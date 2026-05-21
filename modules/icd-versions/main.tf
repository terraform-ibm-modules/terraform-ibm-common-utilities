resource "terraform_data" "install_python_requirements" {
  count = var.auto_install_dependencies ? 1 : 0
  triggers_replace = {
    requirements_hash = filemd5("${path.module}/scripts/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<-EOT
      python3 -c "import requests" 2>/dev/null || python3 -m pip install --user -q -r ${path.module}/scripts/requirements.txt
    EOT
  }
}

data "ibm_iam_auth_token" "tokendata" {}

data "external" "icd_versions" {
  depends_on = [terraform_data.install_python_requirements]

  program = ["python3", "${path.module}/scripts/get_icd_versions.py"]
  query = {
    IAM_TOKEN = sensitive(data.ibm_iam_auth_token.tokendata.iam_access_token)
    REGION    = var.region
    DB_TYPE   = var.icd_type
  }

  lifecycle {
    postcondition {
      condition     = length(jsondecode(self.result["versions"])) > 0
      error_message = "No supported versions found for ICD ${var.icd_type}."
    }
  }
}



locals {
  # Parse the list of versions from the external data source
  # The script returns a JSON string, so we need to decode it first
  icd_supported_versions_json = data.external.icd_versions.result["versions"]
  icd_supported_versions      = jsondecode(local.icd_supported_versions_json)

  icd_preferred_version = data.external.icd_versions.result["preferred_version"]
  icd_latest_version    = data.external.icd_versions.result["latest_version"]
}
