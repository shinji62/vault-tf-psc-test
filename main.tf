
data "google_client_config" "default" {}

locals {
  prefix = var.resource_prefix
  gcp_service_list = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "iamcredentials.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "sqladmin.googleapis.com",
    "servicedirectory.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}


resource "google_project_service" "services" {
  count   = length(local.gcp_service_list)
  service = local.gcp_service_list[count.index]
}
