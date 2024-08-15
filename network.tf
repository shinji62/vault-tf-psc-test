//*************************************************************
// Network and Subnetwork
//*************************************************************
resource "google_compute_network" "main" {
  name                    = "${local.prefix}-${random_string.suffix.result}"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "main" {
  name          = "${local.prefix}-${random_string.suffix.result}"
  ip_cidr_range = "10.0.0.0/17"
  region        = "asia-northeast1"
  network       = google_compute_network.main.self_link

}
