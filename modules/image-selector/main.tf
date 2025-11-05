
########################################################################################################################
# Locals Block
########################################################################################################################

locals {

  # Filter images by OS only.
  os_images = [
    for image in data.ibm_is_images.available_images.images : image
    if strcontains(lower(image.os), var.operating_system)
  ]

  # Filter images by architecture only.
  arch_images = [
    for image in data.ibm_is_images.available_images.images : image
    if strcontains(lower(image.name), var.architecture)
  ]

  # Filter images by both OS and architecture.
  filtered_arch_images = [
    for image in data.ibm_is_images.available_images.images : image
    if strcontains(lower(image.os), var.operating_system) &&
    strcontains(lower(image.name), var.architecture)
  ]

  # Sort by image name
  sorted_names = sort([for image in local.filtered_arch_images : image.name])
  latest_name  = local.sorted_names[length(local.sorted_names) - 1]

  latest_image = one([
    for image in local.filtered_arch_images : image
    if image.name == local.latest_name
  ])
}

########################################################################################################################
# Data Source
########################################################################################################################

data "ibm_is_images" "available_images" {
  status          = var.image_status
  visibility      = var.visibility
  catalog_managed = var.is_catalog_managed
}

########################################################################################################################
