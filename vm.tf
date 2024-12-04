//*************************************************************
// Bastion Host
//*************************************************************

resource "google_compute_instance" "my_instance" {
  name         = "${local.prefix}-instance"
  tags         = ["bastion-tag"]
  machine_type = "n1-standard-4"
  zone         = "asia-northeast1-a"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 100
    }
  }
  network_interface {
    network    = google_compute_network.main.self_link
    subnetwork = google_compute_subnetwork.main.self_link
    access_config {
      // Ephemeral IP
    }
  }
  metadata = {
    ssh-keys = "ubuntu:${file(var.path_to_public_key)}" 
  }
  allow_stopping_for_update = true
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
  depends_on = [google_compute_network.main]
}

resource "google_compute_attached_disk" "a_disk_tf" {
  disk     = google_compute_disk.disk_tf.id
  instance = google_compute_instance.my_instance.id
}

resource "google_compute_disk" "disk_tf" {
  name = "disk-1"
  size = 100
  zone = "asia-northeast1-a"
  type = "pd-ssd"
}
