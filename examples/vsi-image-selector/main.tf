module "image_lookup" {
  source           = "../../modules/vsi-image-selector"
  architecture     = var.architecture
  operating_system = var.operating_system
}
