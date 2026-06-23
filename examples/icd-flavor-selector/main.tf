##############################################################################
# ICD Flavor Selector Example
##############################################################################

module "icd_flavors" {
  source  = "../../modules/icd-flavors"
  service = var.service
  plan    = var.plan
  region  = var.region
}
