//***********************************************************************************************
// This file is used to create a Cloud SQL instance with private IP enabled.
//***********************************************************************************************


//***********************************************************************************************
// Create a Global Ip address network
//***********************************************************************************************
resource "google_compute_global_address" "private_ip_address_peering" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}


//***********************************************************************************************
// Create Peering with Google Services
//***********************************************************************************************

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address_peering.name]
}


resource "google_sql_database_instance" "mysql_privateip" {

  name                = "private-instance-mysql-privateip"
  database_version    = "MYSQL_8_0"
  deletion_protection = false


  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.main.self_link
      enable_private_path_for_google_cloud_services = true
    }
  }
}


resource "google_sql_user" "iam_service_account_user_mysql_privateip" {
  name     = google_service_account.default.email
  instance = google_sql_database_instance.mysql_privateip.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}


resource "google_sql_user" "admin_password_mysql_privateip" {
  name     = "admin"
  instance = google_sql_database_instance.mysql_privateip.name
  password = var.password
}




resource "google_sql_database_instance" "postgresql_privateip" {

  name                = "private-instance-postgresql-privateip"
  database_version    = "POSTGRES_15"
  deletion_protection = false


  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.main.self_link
      enable_private_path_for_google_cloud_services = true
    }
  }
}

resource "google_sql_user" "iam_service_account_user_postgresql_privateip" {
  # Note: for PostgreSQL only, Google Cloud requires that you omit the
  # ".gserviceaccount.com" suffix
  # from the service account email due to length limits on database usernames.
  name     = trimsuffix(google_service_account.default.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.postgresql_privateip.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}


resource "google_sql_user" "admin_password_postgresql_privateip" {
  name     = "admin"
  instance = google_sql_database_instance.postgresql_privateip.name
  password = var.password
}