#!/usr/bin/env python3
import json
import os
import subprocess
import sys


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
        # Validate region is not empty
        if not region or region.strip() == "":
            raise ValueError(
                "REGION is empty or invalid. Cannot construct API endpoint URL."
            )
        api_endpoint = f"https://api.{region}.databases.cloud.ibm.com"
    
    # Validate the constructed/provided endpoint
    if not api_endpoint.startswith(("http://", "https://")):
        raise ValueError(
            f"Invalid API endpoint: '{api_endpoint}'. "
            f"URL must start with http:// or https://"
        )
    
    return api_endpoint


def fetch_icd_deployables(iam_token, api_endpoint):
    """
    Fetches ICD deployables versions using curl command.
    This approach works better with corporate proxies and DNS configurations.
    Args:
        iam_token (str): IBM Cloud IAM token for authentication.
        api_endpoint (str): The API endpoint to use.
    Returns:
        dict: Parsed JSON response containing deployables information.
    """
    # Validate API endpoint
    if not api_endpoint or not api_endpoint.startswith(("http://", "https://")):
        raise ValueError(
            f"Invalid API endpoint URL: '{api_endpoint}'. "
            f"URL must start with http:// or https://"
        )

    # Remove 'Bearer ' prefix if present to avoid double prefixing
    if iam_token.startswith("Bearer "):
        iam_token = iam_token[7:]

    # Construct the full URL
    url = f"{api_endpoint.rstrip('/')}/v5/ibm/deployables"
    
    # Build curl command
    # Using curl respects system proxy settings and DNS configuration better than Python's http.client
    curl_command = [
        "curl",
        "-s",  # Silent mode
        "-f",  # Fail silently on HTTP errors
        "-H", f"Authorization: Bearer {iam_token}",
        "-H", "Accept: application/json",
        url
    ]
    
    try:
        # Execute curl command
        result = subprocess.run(
            curl_command,
            capture_output=True,
            text=True,
            timeout=30,
            check=True
        )
        
        # Parse JSON response
        try:
            return json.loads(result.stdout)
        except json.JSONDecodeError as e:
            raise RuntimeError(
                f"Failed to parse API response as JSON. Response: {result.stdout[:200]}"
            ) from e
            
    except subprocess.TimeoutExpired:
        raise RuntimeError("API request timed out after 30 seconds")
    except subprocess.CalledProcessError as e:
        error_msg = f"API request failed with exit code {e.returncode}"
        if e.stderr:
            error_msg += f". Error: {e.stderr}"
        if e.stdout:
            error_msg += f". Response: {e.stdout[:200]}"
        raise RuntimeError(error_msg)
    except FileNotFoundError:
        raise RuntimeError(
            "curl command not found. Please ensure curl is installed and available in PATH."
        )


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
    try:
        data = parse_input()
        iam_token, region, db_type = validate_inputs(data)

        api_endpoint = get_api_endpoint(region)
        deployables_data = fetch_icd_deployables(iam_token, api_endpoint)
        versions, preferred_version, latest_version = transform_data(
            deployables_data, db_type
        )
        output = format_for_terraform(versions, preferred_version, latest_version)

        print(json.dumps(output))
    except ValueError as e:
        sys.stderr.write(f"ERROR: Validation failed: {str(e)}\n")
        sys.exit(1)
    except RuntimeError as e:
        sys.stderr.write(f"ERROR: Runtime error: {str(e)}\n")
        sys.exit(1)
    except Exception as e:
        sys.stderr.write(f"ERROR: Unexpected error: {str(e)}\n")
        sys.stderr.write(f"ERROR: Type: {type(e).__name__}\n")
        sys.exit(1)


if __name__ == "__main__":
    main()
