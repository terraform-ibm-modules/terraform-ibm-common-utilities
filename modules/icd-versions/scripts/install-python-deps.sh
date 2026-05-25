#!/bin/bash

# This script downloads common-bash-library and installs Python dependencies
# required for the ICD versions module.

set -o errexit
set -o pipefail

DIRECTORY=${1:-"/tmp"}
# renovate: datasource=github-tags depName=terraform-ibm-modules/common-bash-library
# TAG="v0.2.0"  # Commented out for testing with branch
BRANCH="anam-python"  # Testing branch

echo "Downloading common-bash-library from branch ${BRANCH}."

# download common-bash-library from branch
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
    "https://github.com/terraform-ibm-modules/common-bash-library/archive/refs/heads/${BRANCH}.tar.gz"

mkdir -p "${DIRECTORY}/common-bash-library"
tar -xzf "${DIRECTORY}/common-bash.tar.gz" --strip-components=1 -C "${DIRECTORY}/common-bash-library"
rm -f "${DIRECTORY}/common-bash.tar.gz"

# The file doesn't exist at the time shellcheck runs, so this check is skipped.
# shellcheck disable=SC1091
source "${DIRECTORY}/common-bash-library/common/common.sh"

echo "Installing Python requests library."
install_python_package "requests>=2.31.0" "${DIRECTORY}"

rm -rf "${DIRECTORY}/common-bash-library"

echo "Installation complete successfully"
