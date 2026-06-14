##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region where the ICD will be deployed"
  default     = "ca-mon"
}

variable "icd_type" {
  type        = string
  description = "The type of ICD service (e.g., mongodb, redis, postgresql)"
  default     = "mongodb"
}
