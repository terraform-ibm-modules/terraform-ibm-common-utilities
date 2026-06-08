##############################################################################
# ICD Flavor Selector Example
##############################################################################

module "icd_flavors" {
  source   = "../../modules/icd-flavors"
  icd_type = var.icd_type
  region   = var.region
}
