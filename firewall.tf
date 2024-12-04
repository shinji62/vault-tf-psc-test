
//*************************************************************
// Firewall rule for IAP
//*************************************************************

resource "google_compute_firewall" "my_network" {
  name    = "my-network-firewall"
  network = google_compute_network.main.self_link

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["bastion-tag"]
  # https://cloud.google.com/iap/docs/using-tcp-forwarding#create-firewall-rule
  source_ranges = ["35.235.240.0/20", var.my-ip]

  # CloudLoggingにFlowLogログを出力したい場合は設定する
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
