# ICD Flavor Selector Example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=common-utilities-icd-flavor-selector-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-common-utilities/tree/main/examples/icd-flavor-selector">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->


This example demonstrates how to use the `icd-flavors` module to dynamically fetch available flavors for IBM Cloud Database services.

## Overview

The example shows how to:
- Fetch all available flavors for a specific ICD service and plan in a region
- Get the default/recommended flavor
- Use these values in your ICD deployments

## Usage

To run this example, you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.

## Example Output

```bash
$ terraform apply

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

available_flavors = [
  "4x20",
  "8x40",
  "8x80",
  "16x80",
  "32x160",
  "48x240"
]
default_flavor = "4x20"
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| ibm | >= 1.79.2, < 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ibmcloud_api_key | The IBM Cloud API Key | `string` | n/a | yes |
| region | Region where the ICD will be deployed | `string` | `"ca-mon"` | no |
| service | The ICD service name (e.g., databases-for-mongodb, databases-for-postgresql) | `string` | `"databases-for-mongodb"` | no |
| plan | The ICD plan (e.g., standard-gen2, enterprise-gen2) | `string` | `"standard-gen2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| available_flavors | List of all available flavors for the specified ICD service in the region |
| default_flavor | Default/recommended flavor for the specified ICD service |

## Using the Output in ICD Resources

You can use the output from this module in your ICD resource definitions:

```hcl
module "icd_flavors" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/icd-flavors"
  version = "X.Y.Z"
  service = "databases-for-mongodb"
  plan    = "standard-gen2"
  region  = "ca-mon"
}

resource "ibm_database" "mongodb_instance" {
  name              = "my-mongodb"
  plan              = "standard"
  location          = "ca-mon"
  service           = "databases-for-mongodb"
  version           = "6.0"

  group {
    group_id = "member"

    members {
      allocation_count = 3
    }

    # Use the default flavor from the module
    # Note: Flavor names from catalog need to be prefixed with the appropriate family
    # For Gen2 MongoDB, use "bx3d." prefix
    member_host_flavor = "bx3d.${module.icd_flavors.default_flavor}"
  }
}
```

## Notes

- This module is designed for Gen2 (VPC) ICD services
- The `service` parameter should be the ICD service name (e.g., `databases-for-mongodb`)
- The `plan` parameter should be the plan type (e.g., `standard-gen2`, `enterprise-gen2`)
- The module concatenates service and plan to form the catalog service name
- Requires network connectivity to IBM Cloud Global Catalog API
- The bash script requires `curl` and `jq` to be installed

## Available Service Names

Common Gen2 ICD service names include:
- `databases-for-mongodb`
- `databases-for-postgresql`
- `databases-for-redis`
- `databases-for-elasticsearch`
- `databases-for-etcd`
- `databases-for-rabbitmq`

## Available Plans

Common ICD plans include:
- `standard-gen2` - Standard Gen2 plan for VPC
- `enterprise-gen2` - Enterprise Gen2 plan for VPC
