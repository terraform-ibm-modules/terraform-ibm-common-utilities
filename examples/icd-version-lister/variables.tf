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
  default     = "us-south"
}

variable "icd_type" {
  type        = string
  description = "The type of the ICD."
}

variable "plan" {
  type        = string
  default     = ""
  nullable    = false
  description = "The plan for Gen2 databases (e.g., 'standard-gen2', 'enterprise-gen2'). Must end with '-gen2' suffix for Gen2 databases. Leave empty for Gen1."
}

variable "service" {
  type        = string
  default     = ""
  nullable    = false
  description = "The service name for Gen2 databases (e.g., 'databases-for-postgresql'). Required for Gen2 databases, leave empty for Gen1."
}
