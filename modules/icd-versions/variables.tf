##############################################################################
# Input Variables
##############################################################################

variable "region" {
  type        = string
  description = "The region in which you want to list the supported versions of an ICD."
}

variable "icd_type" {
  type        = string
  description = "The type of the ICD."
}
