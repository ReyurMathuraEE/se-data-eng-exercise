variable "snowflake_account" {
  description = "Snowflake account"
  type        = string
}

variable "snowflake_username" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake password"
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "Snowflake role"
  type        = string
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse"
  type        = string
}

variable "snowflake_database" {
  description = "Snowflake database"
  type        = string
}

variable "snowflake_schema" {
  description = "Snowflake schema"
  type        = string
}
