##############################################################################
# Input Variables
##############################################################################

variable "region" {
  type        = string
  description = "The region in which you want to list the supported flavors of an ICD."
}

variable "service" {
  type        = string
  description = "The catalog service name for the ICD (e.g., databases-for-mongodb-standard-gen2, databases-for-postgresql-standard-gen2)."
}
