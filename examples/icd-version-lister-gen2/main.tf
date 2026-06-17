module "icd_version_lister" {
  source   = "../../modules/icd-versions"
  region   = var.region
  icd_type = "postgresql"
  plan     = "standard-gen2"
  service  = "databases-for-postgresql"
}
