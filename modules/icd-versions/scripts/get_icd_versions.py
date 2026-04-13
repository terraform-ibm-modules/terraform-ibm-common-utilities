#!/usr/bin/env python3
import http.client
import json
import os
import sys
import base64
import time
from urllib.parse import urlparse


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
    Fetches ICD deployables versions using HTTP connection with proxy support and retry logic.
    
    Args:
        iam_token (str): IBM Cloud IAM token for authentication.
        api_endpoint (str): The API endpoint to use.
        max_retries (int): Maximum number of retry attempts. Default is 3.
        retry_delay (int): Initial delay in seconds between retries. Default is 10.
                          Uses exponential backoff (delay * 2^attempt).
    Returns:
        dict: Parsed JSON response containing deployables information.
    """
    parsed = urlparse(api_endpoint)
    host = parsed.hostname
    port = parsed.port or 443

    # Remove 'Bearer ' prefix if present to avoid double prefixing
    if iam_token.startswith("Bearer "):
        iam_token = iam_token[7:]

    headers = {
        "Authorization": f"Bearer {iam_token}",
        "Accept": "application/json",
    }

    # Check for proxy configuration from environment variables
    # Check both uppercase and lowercase versions for compatibility
    https_proxy = os.getenv('HTTPS_PROXY') or os.getenv('https_proxy')
    http_proxy = os.getenv('HTTP_PROXY') or os.getenv('http_proxy')
    no_proxy = os.getenv('NO_PROXY') or os.getenv('no_proxy') or ''
    
    # Determine if we should use proxy for this host
    use_proxy = True
    if no_proxy:
        no_proxy_list = [item.strip() for item in no_proxy.split(',')]
        for pattern in no_proxy_list:
            if pattern.startswith('*.'):
                # Wildcard domain matching (e.g., *.echonet matches host.echonet)
                if host.endswith(pattern[1:]):
                    use_proxy = False
                    break
            elif pattern == host or host.endswith('.' + pattern):
                # Exact match or subdomain match
                use_proxy = False
                break
    
    # Select appropriate proxy based on protocol
    proxy_url = https_proxy if parsed.scheme == 'https' else http_proxy
    
    # Retry loop with exponential backoff
    last_exception = None
    for attempt in range(max_retries):
        conn = None
        try:
            if use_proxy and proxy_url:
                # Parse proxy URL to extract host, port, and credentials
                proxy_parsed = urlparse(proxy_url)
                proxy_host = proxy_parsed.hostname
                proxy_port = proxy_parsed.port or 8080
                proxy_user = proxy_parsed.username
                proxy_pass = proxy_parsed.password
                
                # Validate proxy host is not None
                if not proxy_host:
                    raise ValueError(f"Invalid proxy URL: {proxy_url}")
                
                # Create HTTPS connection to the proxy server
                conn = http.client.HTTPSConnection(proxy_host, proxy_port, timeout=30)
                
                # Set up CONNECT tunnel to the target host through the proxy
                # This is required for HTTPS connections through HTTP proxies
                conn.set_tunnel(host, port)
                
                # If proxy requires authentication, add credentials to tunnel headers
                if proxy_user and proxy_pass:
                    # Encode credentials for HTTP Basic authentication
                    credentials = f"{proxy_user}:{proxy_pass}"
                    encoded_credentials = base64.b64encode(credentials.encode()).decode()
                    
                    # Set tunnel headers with proxy authentication
                    # Note: We're accessing internal attributes here, which is necessary
                    # for adding authentication to the CONNECT tunnel
                    # Type ignore comments are needed as these are internal implementation details
                    conn._tunnel_host = host  # type: ignore[attr-defined]
                    conn._tunnel_port = port  # type: ignore[attr-defined]
                    conn._tunnel_headers = {  # type: ignore[attr-defined]
                        'Proxy-Authorization': f'Basic {encoded_credentials}',
                        'Proxy-Connection': 'Keep-Alive'
                    }
            else:
                # Direct connection without proxy
                conn = http.client.HTTPSConnection(host, port, timeout=30)
            
            # Make the API request
            url = "/v5/ibm/deployables"
            conn.request("GET", url, headers=headers)
            response = conn.getresponse()
            data = response.read().decode()

            if response.status != 200:
                # For 5xx errors, retry; for 4xx errors, fail immediately
                if 500 <= response.status < 600:
                    raise RuntimeError(
                        f"API request failed with server error: {response.status} {response.reason}"
                    )
                else:
                    # Client error - don't retry
                    raise RuntimeError(
                        f"API request failed: {response.status} {response.reason} - {data}"
                    )

            # Success - return the parsed JSON
            return json.loads(data)
            
        except (http.client.HTTPException, ConnectionError, TimeoutError) as e:
            # These are retryable errors
            last_exception = e
            if attempt < max_retries - 1:
                # Calculate exponential backoff delay
                wait_time = retry_delay * (2 ** attempt)
                sys.stderr.write(
                    f"Attempt {attempt + 1}/{max_retries} failed: {str(e)}. "
                    f"Retrying in {wait_time} seconds...\n"
                )
                time.sleep(wait_time)
            else:
                # Last attempt failed
                raise RuntimeError(
                    f"All {max_retries} retry attempts failed. Last error: {str(e)}"
                ) from e
                
        except json.JSONDecodeError as e:
            # JSON parsing error - don't retry
            raise RuntimeError(f"Failed to parse API response as JSON: {str(e)}") from e
            
        except Exception as e:
            # Unexpected error - don't retry
            raise RuntimeError(f"Connection error: {str(e)}") from e
            
        finally:
            if conn is not None:
                conn.close()
    
    # If we get here, all retries failed
    if last_exception:
        raise RuntimeError(
            f"All {max_retries} retry attempts failed. Last error: {str(last_exception)}"
        ) from last_exception
    else:
        raise RuntimeError(f"All {max_retries} retry attempts failed with unknown error")


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
