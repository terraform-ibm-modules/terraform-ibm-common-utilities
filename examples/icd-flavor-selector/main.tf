##############################################################################
# ICD Flavor Selector Example
##############################################################################

module "icd_flavors" {
  source  = "../../modules/icd-flavors"
  service = var.service
  region  = var.region
}
