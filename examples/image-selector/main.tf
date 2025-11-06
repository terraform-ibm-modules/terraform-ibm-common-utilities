module "image_lookup" {
  providers = {
    ibm = ibm
  }
  source           = "../../modules/image-selector"
  architecture     = var.architecture
  operating_system = var.operating_system
}
