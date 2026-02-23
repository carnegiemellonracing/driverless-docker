#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${LIBS:-}" || -z "${DRIVERLESS:-}" ]]; then
  echo "LIBS and DRIVERLESS must be set before running this script."
  exit 1
fi

cd "$(dirname "$0")/../.."
docker compose --profile harness run --rm harness bash
