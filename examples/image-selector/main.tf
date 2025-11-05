/********************************************************************
This file is used to implement the ROOT module.
*********************************************************************/

module "image_lookup" {
  source           = "../../modules/image-selector"
  architecture     = var.architecture
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}
