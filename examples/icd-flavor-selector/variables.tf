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
  description = "The ICD service name (e.g., databases-for-mongodb, databases-for-postgresql)."
  default     = "databases-for-mongodb"
}

variable "plan" {
  type        = string
  description = "The ICD plan (e.g., standard-gen2, enterprise-gen2)."
  default     = "standard-gen2"
}
