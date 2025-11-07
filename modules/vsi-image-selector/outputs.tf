########################################################################################################################
# Outputs
########################################################################################################################

output "filtered_image_names" {
  value       = [for img in local.filtered_arch_images : img.name]
  description = "List of image names that matches both the specified operating system and architecture."
}

output "latest_image_id" {
  value       = local.latest_image.id
  description = "Id of the most recent image matching the specified operating system and architecture."
}

output "latest_image_name" {
  value       = local.latest_image.name
  description = "Name of the most recent image matching the specified operating system and architecture."
}

########################################################################################################################
