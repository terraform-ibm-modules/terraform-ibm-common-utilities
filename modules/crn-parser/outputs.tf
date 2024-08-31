########################################################################################################################
# Outputs
########################################################################################################################

output "ctype" {
  value       = local.ctype == "" ? null : local.ctype
  description = "CRN `ctype` field"
}

output "service_name" {
  value       = local.service_name == "" ? null : local.service_name
  description = "CRN `service_name` field"
}

output "region" {
  value       = local.region == "" ? null : local.region
  description = "CRN `region` field"
}

output "scope" {
  value       = local.scope == "" ? null : local.scope
  description = "CRN `scope` field"
}

output "service_instance" {
  value       = local.service_instance == "" ? null : local.service_instance
  description = "CRN `service_instance` field"
}

output "resource_type" {
  value       = local.resource_type == "" ? null : local.resource_type
  description = "CRN `resource_type` field"
}

output "resource" {
  value       = local.resource == "" ? null : local.resource
  description = "CRN `resource` field"
}
