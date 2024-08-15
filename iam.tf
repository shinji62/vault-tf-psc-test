
//*************************************************************
// Create Service Account for Cloud SQL
//*************************************************************
resource "google_service_account" "default" {
  account_id   = "cloud-sql-postgres-sa"
  display_name = "Cloud SQL for Postgres Service Account"
}


resource "google_project_iam_binding" "cloud_sql_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  members = [
    "serviceAccount:${google_service_account.default.email}"
  ]
}

resource "google_project_iam_binding" "cloud_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  members = [
    "serviceAccount:${google_service_account.default.email}"
  ]
}
