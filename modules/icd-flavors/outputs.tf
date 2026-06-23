##############################################################################
# Outputs
##############################################################################

output "available_flavors" {
  description = "List of available flavors for the ICD"
  value       = local.icd_available_flavors
}

output "default_flavor" {
  description = "Default/recommended flavor for the ICD"
  value       = local.icd_default_flavor
}
