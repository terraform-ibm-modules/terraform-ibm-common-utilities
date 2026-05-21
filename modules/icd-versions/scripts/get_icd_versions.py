#!/usr/bin/env python3
import json
import os
import sys
import time

import requests
from requests.exceptions import ConnectionError, ProxyError


def parse_input():
    """
    Reads JSON input from stdin and parses it into a dictionary.
    Returns:
        dict: Parsed input data.
    """
    try:
        data = json.loads(sys.stdin.read())
    except json.JSONDecodeError as e:
        raise ValueError("Invalid JSON input") from e
    return data


def validate_inputs(data):
    """
    Validates required inputs 'IAM_TOKEN', 'REGION' and 'DB_TYPE' from the parsed input.
    Args:
        data (dict): Input data parsed from JSON.
    Returns:
        tuple: A tuple containing (IAM_TOKEN, REGION, DB_TYPE).
    """
    token = data.get("IAM_TOKEN")
    if not token:
        raise ValueError("IAM_TOKEN is required")

    region = data.get("REGION")
    if not region:
        raise ValueError("REGION is required")

    db_type = data.get("DB_TYPE")
    if not db_type:
        raise ValueError("DB_TYPE is required")

    return token, region, db_type


def get_api_endpoint(region):
    """
    Retrieves the API endpoint from environment variable or defaults to region-based URL.
    Args:
        region (str): Region to construct the default URL.
    Returns:
        str: The API endpoint URL.
    """
    api_endpoint = os.getenv("IBMCLOUD_ICD_API_ENDPOINT")
    if not api_endpoint:
        api_endpoint = f"https://api.{region}.databases.cloud.ibm.com"
    return api_endpoint


def fetch_icd_deployables(iam_token, api_endpoint, max_retries=3, retry_delay=10):
    """
    Fetches ICD deployables versions using requests library with retry logic.
    Automatically respects HTTP_PROXY, HTTPS_PROXY, and NO_PROXY environment variables.

    Args:
        iam_token (str): IBM Cloud IAM token for authentication.
        api_endpoint (str): The API endpoint to use.
        max_retries (int): Maximum number of retry attempts (default: 3).
        retry_delay (int): Delay in seconds between retries (default: 10).
    Returns:
        dict: Parsed JSON response containing deployables information.
    """
    # Remove 'Bearer ' prefix if present to avoid double prefixing
    if iam_token.startswith("Bearer "):
        iam_token = iam_token[7:]

    headers = {
        "Authorization": f"Bearer {iam_token}",
        "Accept": "application/json",
    }

    # Construct the full URL
    url = f"{api_endpoint}/v5/ibm/deployables"

    last_exception = None

    for attempt in range(max_retries + 1):  # +1 to include the initial attempt
        try:
            # requests library automatically uses HTTP_PROXY/HTTPS_PROXY environment variables
            # and respects NO_PROXY for exclusions
            response = requests.get(
                url,
                headers=headers,
                timeout=30,  # 30 second timeout
                verify=True,  # Verify SSL certificates (respects REQUESTS_CA_BUNDLE env var)
            )

            if response.status_code != 200:
                error_msg = (
                    f"API request failed: {response.status_code} {response.reason}"
                )

                # Include response body for debugging if available
                try:
                    error_msg += f" - {response.text}"
                except Exception:
                    pass

                # Only retry on server errors (5xx) or rate limiting (429)
                status = response.status_code
                should_retry = status >= 500 or status == 429

                if should_retry and attempt < max_retries:
                    time.sleep(retry_delay)
                    continue
                else:
                    raise RuntimeError(error_msg)

            # Success - return the parsed JSON
            return response.json()

        except requests.exceptions.RequestException as e:
            last_exception = e

            # If this is not the last attempt, silently retry
            # we don't want to print logs for retry as they are going as input to terraform's external data block and it will break the json output expected by terraform
            if attempt < max_retries:
                time.sleep(retry_delay)
            else:
                # Last attempt failed, raise the exception with helpful message
                error_msg = f"HTTP request failed after {max_retries + 1} attempts: {e}"

                if isinstance(e, (ConnectionError, ProxyError)):
                    error_msg += "\nHint: If you're behind a corporate proxy, set HTTPS_PROXY environment variable"

                raise RuntimeError(error_msg) from last_exception


def transform_data(deployables_data, db_type):
    """
    Extracts versions for the specific DB_TYPE.
    Args:
        deployables_data (dict): Raw data returned by the API.
        db_type (str): The type of database to filter for (e.g., 'redis').
    Returns:
        tuple: (versions, preferred_version, latest_version)
    """
    versions = []
    preferred_version = ""
    latest_version = ""

    deployables = deployables_data.get("deployables", [])

    for item in deployables:
        if item.get("type") == db_type:
            for ver in item.get("versions", []):
                if ver.get("status") not in ["dead", "hidden"]:
                    version_str = ver.get("version")
                    versions.append(version_str)
                    if ver.get("is_preferred"):
                        preferred_version = version_str
            # Found the db type, no need to continue unless there are duplicates which shouldn't happen
            break

    if versions:
        # Sort versions to find the latest one.
        # We assume semver-like versioning, so we can split by '.' and convert to int for sorting
        try:
            versions.sort(key=lambda s: list(map(int, s.split("."))))
            latest_version = versions[-1]
        except ValueError:
            # Fallback if version string contains non-numeric characters
            versions.sort()
            latest_version = versions[-1]

    if not versions:
        # It's possible the DB_TYPE is valid but no versions found, or invalid DB_TYPE
        # For our purpose, if we don't find any versions, it might be an issue.
        # But we will return empty list and let terraform validation fail if it tries to match.
        pass

    return versions, preferred_version, latest_version


def format_for_terraform(versions, preferred_version, latest_version):
    """
    Converts the versions list into a JSON string for Terraform external data source consumption.
    Args:
        versions (list): List of version strings.
        preferred_version (str): The preferred version string.
        latest_version (str): The latest version string.
    Returns:
        dict: A dictionary containing version info.
    """
    # Terraform external data source expects a flat map of strings.
    # So we encode the list as a JSON string.
    return {
        "versions": json.dumps(versions),
        "preferred_version": preferred_version,
        "latest_version": latest_version,
    }


def main():
    """
    Main execution function.
    """
    data = parse_input()
    iam_token, region, db_type = validate_inputs(data)

    api_endpoint = get_api_endpoint(region)
    deployables_data = fetch_icd_deployables(iam_token, api_endpoint)
    versions, preferred_version, latest_version = transform_data(
        deployables_data, db_type
    )
    output = format_for_terraform(versions, preferred_version, latest_version)

    print(json.dumps(output))


if __name__ == "__main__":
    main()
