data "ibm_iam_auth_token" "tokendata" {}

# Fetch ICD flavors
data "external" "icd_flavors" {
  program = ["bash", "${path.module}/scripts/get_icd_flavors.sh"]
  query = {
    IAM_TOKEN = sensitive(data.ibm_iam_auth_token.tokendata.iam_access_token)
    REGION    = var.region
    DB_TYPE   = var.icd_type
  }

  lifecycle {
    postcondition {
      condition     = length(jsondecode(self.result["flavors"])) > 0
      error_message = "No flavors found for ICD ${var.icd_type} in region ${var.region}."
    }
  }
}

locals {
  # Parse the list of flavors from the external data source
  # The script returns a JSON string, so we need to decode it first
  icd_flavors_json      = data.external.icd_flavors.result["flavors"]
  icd_available_flavors = jsondecode(local.icd_flavors_json)

  icd_default_flavor = data.external.icd_flavors.result["default_flavor"]
}
