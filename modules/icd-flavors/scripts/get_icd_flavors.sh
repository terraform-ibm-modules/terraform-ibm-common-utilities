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

# Function to construct catalog service name
get_catalog_service_name() {
    local db_type="$1"

    # Map ICD type to catalog service name
    # Format: databases-for-{type}-standard-gen2
    echo "databases-for-${db_type}-standard-gen2"
}

# Function to fetch ICD flavors from catalog
fetch_icd_flavors() {
    local iam_token="$1"
    local region="$2"
    local service_name="$3"

    local url="https://globalcatalog.cloud.ibm.com/api/v1/${service_name}:${region}"
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
        "$url") || error "HTTP request failed"

    # Split response into body and status code
    http_code="${response##*$'\n'}"
    body="${response%$'\n'*}"

    # Validate HTTP response
    if [[ "$http_code" != "200" ]]; then
        error "Catalog API request failed with HTTP ${http_code}: ${body}"
    fi

    # Validate API response JSON
    if ! jq -e . >/dev/null 2>&1 <<< "$body"; then
        error "Invalid JSON response from Catalog API"
    fi

    # Validate expected response structure
    if ! jq -e '
        has("metadata") and
        (.metadata | has("other")) and
        (.metadata.other | has("flavors"))
    ' >/dev/null 2>&1 <<< "$body"; then
        error "Catalog API response missing expected 'metadata.other.flavors' structure"
    fi

    echo "$body"
}

# Function to transform data and extract flavors
transform_data() {
    local catalog_data="$1"

    local flavors
    local default_flavor

    # Extract all available flavors
    flavors=$(jq -c '
        [
            .metadata.other.flavors[]
            | .name
        ]
    ' <<< "$catalog_data")

    # Extract default/recommended flavor (first one or marked as default)
    default_flavor=$(jq -r '
        .metadata.other.flavors[0].name // ""
    ' <<< "$catalog_data")

    echo "$flavors|$default_flavor"
}

# Function to format output for Terraform
format_for_terraform() {
    local flavors="$1"
    local default_flavor="$2"

    jq -n \
        --arg flavors "$flavors" \
        --arg default "$default_flavor" \
        '{
            flavors: $flavors,
            default_flavor: $default
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

    # Get catalog service name
    local service_name
    service_name=$(get_catalog_service_name "$db_type")

    # Fetch catalog data
    local catalog_data
    catalog_data=$(fetch_icd_flavors "$iam_token" "$region" "$service_name")

    # Transform data
    local transformed
    transformed=$(transform_data "$catalog_data")

    local flavors
    local default_flavor

    IFS='|' read -r flavors default_flavor <<< "$transformed"

    # Format output for Terraform
    format_for_terraform "$flavors" "$default_flavor"
}

main

# Made with Bob
