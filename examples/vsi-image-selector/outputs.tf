########################################################################################################################
# Outputs
########################################################################################################################

output "filtered_image_names" {
  value       = module.image_lookup.filtered_image_names
  description = "List of all image names."
}

output "latest_image_id" {
  value       = module.image_lookup.latest_image_id
  description = "Id of the most recent image."
}

output "latest_image_name" {
  value       = module.image_lookup.latest_image_name
  description = "Name of the most recent image."
}
