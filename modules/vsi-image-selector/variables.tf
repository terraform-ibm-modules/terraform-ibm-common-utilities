########################################################################################################################
# Input Variables
########################################################################################################################

variable "visibility" {
  description = "Defines the visibility level of the image. Accepted values are `public` and `private`. Defaults to `public`."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["private", "public"], var.visibility)
    error_message = "Image visibility can be either public or private."
  }
}

variable "image_status" {
  description = "Optional value to provide status of the image."
  type        = string
  default     = null

  validation {
    condition     = var.image_status == null ? true : contains(["available", "deleting", "deprecated", "failed", "obsolete", "pending", "unusable"], var.image_status)
    error_message = "If provided, the image status can be one of - available, deleting, deprecated, failed, obsolete, pending or unusable."
  }
}

variable "architecture" {
  description = "Defines the target system architecture for image selection. The default is `amd64`. Valid options are `amd64` and `s390x`."
  type        = string
  default     = "amd64"

  validation {
    condition     = contains(["amd64", "s390x"], var.architecture)
    error_message = "Architecture values can be either amd64 or s390x."
  }
}

variable "operating_system" {
  description = "The operating system for image selection. Only `ubuntu` images are supported currently."
  type        = string
  default     = "ubuntu"

  validation {
    condition     = var.operating_system == "ubuntu"
    error_message = "Only 'ubuntu' is supported as a valid operating system."
  }
}

variable "is_catalog_managed" {
  description = "Flag to get images which are managed as part of a catalog offering."
  type        = bool
  default     = false
}

########################################################################################################################
