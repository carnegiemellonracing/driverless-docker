# Harness Container

This container is intentionally aligned with `docker/controls-sim` setup.

The only difference is what you run inside it: the harness testing utility
`/root/harness/run_harness.py`.

## Required host env vars

Set these on host (same requirement style as `controls-sim`):

- `DRIVERLESS` (path to your `driverless` repo)
- `LIBS` (path containing `canUsbKvaserTesting/linuxcan`)

Example:

```bash
export DRIVERLESS=~/dev/driverless
export LIBS=~/dev
```

## Build image

```bash
cd ~/dev/driverless-docker/docker/harness
./build.sh
```

## Spin up container

```bash
cd ~/dev/driverless-docker/docker/harness
./spin_up.sh
```

This uses the same display strategy as `controls-sim`:

- host X11 when available
- otherwise Xvfb + `XDG_RUNTIME_DIR` inside container

## Run harness utility (inside container)

```bash
python3 /root/harness/run_harness.py \
  --manifest /root/driverless/driverless_ws/src/controls/configs/harness/experiments.yaml \
  --parallelism 1 \
  --build
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

## Outputs

By default:

`/root/driverless/driverless_ws/src/controls/logs/harness`

- `summary.json`
- `summary.csv`
- per-run logs/configs under `<run_name>/...`
