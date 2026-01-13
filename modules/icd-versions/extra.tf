variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key to deploy resources."
  sensitive   = true
}


provider "ibm" {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.region
}