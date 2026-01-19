##############################################################################
# Outputs
##############################################################################

output "supported_versions" {
  description = "List of supported versions of the ICD"
  value       = module.icd_version_lister.supported_versions
}

output "latest_version" {

  description = "Latest supported version of the ICD"
  value       = module.icd_version_lister.latest_version
}

output "preferred_version" {
  description = "Preferred version of the ICD"
  value       = module.icd_version_lister.preferred_version
}
