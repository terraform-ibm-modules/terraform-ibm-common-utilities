########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# COS instance
########################################################################################################################

module "key_protect" {
  source            = "terraform-ibm-modules/key-protect/ibm"
  version           = "2.8.4"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  key_protect_name  = "${var.prefix}-kp"
  access_tags       = var.resource_tags
}

module "crn_parser" {
  source = "../../modules/crn-parser"
  crn    = module.key_protect.key_protect_crn
}
