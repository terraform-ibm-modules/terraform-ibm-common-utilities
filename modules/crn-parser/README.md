# Terraform IBM common utilities CRN parser

This module takes a CRN string as input, parses the CRN, and returns the segments in the CRN as separate output fields. For more information about what each CRN segment represents, see [Cloud Resource Names](https://cloud.ibm.com/docs/account?topic=account-crn).

## Usage

```hcl
module "crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "X.Y.Z" # Replace "X.Y.Z" to lock into a specific release
  crn     = "crn:v1:bluemix:public:kms:us-south:a/9f9af00a96104f49b6509aa715f9d6a5:44f9c10d-99f5-4547-9e9f-2a1c84b5f0a4:key:f6c9f6d0-92f6-437a-b97c-4b617cb3d320"
}
```

### Required IAM access policies

No permissions are needed to run this module.

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

### Modules

No modules.

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_crn"></a> [crn](#input\_crn) | The CRN to parse. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | Account ID parsed from the CRN `scope` field |
| <a name="output_ctype"></a> [ctype](#output\_ctype) | CRN `ctype` field |
| <a name="output_region"></a> [region](#output\_region) | CRN `region` field |
| <a name="output_resource"></a> [resource](#output\_resource) | CRN `resource` field |
| <a name="output_resource_type"></a> [resource\_type](#output\_resource\_type) | CRN `resource_type` field |
| <a name="output_scope"></a> [scope](#output\_scope) | CRN `scope` field |
| <a name="output_service_instance"></a> [service\_instance](#output\_service\_instance) | CRN `service_instance` field |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | CRN `service_name` field |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
