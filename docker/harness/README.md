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

## Required host env vars

Like `controls-sim`, make sure these are set on the host:

- `DRIVERLESS` (path to your `driverless` repo)
- `LIBS` (path containing `canUsbKvaserTesting/linuxcan`)

Example:

```bash
export DRIVERLESS=~/dev/driverless
export LIBS=~/dev
```

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
cd ~/dev/driverless-docker/docker/harness
./build.sh
```

## Spin up shell (controls-sim style)

```bash
cd ~/dev/driverless-docker/docker/harness
./spin_up.sh
```

Then inside the container run:

```bash
python3 /root/harness/run_harness.py \
  --manifest /root/driverless/driverless_ws/src/controls/configs/harness/experiments.yaml \
  --parallelism 1 \
  --build
```

## One-shot run from host

```bash
cd ~/dev/driverless-docker
docker compose --profile harness run --rm harness \
  python3 /root/harness/run_harness.py \
  --manifest /root/driverless/driverless_ws/src/controls/configs/harness/experiments.yaml \
  --parallelism 1 \
  --build
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
