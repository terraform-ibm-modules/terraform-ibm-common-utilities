# ICD (IBM Cloud Database) versions

This terraform module uses an external data block to call the ICD API endpoint using a python script to fetch the supported versions of an ICD and outputs the list of stable versions currently supported along with latest and preferred version.

## Prerequisites

### Python Requirements

- **Python 3.x** is required (automatically installed if not present)
- **pip** is required (automatically installed if not present)

#### Automatic Dependency Installation

This module **automatically installs** the required `requests` library when you run `terraform apply` or `terraform plan`. The installation process:

1. **Checks for Python3**: If not found, attempts to install it based on your OS (macOS via Homebrew, Debian/Ubuntu via apt, RHEL/CentOS/Fedora via dnf/yum)
2. **Checks for pip**: If not found, installs it using `ensurepip` or `get-pip.py`
3. **Installs requests library**: Installs `requests>=2.31.0` to `/tmp` directory
4. **Triggers on variable change**: Reinstalls when `auto_install_dependencies` variable changes

The installation uses the `common-bash-library` pattern from terraform-ibm-modules for consistency across modules.

#### Disabling Automatic Installation

If you prefer to manage dependencies yourself:

```hcl
module "icd_versions" {
  source                    = "terraform-ibm-modules/common-utilities/ibm//modules/icd-versions"
  version                   = "X.Y.Z"
  icd_type                  = "redis"
  region                    = "us-south"
  auto_install_dependencies = false  # Disable automatic installation
}
```

If you set `auto_install_dependencies = false`, ensure the `requests` library is available:

```bash
pip install requests>=2.31.0
```

### Corporate Proxy Configuration

If you're running this module from behind a corporate proxy, configure the following environment variables:

```bash
# Set proxy for HTTPS requests
export HTTPS_PROXY="http://proxy.company.com:8080"

# Or with authentication
export HTTPS_PROXY="http://username:password@proxy.company.com:8080" # pragma: allowlist secret

# Optionally exclude certain hosts from proxy
export NO_PROXY="localhost,127.0.0.1,.internal.company.com"
```

### Custom SSL Certificates

If your organization uses SSL inspection or custom CA certificates:

```bash
# Point to your corporate CA bundle
export REQUESTS_CA_BUNDLE="/path/to/corporate-ca-bundle.crt"
```

## Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "xxx123xxxxx" # Provide valid IBM Cloud API key.
}

module "icd_versions" {
  source           = "terraform-ibm-modules/common-utilities/ibm//modules/icd-versions"
  version          = "X.Y.Z" # Replace "X.Y.Z" to lock into a specific release
  icd_type         = "redis" # Replace with the ICD type of which you want to get the versions
  region           = "us-south" # Replace with the region in which you are trying to deploy the ICD
  auto_install_dependencies = false # Set to true if you want to install the dependencies automatically
}
```

### Required IAM access policies

- IAM Services
  - **Databases for Redis** service
    - `Viewer` role access
  - **Databases for PostgreSQL** service
    - `Viewer` role access
  - **Databases for RabbitMQ** service
    - `Viewer` role access
  - **Databases for MySQL** service
    - `Viewer` role access
  - **Databases for MongoDB** service
    - `Viewer` role access
  - **Databases for Elasticsearch** service
    - `Viewer` role access

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >=2.3.5, <3.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.2, < 3.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [external_external.icd_versions](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.install_python_packages](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [ibm_iam_auth_token.tokendata](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_install_dependencies"></a> [auto\_install\_dependencies](#input\_auto\_install\_dependencies) | Set to true to automatically install Python dependencies (requests library). Set to false if dependencies are pre-installed in your environment. | `bool` | `true` | no |
| <a name="input_icd_type"></a> [icd\_type](#input\_icd\_type) | The type of the ICD. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region in which you want to list the supported versions of an ICD. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_latest_version"></a> [latest\_version](#output\_latest\_version) | Latest supported version of the ICD |
| <a name="output_preferred_version"></a> [preferred\_version](#output\_preferred\_version) | Preferred version of the ICD |
| <a name="output_supported_versions"></a> [supported\_versions](#output\_supported\_versions) | List of supported versions of the ICD |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
