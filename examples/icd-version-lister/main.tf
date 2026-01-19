module "icd_version_lister" {
  source   = "../../modules/icd-versions"
  region   = var.region
  icd_type = var.icd_type
}
