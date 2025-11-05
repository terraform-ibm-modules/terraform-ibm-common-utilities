# Terraform IBM common utilities Image Selector

This Terraform module retrieves the most recent IBM Cloud VPC image based on a specified operating system and architecture.

This module enables filtering of IBM Cloud images based on operating system and system architecture. It currently supports `ubuntu` as the operating system and `amd64` or `s390x` as valid architecture options.

By applying semantic sorting to image names, the module identifies and returns the most recent image available. The resulting image ID and name can be seamlessly integrated into downstream resources such as virtual server instance provisioning.

> Note: IBM Cloud image IDs are region-specific. This module includes a provider block to ensure the correct region is set when querying image metadata.

## Usage

```hcl
module "filtered_images" {
  source           = "terraform-ibm-modules/common-utilities/ibm//modules/image-selector"
  version          = "X.Y.Z" # Replace "X.Y.Z" to lock into a specific release
  ibmcloud_api_key = "xxx123xxxxx" # Provide valid IBM Cloud API key # pragma: allowlist secret
  region           = "us-south" # Region for which images are fetched.
  architecture     = "amd64" # OS Architecture for filtering.
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
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.84.3 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_images.available_images](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/is_images) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architecture"></a> [architecture](#input\_architecture) | The architecture for which the image is to be fetched. Defaults to `amd64`. | `string` | `"amd64"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API Key. | `string` | n/a | yes |
| <a name="input_image_status"></a> [image\_status](#input\_image\_status) | Optional value to provide status of the image. | `string` | `null` | no |
| <a name="input_is_catalog_managed"></a> [is\_catalog\_managed](#input\_is\_catalog\_managed) | Flag to get images which are managed as part of a catalog offering. | `bool` | `false` | no |
| <a name="input_operating_system"></a> [operating\_system](#input\_operating\_system) | The operating system for which the image id should be retrieved. Only ubuntu images are supported currently. | `string` | `"ubuntu"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to get the image information as VPC infrastructure services are a regional specific based endpoint. Defaults to `us-south`. | `string` | `"us-south"` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | The visibility of the image. Defaults to `public`. | `string` | `"public"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_filtered_image_names_by_architecture"></a> [filtered\_image\_names\_by\_architecture](#output\_filtered\_image\_names\_by\_architecture) | List of image names matching the specified system architecture. |
| <a name="output_filtered_image_names_by_os"></a> [filtered\_image\_names\_by\_os](#output\_filtered\_image\_names\_by\_os) | List of image names available for the specified operating system. |
| <a name="output_filtered_image_names_by_os_and_architecture"></a> [filtered\_image\_names\_by\_os\_and\_architecture](#output\_filtered\_image\_names\_by\_os\_and\_architecture) | List of image names that matches both the specified operating system and architecture. |
| <a name="output_latest_image_id_by_os_and_architecture"></a> [latest\_image\_id\_by\_os\_and\_architecture](#output\_latest\_image\_id\_by\_os\_and\_architecture) | Id of the most recent image matching the specified operating system and architecture. |
| <a name="output_latest_image_name_by_os_and_architecture"></a> [latest\_image\_name\_by\_os\_and\_architecture](#output\_latest\_image\_name\_by\_os\_and\_architecture) | Name of the most recent image matching the specified operating system and architecture. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
