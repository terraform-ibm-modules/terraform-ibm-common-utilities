#!/usr/bin/env bash

set -euo pipefail

# Function to parse JSON input from stdin
parse_input() {
    local input
    input=$(cat)

    # Validate JSON
    if ! echo "$input" | jq empty 2>/dev/null; then
        echo "Error: Invalid JSON input" >&2
        exit 1
    fi

    echo "$input"
}

# Function to validate required inputs
validate_inputs() {
    local data="$1"
    local token region db_type

    token=$(echo "$data" | jq -r '.IAM_TOKEN // empty')
    if [[ -z "$token" ]]; then
        echo "Error: IAM_TOKEN is required" >&2
        exit 1
    fi

    region=$(echo "$data" | jq -r '.REGION // empty')
    if [[ -z "$region" ]]; then
        echo "Error: REGION is required" >&2
        exit 1
    fi

    db_type=$(echo "$data" | jq -r '.DB_TYPE // empty')
    if [[ -z "$db_type" ]]; then
        echo "Error: DB_TYPE is required" >&2
        exit 1
    fi

    echo "$token|$region|$db_type"
}

# Function to get API endpoint
get_api_endpoint() {
    local region="$1"
    local api_endpoint

    api_endpoint="${IBMCLOUD_ICD_API_ENDPOINT:-}"
    if [[ -z "$api_endpoint" ]]; then
        api_endpoint="https://api.${region}.databases.cloud.ibm.com"
    fi

    echo "$api_endpoint"
}

# Function to fetch ICD deployables with retry logic
fetch_icd_deployables() {
    local iam_token="$1"
    local api_endpoint="$2"
    local max_retries="${3:-3}"
    local retry_delay="${4:-10}"

    # Remove 'Bearer ' prefix if present
    iam_token="${iam_token#Bearer }"

    local url="${api_endpoint}/v5/ibm/deployables"
    local attempt=0
    local response
    local http_code

    while [[ $attempt -le $max_retries ]]; do
        response=$(curl -s -w "\n%{http_code}" \
            -H "Authorization: Bearer ${iam_token}" \
            -H "Accept: application/json" \
            "$url" 2>&1) || {

            if [[ $attempt -lt $max_retries ]]; then
                ((attempt++))
                sleep "$retry_delay"
                continue
            else
                echo "Error: HTTP request failed after $((max_retries + 1)) attempts" >&2
                exit 1
            fi
        }

        http_code=$(echo "$response" | tail -n1)
        response=$(echo "$response" | sed '$d')

        if [[ "$http_code" -eq 200 ]]; then
            echo "$response"
            return 0
        else
            # Check if we should retry (5xx errors or 429 rate limiting)
            local should_retry=0
            if [[ "$http_code" -ge 500 ]] || [[ "$http_code" -eq 429 ]]; then
                should_retry=1
            fi

            if [[ $should_retry -eq 1 ]] && [[ $attempt -lt $max_retries ]]; then
                ((attempt++))
                sleep "$retry_delay"
                continue
            else
                echo "Error: API request failed: $http_code - $response" >&2
                exit 1
            fi
        fi
    done
}

# Function to transform data and extract versions
transform_data() {
    local deployables_data="$1"
    local db_type="$2"

    # Extract versions for the specific DB_TYPE
    local versions preferred_version latest_version

    # Use jq to filter and extract data
    versions=$(echo "$deployables_data" | jq -r --arg dbtype "$db_type" '
        .deployables[]
        | select(.type == $dbtype)
        | .versions[]
        | select(.status != "dead" and .status != "hidden")
        | .version
    ' | jq -R -s -c 'split("\n") | map(select(length > 0))')

    preferred_version=$(echo "$deployables_data" | jq -r --arg dbtype "$db_type" '
        .deployables[]
        | select(.type == $dbtype)
        | .versions[]
        | select(.status != "dead" and .status != "hidden" and .is_preferred == true)
        | .version
    ' | head -n1)

    # If no preferred version found, set to empty string
    [[ -z "$preferred_version" ]] && preferred_version=""

    # Calculate latest version by sorting
    if [[ "$versions" != "[]" ]]; then
        latest_version=$(echo "$versions" | jq -r '.[]' | sort -V | tail -n1)
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
        --argjson versions "$versions" \
        --arg preferred "$preferred_version" \
        --arg latest "$latest_version" \
        '{
            versions: ($versions | tostring),
            preferred_version: $preferred,
            latest_version: $latest
        }'
}

# Main function
main() {
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed" >&2
        exit 1
    fi

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is required but not installed" >&2
        exit 1
    fi

    # Parse input
    local data
    data=$(parse_input)

    # Validate inputs
    local validated
    validated=$(validate_inputs "$data")
    IFS='|' read -r iam_token region db_type <<< "$validated"

    # Get API endpoint
    local api_endpoint
    api_endpoint=$(get_api_endpoint "$region")

    # Fetch deployables data
    local deployables_data
    deployables_data=$(fetch_icd_deployables "$iam_token" "$api_endpoint")

    # Transform data
    local transformed
    transformed=$(transform_data "$deployables_data" "$db_type")
    IFS='|' read -r versions preferred_version latest_version <<< "$transformed"

    # Format and output for Terraform
    format_for_terraform "$versions" "$preferred_version" "$latest_version"
}

main
