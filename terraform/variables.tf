variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "ee-india-se-data"
}

variable "gcp_region" {
  description = "GCP region for the bucket"
  type        = string
  default     = "US"
}

variable "gcp_bucket" {
  description = "GCP bucket name"
  type        = string
  default     = "ee-se-data-engg"
}

variable "user" {
    type = string
}

variable "organization_name" {
    type = string
}

variable "account_name" {
    type = string
}

variable "password" {
    type = string
}

variable "database" {
    type = string
}

variable "schema" {
    type = string
}

variable "private_key" {
    type = string
}