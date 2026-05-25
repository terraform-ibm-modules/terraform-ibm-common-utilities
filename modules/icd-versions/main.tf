locals {
  python_deps_path = "/tmp"
}

# Ensure Python3 and pip are installed
data "external" "ensure_python_pip" {
  program = ["bash", "${path.module}/scripts/ensure-python-pip.sh", local.python_deps_path]
}

# Install Python packages from requirements.txt
data "external" "install_python_packages" {
  depends_on = [data.external.ensure_python_pip]

  program = ["bash", "${path.module}/scripts/install-packages.sh", local.python_deps_path]
}

data "ibm_iam_auth_token" "tokendata" {}

# Fetch ICD versions
data "external" "icd_versions" {
  depends_on = [data.external.install_python_packages]

  program = ["python3", "${path.module}/scripts/get_icd_versions.py", local.python_deps_path]
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
