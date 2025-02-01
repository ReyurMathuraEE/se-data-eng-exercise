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