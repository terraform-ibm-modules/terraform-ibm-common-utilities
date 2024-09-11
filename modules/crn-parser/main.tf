/********************************************************************
This file is used to implement the ROOT module.
*********************************************************************/

locals {
  split_crn        = coalescelist(split(":", var.crn))
  ctype            = length(local.split_crn) > 3 ? local.split_crn[3] : null
  service_name     = length(local.split_crn) > 4 ? local.split_crn[4] : null
  region           = length(local.split_crn) > 5 ? local.split_crn[5] : null
  scope            = length(local.split_crn) > 6 ? local.split_crn[6] : null
  service_instance = length(local.split_crn) > 7 ? local.split_crn[7] : null
  resource_type    = length(local.split_crn) > 8 ? local.split_crn[8] : null
  resource         = length(local.split_crn) > 9 ? local.split_crn[9] : null
}
