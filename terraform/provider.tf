terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    snowflake = {
      source = "Snowflake-Labs/snowflake"
    }
  }
}

provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
}

provider "snowflake" {
  organization_name = var.organization_name
  account_name      = var.account_name
  user              = var.user
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = var.private_key

  preview_features_enabled = ["snowflake_table_resource"]
}
