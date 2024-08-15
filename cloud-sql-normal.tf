//***********************************************************************************************
// This file is used to create a Cloud SQL instance with private IP enabled.
//***********************************************************************************************


//***********************************************************************************************
// Create Peering with Google Services
//***********************************************************************************************




resource "google_sql_database_instance" "mysql_normal" {

  name                = "private-instance-mysql-normal"
  database_version    = "MYSQL_8_0"
  deletion_protection = false



  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
    ip_configuration {
      authorized_networks {
        name  = google_compute_instance.my_instance.name
        value = google_compute_instance.my_instance.network_interface.0.access_config.0.nat_ip
      }
    }
  }
}


resource "google_sql_user" "iam_service_account_user_mysql_normal" {
  name     = google_service_account.default.email
  instance = google_sql_database_instance.mysql_normal.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}


resource "google_sql_user" "admin_password_mysql_normal" {
  name     = "admin"
  instance = google_sql_database_instance.mysql_normal.name
  password = var.password
}




resource "google_sql_database_instance" "postgresql_normal" {

  name                = "private-instance-postgresql-normal"
  database_version    = "POSTGRES_15"
  deletion_protection = false



  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
    ip_configuration {
      authorized_networks {
        name  = google_compute_instance.my_instance.name
        value = google_compute_instance.my_instance.network_interface.0.access_config.0.nat_ip
      }
    }

  }

}

resource "google_sql_user" "iam_service_account_user_postgresql_normal" {
  # Note: for PostgreSQL only, Google Cloud requires that you omit the
  # ".gserviceaccount.com" suffix
  # from the service account email due to length limits on database usernames.
  name     = trimsuffix(google_service_account.default.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.postgresql_normal.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}


resource "google_sql_user" "admin_password_postgresql_normal" {
  name     = "admin"
  instance = google_sql_database_instance.postgresql_normal.name
  password = var.password
}
