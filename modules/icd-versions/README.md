# ICD (IBM Cloud Database) versions

This terraform module uses an external data block to call the ICD API endpoint using a bash script to fetch the supported versions of an ICD and outputs the list of stable versions currently supported along with latest and preferred version.

The module supports both **Gen1** and **Gen2** IBM Cloud Databases:
- **Gen1**: Uses the ICD API endpoint (`https://api.{region}.databases.cloud.ibm.com/v5/ibm/deployables`)
- **Gen2**: Uses the Global Catalog API endpoint (`https://globalcatalog.cloud.ibm.com/api/v1/{service}-{plan}:{region}`)
  - Gen2 is detected automatically when the `plan` parameter ends with `-gen2` suffix

## Prerequisites

### Script Requirements

- **bash** is required
- **curl** is required
- **jq** is required

Ensure `curl` and `jq` are available in the environment where Terraform runs.

## Usage

### Gen1 Databases (Legacy)

```hcl
provider "ibm" {
  ibmcloud_api_key = "xxx123xxxxx" # Provide valid IBM Cloud API key.
}

module "icd_versions" {
  source   = "terraform-ibm-modules/common-utilities/ibm//modules/icd-versions"
  version  = "X.Y.Z"    # Replace "X.Y.Z" to lock into a specific release
  icd_type = "redis"    # Replace with the ICD type of which you want to get the versions
  region   = "us-south" # Replace with the region in which you are trying to deploy the ICD
}
```

### Gen2 Databases

For Gen2 databases, you must provide both `plan` (with `-gen2` suffix) and `service` parameters:

```hcl
provider "ibm" {
  ibmcloud_api_key = "xxx123xxxxx" # Provide valid IBM Cloud API key.
}

module "icd_versions_gen2" {
  source   = "terraform-ibm-modules/common-utilities/ibm//modules/icd-versions"
  version  = "X.Y.Z"                           # Replace "X.Y.Z" to lock into a specific release
  icd_type = "postgresql"                      # Database type
  region   = "us-south"                        # Region
  plan     = "standard-gen2"                   # Gen2 plan - MUST end with '-gen2' suffix
  service  = "databases-for-postgresql"        # Gen2 service name
}
```

**Note**: The `plan` parameter MUST end with `-gen2` suffix for Gen2 databases. This is how the module detects whether to use Gen1 or Gen2 API.

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
| [ibm_iam_auth_token.tokendata](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_icd_type"></a> [icd\_type](#input\_icd\_type) | The type of the ICD. | `string` | n/a | yes |
| <a name="input_plan"></a> [plan](#input\_plan) | The plan for Gen2 databases (e.g., 'standard-gen2', 'enterprise-gen2'). Must end with '-gen2' suffix for Gen2 databases. Leave empty for Gen1. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which you want to list the supported versions of an ICD. | `string` | n/a | yes |
| <a name="input_service"></a> [service](#input\_service) | The service name for Gen2 databases (e.g., 'databases-for-postgresql'). Required for Gen2 databases, leave empty for Gen1. | `string` | `""` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_latest_version"></a> [latest\_version](#output\_latest\_version) | Latest supported version of the ICD |
| <a name="output_preferred_version"></a> [preferred\_version](#output\_preferred\_version) | Preferred version of the ICD |
| <a name="output_supported_versions"></a> [supported\_versions](#output\_supported\_versions) | List of supported versions of the ICD |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
