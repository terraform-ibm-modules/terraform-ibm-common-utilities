# ICD (IBM Cloud Database) Flavors

This terraform module uses an external data block to call the IBM Cloud Global Catalog API using a bash script to fetch the available flavors (member_host_flavor) for an ICD service and outputs the list of available flavors along with the default/recommended flavor.

## Prerequisites

### Script Requirements

- **bash** is required
- **curl** is required
- **jq** is required

Ensure `curl` and `jq` are available in the environment where Terraform runs.

## Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "xxx123xxxxx" # Provide valid IBM Cloud API key.
}

module "icd_flavors" {
  source   = "terraform-ibm-modules/common-utilities/ibm//modules/icd-flavors"
  version  = "X.Y.Z"    # Replace "X.Y.Z" to lock into a specific release
  icd_type = "mongodb"  # Replace with the ICD type of which you want to get the flavors
  region   = "us-south" # Replace with the region in which you are trying to deploy the ICD
}

# Use the output in your ICD resource
resource "ibm_database" "example" {
  name              = "example-db"
  plan              = "standard"
  location          = "us-south"
  service           = "databases-for-mongodb"
  version           = "6.0"

  group {
    group_id = "member"

    members {
      allocation_count = 3
    }

    member_host_flavor = module.icd_flavors.default_flavor
  }
}
```

## Important Notes

- This module is designed for **Gen2 (VPC) ICD services** which use the `databases-for-{type}-standard-gen2` catalog naming convention
- Classic ICD services may have different catalog structures and are not currently supported
- The module fetches flavors from the IBM Cloud Global Catalog API endpoint: `https://globalcatalog.cloud.ibm.com/api/v1/{service}:{region}`

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
| [external_external.icd_flavors](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [ibm_iam_auth_token.tokendata](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_icd_type"></a> [icd\_type](#input\_icd\_type) | The type of the ICD (e.g. postgresql, mongodb). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region in which you want to list the supported flavors of an ICD. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_available_flavors"></a> [available\_flavors](#output\_available\_flavors) | List of available flavors for the ICD |
| <a name="output_default_flavor"></a> [default\_flavor](#output\_default\_flavor) | Default/recommended flavor for the ICD |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Benefits

### Pros
- **Dynamic Updates**: Removes static values from modules and dynamically updates to include/exclude changing flavors
- **Reduced Maintenance**: Avoids the need to rewrite code (including ICD module tests) when IBM changes available flavors
- **Consistency**: Ensures flavor values are always valid and up-to-date with IBM Cloud offerings
- **Validation**: Provides built-in validation that the selected flavor is available in the target region

### Cons
- **Gen2 Only**: Currently designed for Gen2 (VPC) ICD services; Classic ICD services work differently
- **API Dependency**: Requires API access during Terraform plan/apply phases
- **Network Requirement**: Needs network connectivity to IBM Cloud Global Catalog API
