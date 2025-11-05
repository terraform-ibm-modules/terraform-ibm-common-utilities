########################################################################################################################
# Outputs
########################################################################################################################

output "filtered_image_names_by_os" {
  value       = [for img in local.os_images : img.name]
  description = "List of image names available for the specified operating system."
}

output "filtered_image_names_by_architecture" {
  value       = [for img in local.arch_images : img.name]
  description = "List of image names matching the specified system architecture."
}

output "filtered_image_names_by_os_and_architecture" {
  value       = [for img in local.filtered_arch_images : img.name]
  description = "List of image names that matches both the specified operating system and architecture."
}

output "latest_image_id_by_os_and_architecture" {
  value       = local.latest_image.id
  description = "Id of the most recent image matching the specified operating system and architecture."
}

output "latest_image_name_by_os_and_architecture" {
  value       = local.latest_image.name
  description = "Name of the most recent image matching the specified operating system and architecture."
}

########################################################################################################################