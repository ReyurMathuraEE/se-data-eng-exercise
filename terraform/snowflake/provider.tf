terraform {
  required_providers {
    snowflake = {
      source = "Snowflake-Labs/snowflake"
    }
  }
}

provider "snowflake" {
  account   = var.snowflake_account
  username  = var.snowflake_username
  password  = var.snowflake_password
  role      = var.snowflake_role
  warehouse = var.snowflake_warehouse
  region    = var.snowflake_region
  database  = var.snowflake_database
  schema    = var.snowflake_schema
}
