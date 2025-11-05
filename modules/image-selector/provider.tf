########################################################################################################################
# Provider config
########################################################################################################################

/*
As the image IDs differ per region so provider region usage 
is very important to get correct results.
*/

provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}