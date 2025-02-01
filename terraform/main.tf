# Define the GCS bucket resource
resource "google_storage_bucket_object" "content_folder" {
  name          = "reyur/"
  content       = "Not really a directory, but it's empty."
  bucket        = var.gcp_bucket
}

resource "snowflake_table" "TAXI_TRIPS_RAW" {
  database = var.database
  schema   = var.schema
  sql      = <<SQL
    CREATE TABLE IF NOT EXISTS TAXI_TRIPS_RAW (
      VENDOR_NAME STRING,
      TPEP_PICKUP_DATETIME STRING,
      TPEP_DROPOFF_DATETIME STRING,
      PASSENGER_COUNT STRING,
      TRIP_DISTANCE STRING,
      PICKUP_LONGITUDE STRING,
      PICKUP_LATITUDE STRING,
      RATECODEID STRING,
      STORE_AND_FWD_FLAG STRING,
      DROPOFF_LONGITUDE STRING,
      DROPOFF_LATITUDE STRING,
      PAYMENT_TYPE STRING,
      PAYMENT_TYPE_NAME STRING,
      FARE_AMOUNT STRING,
      EXTRA STRING,
      MTA_TAX STRING,
      TIP_AMOUNT STRING,
      TOLLS_AMOUNT STRING,
      IMPROVEMENT_SURCHARGE STRING,
      TOTAL_AMOUNT STRING,
      TRIP_DURATION_MINUTES STRING,
      TRIP_SPEED_MPH STRING,
      CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
    );
SQL
}