##############################################################################
# Input Variables
##############################################################################

variable "region" {
  type        = string
  description = "The region in which you want to list the supported flavors of an ICD."
}

variable "icd_type" {
  type        = string
  description = "The type of the ICD (e.g. postgresql, mongodb)."
}
