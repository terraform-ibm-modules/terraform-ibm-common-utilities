########################################################################################################################
# Input Variables
########################################################################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud API Key."
  sensitive   = true
  type        = string
}

variable "region" {
  description = "Regin to get the image information as VPC infrastructure services are a regional specific based endpoint"
  type        = string
  default     = "au-syd"
}

variable "architecture" {
  description = "The architecture for which the image is to be fetched. Defaults to `amd64`."
  type        = string
  default     = "amd64"
}

variable "operating_system" {
  description = "The operating system for image selection. Only `ubuntu` images are supported currently."
  type        = string
  default     = "ubuntu"
}
