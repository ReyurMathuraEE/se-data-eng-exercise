# Define the GCS bucket resource
resource "google_storage_bucket_object" "content_folder" {
  name          = "reyur/"
  content       = "Not really a directory, but it's empty."
  bucket        = var.gcp_bucket
}