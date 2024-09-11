########################################################################################################################
# Outputs
########################################################################################################################

output "parsed_crn_ctype" {
  value       = module.crn_parser.ctype
  description = "The parsed `ctype` field of the Key Protect instance CRN"
}

output "parsed_crn_service_name" {
  value       = module.crn_parser.service_name
  description = "The parsed `service_name` field of the Key Protect instance CRN"
}

output "parsed_crn_region" {
  value       = module.crn_parser.region
  description = "The parsed `region` field of the Key Protect instance CRN"
}

output "parsed_crn_scope" {
  value       = module.crn_parser.scope
  description = "The parsed `scope` field of the Key Protect instance CRN"
}

output "parsed_crn_service_instance" {
  value       = module.crn_parser.service_instance
  description = "The parsed `service_instance` field of the Key Protect instance CRN"
}

output "parsed_crn_resource_type" {
  value       = module.crn_parser.resource_type
  description = "The parsed `resource_type` field of the Key Protect instance CRN"
}

output "parsed_crn_resource" {
  value       = module.crn_parser.resource
  description = "The parsed `resource` field of the Key Protect instance CRN"
}
