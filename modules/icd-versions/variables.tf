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


variable "auto_install_dependencies" {
  type        = bool
  description = "Set to true to automatically install Python dependencies (requests library). Set to false if dependencies are pre-installed in your environment."
  default     = true
}
