terraform {
  required_providers {
    snowflake = {
      source = "Snowflake-Labs/snowflake"
    }
  }
}

provider "snowflake" {
  organization_name = var.TF_VAR_organization_name
  account_name      = var.TF_VAR_account_name
  user              = var.TF_VAR_user
  password          = var.TF_VAR_password

  preview_features_enabled = ["snowflake_table_resource"]
}
