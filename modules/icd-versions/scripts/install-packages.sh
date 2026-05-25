#!/bin/bash

# Ensures Python3, pip are installed, checks for existing packages,
# Installs Python packages from requirements.txt. Returns JSON.

set -o errexit
set -o pipefail

DIRECTORY=${1:-"/tmp"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# renovate: datasource=github-tags depName=terraform-ibm-modules/common-bash-library
# TAG="v0.2.0"  # Commented out for testing with branch
BRANCH="anam-python"  # Testing branch

# Download common-bash-library from branch
curl --silent \
    --connect-timeout 5 \
    --max-time 10 \
    --retry 3 \
    --retry-delay 2 \
    --retry-connrefused \
    --fail \
    --show-error \
    --location \
    --output "${DIRECTORY}/common-bash.tar.gz" \
    "https://github.com/terraform-ibm-modules/common-bash-library/archive/refs/heads/${BRANCH}.tar.gz" >&2

mkdir -p "${DIRECTORY}/common-bash-library"
tar -xzf "${DIRECTORY}/common-bash.tar.gz" --strip-components=1 -C "${DIRECTORY}/common-bash-library" 2>&1 >&2
rm -f "${DIRECTORY}/common-bash.tar.gz"

# shellcheck disable=SC1091
source "${DIRECTORY}/common-bash-library/common/common.sh"

# Ensure Python3 and pip are installed
ensure_python_and_pip >&2

python3 -m pip install --upgrade --target="${DIRECTORY}" -r "${SCRIPT_DIR}/requirements.txt" --quiet --root-user-action=ignore >&2

rm -rf "${DIRECTORY}/common-bash-library"

# Return JSON for external data source
echo '{"status":"success"}'
