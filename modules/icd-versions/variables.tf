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

variable "plan" {
  type        = string
  default     = ""
  nullable    = false
  description = "The plan for Gen2 databases (e.g., 'standard-gen2', 'enterprise-gen2'). Must end with '-gen2' suffix for Gen2 databases. Leave empty for Gen1. Note: For Gen2 databases, only the 'ca-mon' region is currently supported and only for PostgreSQL and MongoDB."

  validation {
    condition = (
      !endswith(lower(var.plan), "-gen2") ||
      trimspace(var.service) != ""
    )

    error_message = "For Gen2 databases (when 'plan' ends with '-gen2'), it is mandatory to provide values for both 'plan' and 'service'."
  }
}

variable "service" {
  type        = string
  default     = ""
  nullable    = false
  description = "The service name for Gen2 databases (e.g., 'databases-for-postgresql'). Required for Gen2 databases, leave empty for Gen1."
}
