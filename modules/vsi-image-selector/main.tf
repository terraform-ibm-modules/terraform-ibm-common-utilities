
########################################################################################################################
# Locals Block
########################################################################################################################

locals {

  # Filter images by OS, optional OS version, and architecture.
  filtered_arch_images = [
    for image in data.ibm_is_images.available_images.images : image
    if strcontains(lower(image.os), lower(var.operating_system)) &&
    lower(image.architecture) == var.architecture &&
    (
      var.operating_system_version == null ||
      strcontains(lower(image.name), lower(var.operating_system_version))
    )
  ]

  # Select the latest image from the filtered set by prioritizing the leading
  # operating system version components in the name, followed by later patch/build
  # numbers.
  image_name_parts = {
    for image in local.filtered_arch_images : image.name => regexall("[0-9]+", image.name)
  }

  sortable_image_keys = [
    for image in local.filtered_arch_images : format(
      "%s||%s",
      join(":", concat(
        [
          for index in range(4) : format(
            "%010d",
            try(tonumber(local.image_name_parts[image.name][index]), 0)
          )
        ],
        [
          for index in range(10) : format(
            "%010d",
            try(tonumber(local.image_name_parts[image.name][length(local.image_name_parts[image.name]) - 1 - index]), 0)
          )
        ]
      )),
      image.name
    )
  ]

  latest_image_name = split("||", sort(local.sortable_image_keys)[length(local.sortable_image_keys) - 1])[1]

  latest_image = one([
    for image in local.filtered_arch_images : image
    if image.name == local.latest_image_name
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
