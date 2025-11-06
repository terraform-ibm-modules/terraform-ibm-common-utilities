# Virtual Server Instance (VSI) image selector module

This Terraform module retrieves the most recent IBM Cloud VPC image based on a specified operating system and architecture.

This module enables filtering of IBM Cloud images based on operating system and system architecture. It currently supports `ubuntu` as the operating system and `amd64` or `s390x` as valid architecture options.

By applying semantic sorting to image names, the module identifies and returns the most recent image available. The resulting image ID and name can be seamlessly integrated into downstream resources such as virtual server instance provisioning. Refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images) for more information.

> Note: IBM Cloud image IDs are region-specific, so ensure that the provider block is configured with the correct region when consuming this module.

## Usage

```hcl

provider "ibm" {
  ibmcloud_api_key = "xxx123xxxxx" # Provide valid IBM Cloud API key # pragma: allowlist secret
  region           = "us-south" # Region for which images are fetched.
}

module "filtered_images" {
  providers = {
    ibm = ibm
  }
  source           = "terraform-ibm-modules/common-utilities/ibm//modules/vsi-image-selector"
  version          = "X.Y.Z" # Replace "X.Y.Z" to lock into a specific release
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
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.84.3, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_images.available_images](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/is_images) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Defines the target system architecture for image selection. The default is `amd64`. Valid options are `amd64` and `s390x`. | `string` | `"amd64"` | no |
| <a name="input_image_status"></a> [image\_status](#input\_image\_status) | Optional value to provide status of the image. | `string` | `null` | no |
| <a name="input_is_catalog_managed"></a> [is\_catalog\_managed](#input\_is\_catalog\_managed) | Flag to get images which are managed as part of a catalog offering. | `bool` | `false` | no |
| <a name="input_operating_system"></a> [operating\_system](#input\_operating\_system) | The operating system for image selection. Only `ubuntu` images are supported currently. | `string` | `"ubuntu"` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Defines the visibility level of the image. Accepted values are `public` and `private`. Defaults to `public`. | `string` | `"public"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_filtered_image_names"></a> [filtered\_image\_names](#output\_filtered\_image\_names) | List of image names that matches both the specified operating system and architecture. |
| <a name="output_latest_image_id"></a> [latest\_image\_id](#output\_latest\_image\_id) | Id of the most recent image matching the specified operating system and architecture. |
| <a name="output_latest_image_name"></a> [latest\_image\_name](#output\_latest\_image\_name) | Name of the most recent image matching the specified operating system and architecture. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
