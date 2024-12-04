# Description

This repository is used to test Cloud SQL with multitple configuration

Default behavior
With PSC
With Private IP

Terraform code also creeate a VM with a service account who can connect to all DB but by default GCP create those user without permission.

## GCP Account

### If you don't have a GCP account

First create a temporary account using doormat:

* Request a temporarly GCP Account **Accounts>GCP>Create Temporary Project**

Once the project is created, you need to login locally.
Make sure the gcloud cli is install in your laptop.

```
gcloud auth application-default login
```

## Run Terraform

Before running terraform you need to create a `terraform.tfvars` which contain the variable which are needed

For example :

```hcl
#Prefix to add to created resource - smaller is better
resource_prefix="pre-me"

#Your GCP project id
project_id="hc-....."

# Password use for the DB admin user
password="my-password"

# Your IP to be able to ssh into the deployed VM (should be with CIDR, for example 1.1.1.1/32)
my-ip="1.1.1.1/32"

# LOCAL Path to your ssh public kkey to ssh into the deployed VM
path_to_public_key="~/.ssh/my_public_key
```

Once login into GCP, you should be able to run Terraform

```shell
terraform plan
terraform apply
```

If you encounter the following error, just run `terraform apply` again

```shell
Error: Error, failed to insert user cloud-sql-postgres-sa@YOUR_GCP_PROJECT.iam into instance psc-enabled-main-instance: googleapi: Error 400: Invalid request: failed to create user "cloud-sql-postgres-sa@YOUR_GCP_PROJECT.iam": role "cloudsqliamserviceaccount" does not exist., invalid
```

## SSH into the VM

```shell
ssh -i ~/.ssh/your_private_key ubuntu@TF_OUPUT_OF_vm-public-ip
```

## Using with Vault

This use IAM authentification but by default GCP create those user without permission.
You need to add permission to the IAM user in those Database.


### MYSQL

Install MYSQL client on the VM

```shell
sudo apt install mysql-client-core-8.0
```

Normal Mysql with public ip

```shell
mysql -h TF_OUTPUT_normal-mysql-public-ip -u admin -p
GRANT SELECT, CREATE, CREATE USER ON *.* TO "cloud-sql-postgres-sa"@"%" WITH GRANT OPTION;
```

Normal Mysql with private ip

```shell
mysql -h TF_OUTPUT_privateip-mysql-ip -u admin -p
GRANT SELECT, CREATE, CREATE USER ON *.* TO "cloud-sql-postgres-sa"@"%" WITH GRANT OPTION;
```

MySQL with PSC

```shell
mysql -h TF_OUTPUT_psc-mysql-dns-name -u admin -p
GRANT SELECT, CREATE, CREATE USER ON *.* TO "cloud-sql-postgres-sa"@"%" WITH GRANT OPTION;
```

### Postgres

Install postgres client

```shell
sudo apt install postgresql-client-common
sudo apt install postgresql-client-12
```

Normal PSQL with public ip

Change `YOUR_GCP_PROJECT` with your gcp project id `hc-...`

```shell
psql -h TF_OUTPUT_normal-postgresql-public-ip -U admin -d postgres
ALTER USER "cloud-sql-postgres-sa@YOUR_GCP_PROJECT.iam" WITH CREATEROLE;
```

Normal PSQL with private ip

```shell
psql -h  TF_OUTPUT_privateip-postgresql-ip -U admin -d postgres
ALTER USER "cloud-sql-postgres-sa@YOUR_GCP_PROJECT.iam" WITH CREATEROLE;
```

PSQL with PSC

```shell
psql -h  TF_OUTPUT_psc-mysql-dns-name -U admin -d postgres
ALTER USER "cloud-sql-postgres-sa@YOUR_GCP_PROJECT.iam" WITH CREATEROLE;
```

## Vault

Vault need to be compile with the change and need to be run from the VM as we use the underlying GCP service account to connect to the DB

### Starting Vault

```shell
vault server -dev
```

## Testing Vault


### Enable secret Database engine
```
vault secrets enable database
```

### MYSQL

Normal MySQL

```shell
vault write database/config/my-mysql-database-normal \
    plugin_name="mysql-database-plugin" \
    allowed_roles="my-role-normal-mysql" \
    connection_url="cloud-sql-postgres-sa@cloudsql-mysql(TF_OUTPUT_OF_normal-mysql-connection-name)/mysql" \
    auth_type="gcp_iam" 

# Setup role    
vault write database/roles/my-role-normal-mysql \
    db_name=my-mysql-database-normal \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"

#Testing credentials
vault read database/creds/my-role-normal-mysql
#should return
Key                Value
---                -----
lease_id           database/creds/my-role-normal-mysql/wrGWUSSM7nne0qLGAsrmfZml
lease_duration     1h
lease_renewable    true
password           IHyp8-mcinUCmJ58KjGG
username           v-root-my-role-no-7WOnVsmnfMbIQk
```

MySQL with PrivateIP

```shell
vault write database/config/my-mysql-database-privip \
    plugin_name="mysql-database-plugin" \
    allowed_roles="my-role-mysql-privip" \
    connection_url="cloud-sql-postgres-sa@cloudsql-mysql(TF_OUTPUT_OF_privateip-mysql-connection-name)/mysql" \
    auth_type="gcp_iam" \
    use_private_ip=true

# Setup role    
vault write database/roles/my-role-mysql-privip \
    db_name=my-mysql-database-privip \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"

#Testing credentials
vault read database/creds/my-role-mysql-privip 
#Should return
Key                Value
---                -----
lease_id           database/creds/my-role-mysql-privip/AQY4C2h90M0npo6NXxJpEYxH
lease_duration     1h
lease_renewable    true
password           IQKIU-gALqMpSwdTCb9B
username           v-root-my-role-pr-JuqgEl2DkqkZgH
```

MySQL with PSC

```shell
vault write database/config/my-mysql-database-psc \
    plugin_name="mysql-database-plugin" \
    allowed_roles="my-role-mysql-psc" \
    connection_url="cloud-sql-postgres-sa@cloudsql-mysql(TF_OUTPUT_OF_psc-mysql-connection-name)/mysql" \
    auth_type="gcp_iam" \
    use_psc=true

# Setup role    
vault write database/roles/my-role-mysql-psc \
    db_name=my-mysql-database-psc \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"

#Testing credentials
vault read database/creds/my-role-mysql-psc 

#Shoulld return 
Key                Value
---                -----
lease_id           database/creds/my-role-mysql-psc/PDODJinMmqffIXvCTaWBFfXw
lease_duration     1h
lease_renewable    true
password           yutZTIxR-0QF4bxOmB7T
username           v-root-my-role-my-RFWG5ua4UclX6Z
```

### POSTGRES

Change `YOUR_GCP_PROJECT` with your gcp project id `hc-...`

Normal Postgres

```shell
vault write database/config/my-postgresql-database-normal \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="my-role-psql-normal" \
    connection_url="host=TF_OUTPUT_OF_normal-postgresql-connection-name user=cloud-sql-postgres-sa@YOUR_GCP_PROJECT.iam dbname=postgres sslmode=disable" \
    auth_type="gcp_iam" 

# Setup role    
vault write database/roles/my-role-psql-normal \
    db_name=my-postgresql-database-normal \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

#Testing credentials
vault read database/creds/my-role-psql-normal

#Should return

Key                Value
---                -----
lease_id           database/creds/my-role-psql-normal/Rl5mo0ylXkJDav6ym19gWLnT
lease_duration     1h
lease_renewable    true
password           -RVAwyD4eINx0uILozOf
username           v-root-my-role--iflFUrj7OfoZPIC1rBcH-1733295245
```

Postgres with PrivateIP

```shell
vault write database/config/my-postgresql-database-privateip \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="my-role-psql-privateip" \
    connection_url="host=TF_OUTPUT_OF_privateip-postgresql-connection-name user=cloud-sql-postgres-sa@YOUR_GCP_PROJECT.iam dbname=postgres sslmode=disable" \
    auth_type="gcp_iam" \
    use_private_ip=true

# Setup role    
vault write database/roles/my-role-psql-privateip \
    db_name=my-postgresql-database-privateip \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

#Testing credentials
vault read database/creds/my-role-psql-privateip

#Should return
Key                Value
---                -----
lease_id           database/creds/my-role-psql-privateip/eaTSwih3C89XVptRKPvKVjzv
lease_duration     1h
lease_renewable    true
password           aI2-OcbA4UwK2tDovLGW
username           v-root-my-role--fGyDn8Cy1z8YLMGiFSn3-1733295046
```

Postgres with PSC

```shell
vault write database/config/my-postgresql-database-psc \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="my-role-psql-psc" \
    connection_url="host=TF_OUTPUT_OF_psc-postgresl-connection-name user=cloud-sql-postgres-sa@YOUR_GCP_PROJECT.iam dbname=postgres sslmode=disable" \
    auth_type="gcp_iam" \
    use_psc=true

# Setup role    
vault write database/roles/my-role-psql-psc \
    db_name=my-postgresql-database-psc \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

#Testing credentials
vault read database/creds/my-role-psql-psc 

#Shoulld return 
Key                Value
---                -----
lease_id           database/creds/my-role-psql-psc/EGSnX6bDr1h88SMWlPoPhITc
lease_duration     1h
lease_renewable    true
password           P7M-OcXHM4O-Sooi0Dg4
username           v-root-my-role--6Mmsz1Y97NxSTlCLy4bC-1733294915
```
