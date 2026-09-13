#!/bin/bash
# ------------------------------ start.sh ------------------------
# A shell script to run initial git authentication and clone driverless repo
# Author: Arya Lohia (a-lohia)
# Last Updated: 09/12/26

set -eou pipefail

# setup auth through github cli
# Note: requires user input
gh auth login
gh auth setup-git

WORKSPACE_ROOT=/root/driverless

# Clone driverless repo
git -C $WORKSPACE_ROOT clone --recurse-submodules https://github.com/carnegiemellonracing/driverless.git
cd ${WORKSPACE_ROOT}/driverless/driverless_ws

# setup dv paths / cmds
chmod +x ${WORKSPACE_ROOT}/driverless/scripts/setup/driverless_setup.sh
${WORKSPACE_ROOT}/driverless/scripts/setup/driverless_setup.sh