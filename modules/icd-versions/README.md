# ICD (IBMCloud Database) versions

This terraform module uses an external data block to call the ICD API endpoint to fetch the supported versions of an ICD and outputs the list of stable versions currently supported along with latest and preferred version.

## Usage

```hcl

provider "ibm" {
  ibmcloud_api_key = "xxx123xxxxx" # Provide valid IBM Cloud API key # pragma: allowlist secret
  region           = "us-south" # Region for which images are fetched.
}

module "icd_versions" {
  source           = "terraform-ibm-modules/common-utilities/ibm//modules/icd-versions"
  version          = "X.Y.Z" # Replace "X.Y.Z" to lock into a specific release
  icd_type         = "redis" # Replace with the ICD type of which you want to get the versions
  region           = "us-south" # Replace with the region in which you are trying to deploy the ICD
}
```

### Required IAM access policies

No permissions are needed to run this module.

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >=2.3.5, <3.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.2, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [external_external.icd_versions](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [ibm_iam_auth_token.tokendata](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_icd_type"></a> [icd\_type](#input\_icd\_type) | The type of the ICD. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region in which you want to list the supported versions of an ICD. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_latest_version"></a> [latest\_version](#output\_latest\_version) | Latest supported version of the ICD |
| <a name="output_preferred_version"></a> [preferred\_version](#output\_preferred\_version) | Preferred version of the ICD |
| <a name="output_supported_versions"></a> [supported\_versions](#output\_supported\_versions) | List of supported versions of the ICD |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
