variable "name" {}
variable "vm_size" {}

variable "diag_storage_name" {}
variable "diag_storage_primary_access_key" {}
variable "diag_storage_primary_blob_endpoint" {}

variable "admin_username" {
  default = "azureuser"
}

variable "paas_username" {
  default = "azureuser"
}

variable "cloud_config" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "availability_set_id" {
  type = "string"
}

variable "subnet_id" {
  type = "string"
}

variable "storage_type" {}

variable "tags" {
  type = "map"
}

variable "ssh_key" {}

variable "ssh_port" {
  default = "22"
}
