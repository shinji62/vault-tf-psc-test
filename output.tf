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

output "privateip-postgresql-ip" {
  value = google_sql_database_instance.postgresql_privateip.private_ip_address
}

output "privateip-mysql-connection-name" {
  value = google_sql_database_instance.mysql_privateip.connection_name
}

output "privateip-mysql-ip" {
  value = google_sql_database_instance.mysql_privateip.private_ip_address
}

output "normal-postgresql-connection-name" {
  value = google_sql_database_instance.postgresql_normal.connection_name
}

output "normal-postgresql-public-ip" {
  value = google_sql_database_instance.postgresql_normal.public_ip_address
}

output "normal-mysql-connection-name" {
  value = google_sql_database_instance.mysql_normal.connection_name
}

output "normal-mysql-public-ip" {
  value = google_sql_database_instance.mysql_normal.public_ip_address
}


output "vm-public-ip" {
  value = google_compute_instance.my_instance.network_interface.0.access_config.0.nat_ip
}
