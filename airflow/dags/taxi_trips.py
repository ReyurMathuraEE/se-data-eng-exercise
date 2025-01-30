import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.google.cloud.operators.gcs import GCSDownloadFileOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.hooks.gcs import GCSHook

GCP_BUCKET_NAME = 'your-gcp-bucket-name'
SNOWFLAKE_TABLE = 'taxi_trips_raw'

# Snowflake connection credentials (set these in your Airflow UI)
SNOWFLAKE_CONN_ID = 'your_snowflake_conn'

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'start_date': days_ago(1),
}

dag = DAG(
    'Taxi_Trips',
    default_args=default_args,
    description='A DAG to load Taxi trips data from GCP to Snowflake',
    schedule_interval=timedelta(days=1),
)

def get_latest_file_from_gcs():
    """Fetch the latest file from the GCP bucket."""
    hook = GCSHook(gcp_conn_id='google_cloud_default')
    files = hook.list(bucket_name=GCP_BUCKET_NAME, prefix='taxi_trips')
    
    # Sort by filename to get the most recent file
    files.sort(reverse=True)  # Assuming the format includes timestamps (e.g., taxi_trips_yyyymmddhh_mm_ss.csv)
    return files[0]  # Returning the latest file

def load_data_to_snowflake():
    """Load data from GCP bucket to Snowflake using Snowflake's metadata loading."""
    latest_file = get_latest_file_from_gcs()
    
    # Ensure this file is not already processed by checking metadata in Snowflake
    snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)
    
    # SQL to check if the file has been loaded already
    check_file_query = f"""
    SELECT COUNT(1) 
    FROM {SNOWFLAKE_TABLE} 
    WHERE file_name = '{latest_file}'
    """
    file_exists = snowflake_hook.get_first(check_file_query)[0]
    
    if file_exists == 0:  # File hasn't been loaded yet
        load_query = f"""
        COPY INTO {SNOWFLAKE_TABLE}
        FROM 'gcs://{GCP_BUCKET_NAME}/{latest_file}'
        FILE_FORMAT = (TYPE = 'CSV', FIELD_OPTIONALLY_ENCLOSED_BY = '"')
        ON_ERROR = 'SKIP_FILE';
        """
        snowflake_hook.run(load_query)
        return f"File {latest_file} loaded successfully."
    else:
        return f"File {latest_file} has already been loaded."

# Task 1: Get the latest file from GCP
download_task = GCSDownloadFileOperator(
    task_id='download_file_from_gcp',
    bucket_name=GCP_BUCKET_NAME,
    object_name=get_latest_file_from_gcs(),
    filename='/tmp/latest_taxi_trip_file.csv',
    google_cloud_storage_conn_id='google_cloud_default',
    dag=dag
)

# Task 2: Load data into Snowflake if it's new
load_data_task = SnowflakeOperator(
    task_id='load_data_to_snowflake',
    sql=load_data_to_snowflake(),
    snowflake_conn_id=SNOWFLAKE_CONN_ID,
    dag=dag
)

download_task >> load_data_task
