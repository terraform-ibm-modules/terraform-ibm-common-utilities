##############################################################################
# Outputs
##############################################################################

output "supported_versions" {
  description = "List of supported versions of the ICD"
  value       = local.icd_supported_versions
}

output "latest_version" {

  description = "Latest supported version of the ICD"
  value       = local.icd_latest_version
}

output "preferred_version" {
  description = "Preferred version of the ICD"
  value       = local.icd_preferred_version
}
