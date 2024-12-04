variable "resource_prefix" {
  description = "prefix to add to created resource - smaller is better"
  type        = string
  default     = "gwenn"
}

variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "password" {
  description = "password use for the DB admin user"
  type        = string
}

variable "my-ip" {
  description = "your IP to be able to ssh into the deployed VM (should be with CIDR)"
  type        = string
}

variable "path_to_public_key" {
  description = "local path to your ssh public key to ssh into the deployed VM"
  type        = string
}
