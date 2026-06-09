#!/usr/bin/env bash

set -euo pipefail

# Function to print error messages
error() {
    echo "Error: $*" >&2
    exit 1
}

# Function to parse JSON input from stdin
parse_input() {
    local input

    input=$(cat)

    [[ -z "$input" ]] && error "No JSON input provided"

    # Validate JSON input
    if ! jq -e . >/dev/null 2>&1 <<< "$input"; then
        error "Invalid JSON input"
    fi

    echo "$input"
}

# Function to validate required inputs
validate_inputs() {
    local data="$1"
    local token
    local region
    local db_type

    token=$(jq -r '.IAM_TOKEN // empty' <<< "$data")
    [[ -z "$token" ]] && error "IAM_TOKEN is required"

    region=$(jq -r '.REGION // empty' <<< "$data")
    [[ -z "$region" ]] && error "REGION is required"

    db_type=$(jq -r '.DB_TYPE // empty' <<< "$data")
    [[ -z "$db_type" ]] && error "DB_TYPE is required"

    # Remove optional Bearer prefix
    token="${token#Bearer }"

    echo "$token|$region|$db_type"
}

# Function to get API endpoint
get_api_endpoint() {
    local region="$1"

    echo "${IBMCLOUD_ICD_API_ENDPOINT:-https://api.${region}.databases.cloud.ibm.com}"
}

# Function to get fallback regions for ca-mon
get_fallback_regions() {
    local primary_region="$1"

    # Only ca-mon region has fallback support
    if [[ "$primary_region" == "ca-mon" ]]; then
        # Fallback to ca-tor first, then us-south
        echo "ca-tor us-south"
    else
        echo ""
    fi
}

# Function to fetch ICD deployables with fallback support
fetch_icd_deployables() {
    local iam_token="$1"
    local api_endpoint="$2"

    local url="${api_endpoint}/v5/ibm/deployables"
    local response
    local http_code
    local body

    response=$(curl --silent \
        --show-error \
        --connect-timeout 5 \
        --max-time 10 \
        --retry 3 \
        --retry-delay 2 \
        --retry-connrefused \
        --location \
        -w "\n%{http_code}" \
        -H "Authorization: Bearer ${iam_token}" \
        -H "Accept: application/json" \
        "$url" 2>&1) || return 1

    # Split response into body and status code
    http_code="${response##*$'\n'}"
    body="${response%$'\n'*}"

    # Validate HTTP response
    if [[ "$http_code" != "200" ]]; then
        return 1
    fi

    # Validate API response JSON
    if ! jq -e . >/dev/null 2>&1 <<< "$body"; then
        return 1
    fi

    # Validate expected response structure
    if ! jq -e '
        has("deployables") and
        (.deployables | type == "array")
    ' >/dev/null 2>&1 <<< "$body"; then
        return 1
    fi

    echo "$body"
    return 0
}

fetch_with_fallback() {
    local iam_token="$1"
    local primary_region="$2"
    local primary_endpoint
    local deployables_data

    primary_endpoint=$(get_api_endpoint "$primary_region")

    # Try primary endpoint
    echo "Attempting to fetch from primary endpoint: ${primary_endpoint}" >&2
    if deployables_data=$(fetch_icd_deployables "$iam_token" "$primary_endpoint"); then
        echo "Successfully fetched from primary endpoint: ${primary_endpoint}" >&2
        echo "$deployables_data"
        return 0
    fi

    echo "Warning: Primary endpoint ${primary_endpoint} failed or is unavailable" >&2

    # Only use fallback for ca-mon region
    if [[ "$primary_region" != "ca-mon" ]]; then
        error "API endpoint failed for region '${primary_region}'."
    fi

    # Try fallback regions
    local fallback_regions
    read -ra fallback_regions <<< "$(get_fallback_regions "$primary_region")"

    for fallback_region in "${fallback_regions[@]}"; do
        local fallback_endpoint
        fallback_endpoint=$(get_api_endpoint "$fallback_region")

        echo "Attempting fallback endpoint: ${fallback_endpoint}" >&2
        if deployables_data=$(fetch_icd_deployables "$iam_token" "$fallback_endpoint"); then
            echo "Successfully fetched from fallback endpoint: ${fallback_endpoint}" >&2
            echo "$deployables_data"
            return 0
        fi

        echo "Warning: Fallback endpoint ${fallback_endpoint} failed" >&2
    done

    error "All API endpoints failed. Tried primary region '${primary_region}' and fallback regions: ${fallback_regions[*]}"
}

# Function to transform data and extract versions
transform_data() {
    local deployables_data="$1"
    local db_type="$2"

    local versions
    local preferred_version
    local latest_version

    # Extract valid versions
    versions=$(jq -c --arg dbtype "$db_type" '
        [
            .deployables[]
            | select(.type == $dbtype)
            | .versions[]
            | select(.status != "dead" and .status != "hidden")
            | .version
        ]
    ' <<< "$deployables_data")

    # Extract preferred version
    preferred_version=$(jq -r --arg dbtype "$db_type" '
        .deployables[]
        | select(.type == $dbtype)
        | .versions[]
        | select(
            .status != "dead"
            and .status != "hidden"
            and .is_preferred == true
        )
        | .version
    ' <<< "$deployables_data" | head -n1)

    preferred_version="${preferred_version:-}"

    # Determine latest version
    if [[ "$versions" != "[]" ]]; then
        latest_version=$(
            jq -r '.[]' <<< "$versions" \
            | sort -V \
            | tail -n1
        )
    else
        latest_version=""
    fi

    echo "$versions|$preferred_version|$latest_version"
}

# Function to format output for Terraform
format_for_terraform() {
    local versions="$1"
    local preferred_version="$2"
    local latest_version="$3"

    jq -n \
        --arg versions "$versions" \
        --arg preferred "$preferred_version" \
        --arg latest "$latest_version" \
        '{
            versions: $versions,
            preferred_version: $preferred,
            latest_version: $latest
        }'
}

# Main function
main() {
    # Check required dependencies
    command -v jq >/dev/null 2>&1 || error "jq is required but not installed"
    command -v curl >/dev/null 2>&1 || error "curl is required but not installed"

    # Parse input
    local data
    data=$(parse_input)

    # Validate inputs
    local validated
    validated=$(validate_inputs "$data")

    local iam_token
    local region
    local db_type

    IFS='|' read -r iam_token region db_type <<< "$validated"

    # Get API endpoint
    local api_endpoint
    api_endpoint=$(get_api_endpoint "$region")

    # Fetch deployables data with fallback support
    local deployables_data
    deployables_data=$(fetch_with_fallback "$iam_token" "$region")

    # Transform data
    local transformed
    transformed=$(transform_data "$deployables_data" "$db_type")

    local versions
    local preferred_version
    local latest_version

    IFS='|' read -r versions preferred_version latest_version <<< "$transformed"

    # Format output for Terraform
    format_for_terraform "$versions" "$preferred_version" "$latest_version"
}

main
