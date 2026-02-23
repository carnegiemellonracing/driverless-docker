#!/usr/bin/env python3
"""Automated controls benchmark harness.

Runs controller/sim config pairs, optionally in parallel, and aggregates:
- lap times
- midline deviation summaries
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import shlex
import signal
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml

LAP_REGEX = re.compile(r"Lap:(\d+):([0-9eE+\-.]+)")


@dataclass
class RunSpec:
    name: str
    controller_config: Path
    sim_config: Path
    timeout_sec: int


def _safe_name(name: str) -> str:
    return re.sub(r"[^a-zA-Z0-9_.-]+", "_", name).strip("_") or "run"


def _resolve_path(path_value: str, manifest_dir: Path, workspace: Path) -> Path:
    path = Path(path_value)
    if path.is_absolute():
        return path

    candidates = [
        manifest_dir / path,
        workspace / path,
        workspace / "src" / "controls" / "configs" / path,
        workspace / "src" / "controls" / "configs" / "controller" / path,
        workspace / "src" / "controls" / "configs" / "simulator" / path,
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate.resolve()

    # Fall back to manifest-relative path even if not found so error is explicit later.
    return (manifest_dir / path).resolve()


def _load_yaml(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict):
        raise RuntimeError(f"YAML root must be a mapping: {path}")
    return data


def _ensure_params(root: dict[str, Any], node_name: str) -> dict[str, Any]:
    node = root.get(node_name)
    if not isinstance(node, dict):
        raise RuntimeError(f"Missing node '{node_name}' in config")
    params = node.get("ros__parameters")
    if not isinstance(params, dict):
        raise RuntimeError(f"Missing '{node_name}.ros__parameters' in config")
    return params


def _write_yaml(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        yaml.safe_dump(payload, f, sort_keys=False)


def _run_cmd(cmd: str, env: dict[str, str], log_path: Path) -> subprocess.Popen[str]:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    log_file = log_path.open("w", encoding="utf-8")
    proc = subprocess.Popen(
        ["/bin/bash", "-lc", cmd],
        stdout=log_file,
        stderr=subprocess.STDOUT,
        env=env,
        preexec_fn=os.setsid,
        text=True,
    )
    proc._harness_log_file = log_file  # type: ignore[attr-defined]
    return proc


def _terminate_process(proc: subprocess.Popen[str], grace_sec: float = 10.0) -> None:
    if proc.poll() is not None:
        return
    try:
        os.killpg(os.getpgid(proc.pid), signal.SIGINT)
    except ProcessLookupError:
        return

    start = time.monotonic()
    while proc.poll() is None and (time.monotonic() - start) < grace_sec:
        time.sleep(0.2)

    if proc.poll() is None:
        try:
            os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
        except ProcessLookupError:
            return

    start = time.monotonic()
    while proc.poll() is None and (time.monotonic() - start) < 3.0:
        time.sleep(0.2)

    if proc.poll() is None:
        try:
            os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
        except ProcessLookupError:
            pass


def _close_log(proc: subprocess.Popen[str]) -> None:
    log_file = getattr(proc, "_harness_log_file", None)
    if log_file is not None:
        log_file.close()


def _parse_lap_times(track_log_path: Path, sim_stdout_path: Path) -> list[float]:
    lap_times: list[float] = []

    def parse_text(text: str) -> None:
        for match in LAP_REGEX.finditer(text):
            lap_times.append(float(match.group(2)))

    if track_log_path.exists():
        parse_text(track_log_path.read_text(encoding="utf-8", errors="ignore"))

    if not lap_times and sim_stdout_path.exists():
        parse_text(sim_stdout_path.read_text(encoding="utf-8", errors="ignore"))

    return lap_times


def _parse_midline(midline_csv_path: Path) -> tuple[int, dict[str, Any] | None]:
    if not midline_csv_path.exists() or midline_csv_path.stat().st_size == 0:
        return 0, None

    rows: list[dict[str, Any]] = []
    with midline_csv_path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)

    if not rows:
        return 0, None

    last = rows[-1]
    parsed: dict[str, Any] = {}
    for key, value in last.items():
        if value is None:
            parsed[key] = None
            continue
        if key == "samples":
            parsed[key] = int(value)
        else:
            parsed[key] = float(value)

    return len(rows), parsed


def _run_single(
    run_spec: RunSpec,
    run_idx: int,
    args: argparse.Namespace,
    manifest_dir: Path,
) -> dict[str, Any]:
    start_wall = time.time()
    run_name = _safe_name(run_spec.name)
    run_dir = (Path(args.results_dir) / run_name).resolve()
    generated_dir = run_dir / "generated_configs"
    run_dir.mkdir(parents=True, exist_ok=True)

    controller_cfg = _load_yaml(run_spec.controller_config)
    sim_cfg = _load_yaml(run_spec.sim_config)

    controller_params = _ensure_params(controller_cfg, "controller")
    sim_params = _ensure_params(sim_cfg, "sim_node")

    # Per-run isolated logs to support safe parallel execution.
    midline_log_path = run_dir / "midline_deviation_summary.csv"
    track_log_path = run_dir / "track_times.log"
    collisions_log_path = run_dir / "collisions.log"

    controller_params["midline_deviation_log_file"] = str(midline_log_path)
    sim_params["track_time_log_file_path"] = str(track_log_path)
    sim_params["collision_logs_file_path"] = str(collisions_log_path)

    if args.force_sim_safe_controller:
        if "send_to_can" in controller_params:
            controller_params["send_to_can"] = False
        if "display_on" in controller_params:
            controller_params["display_on"] = False
        if "testing_on_controls_sim" in controller_params:
            controller_params["testing_on_controls_sim"] = True

    generated_controller = generated_dir / "controller.generated.yaml"
    generated_sim = generated_dir / "sim.generated.yaml"
    _write_yaml(generated_controller, controller_cfg)
    _write_yaml(generated_sim, sim_cfg)

    ros_domain_id = args.base_ros_domain_id + run_idx
    env = os.environ.copy()
    env["ROS_DOMAIN_ID"] = str(ros_domain_id)

    source_prefix = (
        "source /opt/ros/humble/setup.bash "
        "&& source /root/driverless/driverless_ws/install/setup.bash"
    )

    sim_stdout = run_dir / "sim.stdout.log"
    controller_stdout = run_dir / "controller.stdout.log"

    sim_cmd = (
        f"{source_prefix} && ros2 run controls sim --ros-args "
        f"--params-file {shlex.quote(str(generated_sim))}"
    )
    controller_cmd = (
        f"{source_prefix} && ros2 run controls controller --ros-args "
        f"--params-file {shlex.quote(str(generated_controller))}"
    )

    sim_proc = _run_cmd(sim_cmd, env=env, log_path=sim_stdout)
    time.sleep(max(args.controller_start_delay_sec, 0.0))
    controller_proc = _run_cmd(controller_cmd, env=env, log_path=controller_stdout)

    status = "ok"
    error = ""
    sim_exit_code: int | None = None
    controller_exit_code: int | None = None

    deadline = time.monotonic() + run_spec.timeout_sec

    try:
        while True:
            sim_exit_code = sim_proc.poll()
            controller_exit_code = controller_proc.poll()

            if sim_exit_code is not None:
                break

            if controller_exit_code is not None and controller_exit_code != 0:
                status = "failed"
                error = f"controller exited early with code {controller_exit_code}"
                _terminate_process(sim_proc)
                sim_exit_code = sim_proc.poll()
                break

            if time.monotonic() > deadline:
                status = "failed"
                error = f"timeout after {run_spec.timeout_sec}s"
                _terminate_process(sim_proc)
                _terminate_process(controller_proc)
                sim_exit_code = sim_proc.poll()
                controller_exit_code = controller_proc.poll()
                break

            time.sleep(0.25)

        # Simulator finished; terminate controller if still alive.
        _terminate_process(controller_proc)
        if controller_exit_code is None:
            controller_exit_code = controller_proc.poll()

        if sim_exit_code is None:
            sim_exit_code = sim_proc.poll()

        if sim_exit_code != 0:
            status = "failed"
            if not error:
                error = f"sim exited with code {sim_exit_code}"

    finally:
        _terminate_process(sim_proc)
        _terminate_process(controller_proc)
        _close_log(sim_proc)
        _close_log(controller_proc)

    lap_times = _parse_lap_times(track_log_path, sim_stdout)
    midline_rows, midline_final = _parse_midline(midline_log_path)

    duration_sec = time.time() - start_wall

    return {
        "name": run_spec.name,
        "run_dir": str(run_dir),
        "controller_config": str(run_spec.controller_config),
        "sim_config": str(run_spec.sim_config),
        "generated_controller_config": str(generated_controller),
        "generated_sim_config": str(generated_sim),
        "ros_domain_id": ros_domain_id,
        "status": status,
        "error": error,
        "sim_exit_code": sim_exit_code,
        "controller_exit_code": controller_exit_code,
        "duration_sec": round(duration_sec, 3),
        "lap_times_sec": lap_times,
        "lap_count": len(lap_times),
        "best_lap_sec": min(lap_times) if lap_times else None,
        "mean_lap_sec": (sum(lap_times) / len(lap_times)) if lap_times else None,
        "midline_rows": midline_rows,
        "midline_final": midline_final,
    }


def _load_manifest(path: Path, args: argparse.Namespace) -> list[RunSpec]:
    payload = _load_yaml(path)
    runs = payload.get("runs")
    if not isinstance(runs, list) or not runs:
        raise RuntimeError("Manifest must contain non-empty 'runs' list")

    defaults = payload.get("defaults", {})
    if defaults is None:
        defaults = {}
    if not isinstance(defaults, dict):
        raise RuntimeError("Manifest 'defaults' must be a mapping")

    default_timeout = int(defaults.get("timeout_sec", args.default_timeout_sec))

    out: list[RunSpec] = []
    for idx, run in enumerate(runs):
        if not isinstance(run, dict):
            raise RuntimeError(f"runs[{idx}] must be a mapping")

        name = str(run.get("name") or f"run_{idx}")

        try:
            controller_config = str(run["controller_config"])
            sim_config = str(run["sim_config"])
        except KeyError as exc:
            raise RuntimeError(f"runs[{idx}] missing required key: {exc}") from exc

        timeout_sec = int(run.get("timeout_sec", default_timeout))
        if timeout_sec <= 0:
            raise RuntimeError(f"runs[{idx}] timeout_sec must be > 0")

        manifest_dir = path.parent.resolve()
        workspace = Path(args.workspace).resolve()

        controller_path = _resolve_path(controller_config, manifest_dir, workspace)
        sim_path = _resolve_path(sim_config, manifest_dir, workspace)

        if not controller_path.exists():
            raise RuntimeError(f"Controller config does not exist: {controller_path}")
        if not sim_path.exists():
            raise RuntimeError(f"Sim config does not exist: {sim_path}")

        out.append(
            RunSpec(
                name=name,
                controller_config=controller_path,
                sim_config=sim_path,
                timeout_sec=timeout_sec,
            )
        )

    return out


def _write_summary(results: list[dict[str, Any]], output_dir: Path) -> tuple[Path, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)

    summary_json = output_dir / "summary.json"
    summary_csv = output_dir / "summary.csv"

    with summary_json.open("w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)

    fieldnames = [
        "name",
        "status",
        "error",
        "ros_domain_id",
        "duration_sec",
        "lap_count",
        "best_lap_sec",
        "mean_lap_sec",
        "sim_exit_code",
        "controller_exit_code",
        "midline_rows",
        "samples",
        "mean_signed_error_m",
        "mean_abs_error_m",
        "rmse_error_m",
        "max_abs_error_m",
        "integral_abs_error_m_s",
        "run_dir",
    ]

    with summary_csv.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for result in results:
            midline = result.get("midline_final") or {}
            writer.writerow(
                {
                    "name": result.get("name"),
                    "status": result.get("status"),
                    "error": result.get("error"),
                    "ros_domain_id": result.get("ros_domain_id"),
                    "duration_sec": result.get("duration_sec"),
                    "lap_count": result.get("lap_count"),
                    "best_lap_sec": result.get("best_lap_sec"),
                    "mean_lap_sec": result.get("mean_lap_sec"),
                    "sim_exit_code": result.get("sim_exit_code"),
                    "controller_exit_code": result.get("controller_exit_code"),
                    "midline_rows": result.get("midline_rows"),
                    "samples": midline.get("samples"),
                    "mean_signed_error_m": midline.get("mean_signed_error_m"),
                    "mean_abs_error_m": midline.get("mean_abs_error_m"),
                    "rmse_error_m": midline.get("rmse_error_m"),
                    "max_abs_error_m": midline.get("max_abs_error_m"),
                    "integral_abs_error_m_s": midline.get("integral_abs_error_m_s"),
                    "run_dir": result.get("run_dir"),
                }
            )

    return summary_json, summary_csv


def _build_workspace(workspace: Path, output_dir: Path) -> None:
    build_log = output_dir / "build.log"
    build_cmd = (
        "source /opt/ros/humble/setup.bash "
        f"&& cd {shlex.quote(str(workspace))} "
        "&& ./build_controls.py"
    )
    with build_log.open("w", encoding="utf-8") as log_file:
        proc = subprocess.run(["/bin/bash", "-lc", build_cmd], stdout=log_file, stderr=subprocess.STDOUT, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"Build failed. See log: {build_log}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run automated controls benchmark sweeps")
    parser.add_argument("--manifest", required=True, help="Path to runs manifest YAML")
    parser.add_argument("--parallelism", type=int, default=1, help="Number of run pairs to execute concurrently")
    parser.add_argument("--workspace", default="/root/driverless/driverless_ws", help="Path to driverless workspace")
    parser.add_argument(
        "--results-dir",
        default="/root/driverless/driverless_ws/src/controls/logs/harness",
        help="Output directory for harness results",
    )
    parser.add_argument("--build", action="store_true", help="Build controls workspace before running tests")
    parser.add_argument("--base-ros-domain-id", type=int, default=70, help="Base ROS_DOMAIN_ID for run isolation")
    parser.add_argument("--default-timeout-sec", type=int, default=600, help="Default per-run timeout")
    parser.add_argument("--controller-start-delay-sec", type=float, default=1.0, help="Delay between launching sim and controller")
    parser.add_argument(
        "--force-sim-safe-controller",
        action="store_true",
        default=True,
        help="Force controller config overrides for sim testing (send_to_can=false, display_on=false, testing_on_controls_sim=true)",
    )
    parser.add_argument(
        "--no-force-sim-safe-controller",
        dest="force_sim_safe_controller",
        action="store_false",
        help="Disable automatic controller safety overrides",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.parallelism <= 0:
        print("--parallelism must be > 0", file=sys.stderr)
        return 2

    manifest_path = Path(args.manifest).resolve()
    if not manifest_path.exists():
        print(f"Manifest not found: {manifest_path}", file=sys.stderr)
        return 2

    results_dir = Path(args.results_dir).resolve()
    results_dir.mkdir(parents=True, exist_ok=True)

    try:
        run_specs = _load_manifest(manifest_path, args)
        print(f"Loaded {len(run_specs)} run specs from {manifest_path}")

        if args.build:
            print("Building controls workspace before benchmark run...")
            _build_workspace(Path(args.workspace).resolve(), results_dir)

        results: list[dict[str, Any]] = [None] * len(run_specs)  # type: ignore[list-item]
        with ThreadPoolExecutor(max_workers=args.parallelism) as executor:
            futures = {
                executor.submit(_run_single, run_spec, idx, args, manifest_path.parent.resolve()): idx
                for idx, run_spec in enumerate(run_specs)
            }
            for future in as_completed(futures):
                idx = futures[future]
                result = future.result()
                results[idx] = result
                print(
                    f"[{idx + 1}/{len(run_specs)}] {result['name']}: {result['status']} "
                    f"(laps={result['lap_count']}, best={result['best_lap_sec']})"
                )

        summary_json, summary_csv = _write_summary(results, results_dir)
        print(f"Wrote summary JSON: {summary_json}")
        print(f"Wrote summary CSV:  {summary_csv}")

        failed = [r for r in results if r.get("status") != "ok"]
        return 1 if failed else 0

    except Exception as exc:
        print(f"Harness failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
