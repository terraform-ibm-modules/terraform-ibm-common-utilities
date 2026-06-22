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

variable "service" {
  type        = string
  description = "The catalog service name for the ICD (e.g., databases-for-mongodb-standard-gen2)"
  default     = "databases-for-mongodb-standard-gen2"
}
