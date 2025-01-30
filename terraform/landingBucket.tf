# Provider configuration 
# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  project = "ee-india-se-data"
  region  = "US"
}

# Define the GCS bucket resource
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "landing_bucket" {
  name                        = "ee-se-data-engg/reyur"
  location                    = "us-central1"
  storage_class               = "STANDARD"
  force_destroy               = false

  # Manage access to objects in bucket at global level
  uniform_bucket_level_access = true
}

# Define IAM policy bindings to make the bucket private
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam
resource "google_storage_bucket_iam_binding" "no_public_access" {
  bucket = google_storage_bucket.landing_bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "projectOwner:ee-india-se-data"
  ]
}
