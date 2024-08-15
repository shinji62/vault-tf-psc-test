output "psc-postgresl-connection-name" {
  value = google_sql_database_instance.main.connection_name
}

output "psc-postgresl-dns-name" {
  value = google_sql_database_instance.main.dns_name
}

output "psc-mysql-connection-name" {
  value = google_sql_database_instance.mysql.connection_name
}

output "psc-mysql-dns-name" {
  value = google_sql_database_instance.mysql.dns_name
}



output "privateip-postgresql-connection-name" {
  value = google_sql_database_instance.postgresql_privateip.connection_name
}

output "privateip-postgresql-dns-name" {
  value = google_sql_database_instance.postgresql_privateip.dns_name
}

output "privateip-mysql-connection-name" {
  value = google_sql_database_instance.mysql_privateip.connection_name
}

output "privateip-mysql-dns-name" {
  value = google_sql_database_instance.mysql_privateip.dns_name
}

output "normal-postgresql-connection-name" {
  value = google_sql_database_instance.postgresql_normal.connection_name
}

output "normal-postgresql-dns-name" {
  value = google_sql_database_instance.postgresql_normal.dns_name
}

output "normal-mysql-connection-name" {
  value = google_sql_database_instance.mysql_normal.connection_name
}

output "normal-mysql-dns-name" {
  value = google_sql_database_instance.mysql_normal.dns_name
}
