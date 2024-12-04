//*************************************************************
// Create Managed Zone for Cloud SQL
//*************************************************************

resource "google_dns_managed_zone" "sql" {
  name       = "cloud-sql"
  dns_name   = "${local.region}.sql.goog."
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.main.id

    }
  }
  depends_on = [google_compute_instance.my_instance]
}


//*************************************************************
// Create SQL User for Service Account
//*************************************************************

resource "google_sql_user" "iam_service_account_user" {
  # Note: for PostgreSQL only, Google Cloud requires that you omit the
  # ".gserviceaccount.com" suffix
  # from the service account email due to length limits on database usernames.
  name     = trimsuffix(google_service_account.default.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.main.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}


resource "google_sql_user" "admin_password" {
  name     = "admin"
  instance = google_sql_database_instance.main.name
  password = var.password
}

//*************************************************************
// Create Cloud SQL Instance with PSC Enabled
//*************************************************************
resource "google_sql_database_instance" "main" {
  name                = "psc-enabled-main-instance"
  database_version    = "POSTGRES_15"
  deletion_protection = false
  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
    ip_configuration {
      psc_config {
        psc_enabled = true
        allowed_consumer_projects = [
          data.google_client_config.default.project
        ]
      }
      ipv4_enabled = false
    }
    backup_configuration {
      enabled = false
    }
    availability_type = "REGIONAL"
  }
}

//*************************************************************
// Reserve Internal IP Address for PSC to Consumer
//*************************************************************
resource "google_compute_address" "psc-to-consumer" {
  name         = "${local.prefix}-psc-to-consumer"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.main.self_link
}

//*************************************************************
// Create Service Attachment for PSC
//*************************************************************
resource "google_compute_forwarding_rule" "psc" {
  name                  = "${local.prefix}-psc"
  target                = google_sql_database_instance.main.psc_service_attachment_link
  load_balancing_scheme = "" # need to override EXTERNAL default when target is a service attachment
  network               = google_compute_network.main.self_link
  ip_address            = google_compute_address.psc-to-consumer.id
}


locals {
  split_connection_name = split(".", google_sql_database_instance.main.dns_name)
  instance_uid          = local.split_connection_name[0]
  dns_label             = local.split_connection_name[1]
  region                = local.split_connection_name[2]
}


//*************************************************************
// Create DNS Record Set for Cloud SQL
//*************************************************************
resource "google_dns_record_set" "psc" {
  name         = google_sql_database_instance.main.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.sql.name
  rrdatas      = [google_compute_address.psc-to-consumer.address]
}

//*************************************************************
// MYSQL
//*************************************************************

resource "google_sql_user" "iam_service_account_user_mysql" {
  # Note: for PostgreSQL only, Google Cloud requires that you omit the
  # ".gserviceaccount.com" suffix
  # from the service account email due to length limits on database usernames.
  name     = google_service_account.default.email
  instance = google_sql_database_instance.mysql.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}


resource "google_sql_user" "admin_password_mysql" {
  name     = "admin"
  instance = google_sql_database_instance.mysql.name
  password = var.password
}

//*************************************************************
// Create Cloud SQL Instance with PSC Enabled
//*************************************************************
resource "google_sql_database_instance" "mysql" {
  name                = "psc-enabled-mysql-instance"
  database_version    = "MYSQL_8_0"
  deletion_protection = false
  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
    ip_configuration {
      psc_config {
        psc_enabled = true
        allowed_consumer_projects = [
          data.google_client_config.default.project
        ]
      }
      ipv4_enabled = false
    }
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }
    availability_type = "REGIONAL"
  }
}

//*************************************************************
// Reserve Internal IP Address for PSC to Consumer
//*************************************************************
resource "google_compute_address" "psc-to-consumer-mysql" {
  name         = "${local.prefix}-psc-to-consumer-mysql"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.main.self_link
}

//*************************************************************
// Create Service Attachment for PSC
//*************************************************************
resource "google_compute_forwarding_rule" "psc-mysql" {
  name                  = "${local.prefix}-psc-mysql"
  target                = google_sql_database_instance.mysql.psc_service_attachment_link
  load_balancing_scheme = "" # need to override EXTERNAL default when target is a service attachment
  network               = google_compute_network.main.self_link
  ip_address            = google_compute_address.psc-to-consumer-mysql.id
}


locals {
  split_connection_name_mysql = split(".", google_sql_database_instance.mysql.dns_name)
  instance_uid_mysql          = local.split_connection_name_mysql[0]
  dns_label_mysql             = local.split_connection_name_mysql[1]
  region_mysql                = local.split_connection_name_mysql[2]
}


//*************************************************************
// Create DNS Record Set for Cloud SQL
//*************************************************************
resource "google_dns_record_set" "psc_mysql" {
  name         = google_sql_database_instance.mysql.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.sql.name
  rrdatas      = [google_compute_address.psc-to-consumer-mysql.address]
}
