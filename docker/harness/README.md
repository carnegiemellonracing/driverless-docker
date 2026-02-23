# Harness Container

This container runs automated controls benchmark sweeps for config pairs:

- controller config (`conf_i`)
- sim config (`sim_i`)

It collects:

- lap times
- midline deviation summary metrics

## Files

- `run_harness.py`: benchmark runner
- `harness_runs.example.yaml`: run manifest example
- `requirements.txt`: Python deps

## Manifest format

```yaml
defaults:
  timeout_sec: 600

runs:
  - name: conf1_sim1
    controller_config: /root/driverless/driverless_ws/src/controls/configs/controller/conf1.yaml
    sim_config: /root/driverless/driverless_ws/src/controls/configs/simulator/sim1.yaml
```

## Build

```bash
cd ~/dev/driverless-docker
docker compose --profile harness build harness
```

## Run (serial)

```bash
cd ~/dev/driverless-docker
docker compose --profile harness run --rm harness \
  python3 /root/harness/run_harness.py \
  --manifest /root/harness/harness_runs.example.yaml \
  --parallelism 1 \
  --build
```

## Run (parallel)

```bash
cd ~/dev/driverless-docker
docker compose --profile harness run --rm harness \
  python3 /root/harness/run_harness.py \
  --manifest /root/harness/harness_runs.example.yaml \
  --parallelism 2
```

## Outputs

By default outputs are written to:

`/root/driverless/driverless_ws/src/controls/logs/harness`

- `summary.json`: full run-by-run data
- `summary.csv`: flattened summary table
- `<run_name>/...`: generated configs and raw logs per run

## Notes

- Each run gets its own `ROS_DOMAIN_ID` for isolation.
- Per-run log paths are auto-overridden so parallel runs do not clobber each other.
- By default, the harness applies sim-safe controller overrides:
  - `send_to_can=false`
  - `display_on=false`
  - `testing_on_controls_sim=true`
  Disable this with `--no-force-sim-safe-controller`.
