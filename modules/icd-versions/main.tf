data "ibm_iam_auth_token" "tokendata" {}

data "external" "icd_versions" {
  program = ["python3", "${path.module}/scripts/get_icd_versions.py"]
  query = {
    IAM_TOKEN = sensitive(data.ibm_iam_auth_token.tokendata.iam_access_token)
    REGION    = var.region
    DB_TYPE   = var.icd_type
  }
}



locals {
  # Parse the list of versions from the external data source
  # The script returns a JSON string, so we need to decode it first
  icd_supported_versions_json = data.external.icd_versions.result["versions"]
  icd_supported_versions      = jsondecode(local.icd_supported_versions_json)

  icd_preferred_version       = data.external.icd_versions.result["preferred_version"]
  icd_latest_version          = data.external.icd_versions.result["latest_version"]
}