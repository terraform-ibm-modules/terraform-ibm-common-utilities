#!/bin/bash

# Wrapper script for external data source
# Installs Python packages from requirements.txt and returns JSON

set -o errexit
set -o pipefail

DIRECTORY=${1:-"/tmp"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install packages from requirements.txt
python3 -m pip install --upgrade --target="${DIRECTORY}" -r "${SCRIPT_DIR}/requirements.txt" --quiet --root-user-action=ignore >&2

# Return JSON for external data source
echo '{"status":"success"}'
