##############################################################################
# Outputs
##############################################################################

output "available_flavors" {
  description = "List of all available flavors for the specified ICD type in the region"
  value       = module.icd_flavors.available_flavors
}

output "default_flavor" {
  description = "Default/recommended flavor for the specified ICD type"
  value       = module.icd_flavors.default_flavor
}
