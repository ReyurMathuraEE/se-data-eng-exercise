# Provider configuration 
# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  project = "ee-india-se-data"
  region  = "US"
}

# Define the GCS bucket resource
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket_object" "content_folder" {
  name          = "reyur/"
  content       = "Not really a directory, but it's empty."
  bucket        = "ee-se-data-engg"
}
