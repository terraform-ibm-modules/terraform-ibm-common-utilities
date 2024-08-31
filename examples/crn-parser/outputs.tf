########################################################################################################################
# Outputs
########################################################################################################################

output "key_protect_crn" {
  value       = module.key_protect.key_protect_crn
  description = "The CRN of the Key Protect instance"
}

output "parsed_key_protect_crn" {
  value       = module.crn_parser
  description = "The parsed fields of the Key Protect instance CRN"
}
