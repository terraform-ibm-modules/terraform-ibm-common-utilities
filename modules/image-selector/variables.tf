########################################################################################################################
# Input Variables
########################################################################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud API Key."
  sensitive   = true
  type        = string
}

variable "region" {
  description = "Region to get the image information as VPC infrastructure services are a regional specific based endpoint. Defaults to `us-south`."
  type        = string
  default     = "us-south"
}

variable "visibility" {
  description = "The visibility of the image. Defaults to `public`."
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
  description = "The architecture for which the image is to be fetched. Defaults to `amd64`."
  type        = string
  default     = "amd64"

  validation {
    condition     = contains(["amd64", "s390x"], var.architecture)
    error_message = "Architecture values can be either amd64 or s390x."
  }
}

variable "operating_system" {
  description = "The operating system for which the image id should be retrieved. Only ubuntu images are supported currently."
  type        = string
  default     = "ubuntu"
}

variable "is_catalog_managed" {
  description = "Flag to get images which are managed as part of a catalog offering."
  type        = bool
  default     = false
}

########################################################################################################################