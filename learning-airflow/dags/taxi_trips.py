from airflow.decorators import dag, task
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from datetime import datetime
import tempfile
import os

BUCKET_NAME = "se-data-landing-reyur"
REMOTE_FILE_NAME = "taxi_trips_2016010100_00_00.csv"
SNOWFLAKE_CONN_ID = "Snowflake_default"
RAW_TABLE_NAME = "TAXI_TRIPS_CURATED"

@dag(
    schedule_interval=None,  # Trigger manually
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["Load Taxi Trips Data To the Raw Layer"],
)
# def snowflake_connection_test():
#     @task
#     def test_connection():
#         hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)
#         hook.run("USE ROLE SE_DE_PARTICIPANT;")
#         result = hook.run("SELECT CURRENT_VERSION();")
#         print(f"Snowflake version: {result}")

#     test_connection()

# test_dag = snowflake_connection_test()
def data_to_raw_layer():
    @task
    def read_from_gcs():
        # Read content from a file in GCS
        gcs_hook = GCSHook()
        try:
            content = gcs_hook.download(
                bucket_name=BUCKET_NAME,
                object_name=REMOTE_FILE_NAME,
            ).decode("utf-8")
            print(f"Content of {REMOTE_FILE_NAME} from GCS: {content}")
            return content
        except Exception as e:
            print(f"Error downloading file {REMOTE_FILE_NAME} from GCS: {e}")
            raise

    @task
    def load_to_snowflake(content: str):
        # Load data into Snowflake using a temporary stage and COPY INTO
        print("Loading data to Snowflake...")

        # Save content to a temporary local file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".csv") as temp_file:
            temp_file.write(content.encode("utf-8"))
            temp_file_path = temp_file.name
        
        try:
            # Initialize SnowflakeHook
            snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)

            # Use PUT to upload the file to Snowflake's table-specific stage
            snowflake_hook.run(f"""
                PUT file://{temp_file_path} @%{RAW_TABLE_NAME};
            """)
            print(f"File uploaded to Snowflake temporary stage for table: {RAW_TABLE_NAME}")
            
            # Use COPY INTO to load data from the stage into the table
            snowflake_hook.run(f"""
                COPY INTO {RAW_TABLE_NAME}
                FROM @%{RAW_TABLE_NAME}
                FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1 ERROR_ON_COLUMN_COUNT_MISMATCH=false);
            """)
            print(f"Data successfully loaded into {RAW_TABLE_NAME}.")
        except Exception as e:
            print(f"Error loading data into Snowflake: {e}")
            raise
        finally:
            # Cleanup the temporary file
            os.remove(temp_file_path)

    # Task dependencies
    file_content = read_from_gcs()
    load_to_snowflake(file_content)

data_to_raw_layer_dag = data_to_raw_layer()