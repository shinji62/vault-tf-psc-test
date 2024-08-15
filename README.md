# Description

This repository is used to test Cloud SQL with multitple configuration

Default behavior
With PSC
With Private IP

Terraform code also creeate a VM with a service account who can connect to all DB but by default GCP create those user without permission.

# Using with Vault
This use IAM authentification but by default GCP create those user without permission.
You need to add permission to the IAM user in those Database.

1- Ssh to the VM (use Google browser ssh)
2- You can connect using using normal `psql` or `mysql` client using the admin user and password (TF variable)
3- Then add permission to tthe user

Mysql
```
GRANT SELECT, CREATE, CREATE USER ON *.* TO "cloud-sql-postgres-sa"@"%" WITH GRANT OPTION;
```

Postgres
```
ALTER USER "cloud-sql-postgres-sa@YOUR_GCP_PROJECT.iam" WITH CREATEROLE;
```

## Setuping Vault

Enable secret Database engine
```
vault secrets enable database
```

Postgres with PSC
```
vault write database/config/my-postgresql-database-psc \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="my-role" \
    connection_url="host=TF_OUTPUT_OF_psc-postgresl-connection-name user=cloud-sql-postgres-sa@sej-tools-hashicorp.iam dbname=postgres sslmode=disable" \
    auth_type="gcp_iam" \
    use_psc=true
```

Postgres with PrivateIP
```
vault write database/config/my-postgresql-database-privateip \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="my-role" \
    connection_url="host=TF_OUTPUT_OF_privateip-postgresql-connection-name user=cloud-sql-postgres-sa@sej-tools-hashicorp.iam dbname=postgres sslmode=disable" \
    auth_type="gcp_iam" \
    use_private_ip=true
```


Postgres without options
```
vault write database/config/my-postgresql-database-normal \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="my-role" \
    connection_url="host=TF_OUTPUT_OF_normal-postgresql-connection-name user=cloud-sql-postgres-sa@sej-tools-hashicorp.iam dbname=postgres sslmode=disable" \
    auth_type="gcp_iam" 
```


MySQL with PSC
```
vault write database/config/my-mysql-database-psc \
    plugin_name="mysql-database-plugin" \
    allowed_roles="my-role" \
    connection_url="cloud-sql-postgres-sa@cloudsql-mysql(TF_OUTPUT_OF_psc-mysql-connection-name)/mysql" \
    auth_type="gcp_iam" \
    use_psc=true
```

MySQL with PrivateIP
```
vault write database/config/my-mysql-database-privip \
    plugin_name="mysql-database-plugin" \
    allowed_roles="my-role" \
    connection_url="cloud-sql-postgres-sa@cloudsql-mysql(TF_OUTPUT_OF_privateip-mysql-connection-name)/mysql" \
    auth_type="gcp_iam" \
    use_private_ip=true
```

MySQL default
```
vault write database/config/my-mysql-database-normal \
    plugin_name="mysql-database-plugin" \
    allowed_roles="my-role" \
    connection_url="cloud-sql-postgres-sa@cloudsql-mysql(TF_OUTPUT_OF_normal-mysql-connection-name)/mysql" \
    auth_type="gcp_iam" 
```