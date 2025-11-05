########################################################################################################################
# Outputs
########################################################################################################################

output "latest_image_name_by_os_and_architecture" {
  value       = module.image_lookup.latest_image_name_by_os_and_architecture
  description = "The name of the most recent image."
}
