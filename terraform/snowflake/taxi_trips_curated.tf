resource "snowflake_table" "taxi_trips_curated" {
  name      = "TAXI_TRIPS_CURATED"
  database  = var.snowflake_database
  schema    = var.snowflake_schema
  comment   = "Curated table for taxi trips"

  column {
    name = "VENDOR_NAME"
    type = "STRING"
    comment = "Vendor providing the trip service"
  }

  column {
    name = "TPEP_PICKUP_DATETIME"
    type = "STRING"
    comment = "Pickup timestamp in string format"
  }

  column {
    name = "TPEP_DROPOFF_DATETIME"
    type = "STRING"
    comment = "Dropoff timestamp in string format"
  }

  column {
    name = "PASSENGER_COUNT"
    type = "STRING"
    comment = "Number of passengers"
  }

  column {
    name = "TRIP_DISTANCE"
    type = "STRING"
    comment = "Distance of the trip in string format"
  }

  column {
    name = "PICKUP_LONGITUDE"
    type = "STRING"
    comment = "Longitude of the pickup location"
  }

  column {
    name = "PICKUP_LATITUDE"
    type = "STRING"
    comment = "Latitude of the pickup location"
  }

  column {
    name = "RATECODEID"
    type = "STRING"
    comment = "Rate code for the trip"
  }

  column {
    name = "STORE_AND_FWD_FLAG"
    type = "STRING"
    comment = "Indicates if the trip was stored and forwarded"
  }

  column {
    name = "DROPOFF_LONGITUDE"
    type = "STRING"
    comment = "Longitude of the dropoff location"
  }

  column {
    name = "DROPOFF_LATITUDE"
    type = "STRING"
    comment = "Latitude of the dropoff location"
  }

  column {
    name = "PAYMENT_TYPE"
    type = "STRING"
    comment = "Type of payment"
  }

  column {
    name = "PAYMENT_TYPE_NAME"
    type = "STRING"
    comment = "Readable name of the payment type"
  }

  column {
    name = "FARE_AMOUNT"
    type = "STRING"
    comment = "Total fare for the trip"
  }

  column {
    name = "EXTRA"
    type = "STRING"
    comment = "Additional charges for the trip"
  }

  column {
    name = "MTA_TAX"
    type = "STRING"
    comment = "Tax applied for MTA services"
  }

  column {
    name = "TIP_AMOUNT"
    type = "STRING"
    comment = "Tip amount given by the customer"
  }

  column {
    name = "TOLLS_AMOUNT"
    type = "STRING"
    comment = "Tolls charged during the trip"
  }

  column {
    name = "IMPROVEMENT_SURCHARGE"
    type = "STRING"
    comment = "Improvement surcharge applied"
  }

  column {
    name = "TOTAL_AMOUNT"
    type = "STRING"
    comment = "Total amount charged for the trip"
  }

  column {
    name = "TRIP_DURATION_MINUTES"
    type = "STRING"
    comment = "Duration of the trip in minutes"
  }

  column {
    name = "TRIP_SPEED_MPH"
    type = "STRING"
    comment = "Speed of the trip in miles per hour"
  }

  column {
    name = "CREATED_TIMESTAMP"
    type = "TIMESTAMP_NTZ"
    comment = "Record creation timestamp"
    default = "CURRENT_TIMESTAMP()"
  }
}
