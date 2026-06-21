##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud API Key."
  sensitive   = true
  type        = string
}

variable "region" {
  type        = string
  description = "The region in which you want to list the supported versions of an ICD."
}
