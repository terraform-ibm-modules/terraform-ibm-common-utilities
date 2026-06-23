##############################################################################
# Input Variables
##############################################################################

variable "region" {
  type        = string
  description = "The region in which you want to list the supported flavors of an ICD."
}

variable "service" {
  type        = string
  description = "The ICD service name (e.g., databases-for-mongodb, databases-for-postgresql)."
}

variable "plan" {
  type        = string
  description = "The ICD plan (e.g., standard-gen2, enterprise-gen2)."
  default     = "standard-gen2"
}
