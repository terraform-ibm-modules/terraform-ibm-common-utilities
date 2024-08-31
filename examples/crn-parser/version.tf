terraform {
  required_version = ">= 1.3.0"

  # As the CRN parser does not utilize the IBM Terraform provider, the provider does not need to be locked to any version
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.65.0"
    }
  }
}
