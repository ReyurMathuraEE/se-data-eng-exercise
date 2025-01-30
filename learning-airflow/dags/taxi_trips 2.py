from airflow.decorators import dag, task
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from datetime import datetime
import re

# Constants
BUCKET_NAME = "se-data-landing-reyur"
REMOTE_FILE_PATTERN = "taxi_trips_*.csv"
SNOWFLAKE_CONN_ID = "Snowflake_default"
RAW_TABLE_NAME = "TAXI_TRIPS_CURATED"
STAGE_NAME = "EE_SE_DATA_ENGG_GCS" 
FILE_FORMAT = "CSV_FORMAT"

@dag(
    schedule_interval=None,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["Load Taxi Trips Data To the Raw Layer"],
)
def data_to_raw_layer2():

    @task
    def get_new_files():
        snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)

        stage_files_query = f"LIST @{STAGE_NAME};"
        stage_files = snowflake_hook.get_records(stage_files_query)

        all_files = [re.split(r'\s+', row[0])[-1] for row in stage_files]

        loaded_files_query = f"SELECT DISTINCT METADATA$FILENAME FROM {RAW_TABLE_NAME};"
        loaded_files = snowflake_hook.get_records(loaded_files_query)
        loaded_files = {row[0] for row in loaded_files}

        new_files = [f for f in all_files if f not in loaded_files]

        if not new_files:
            print("No new files to process.")
            return []

        print(f"New files to load: {new_files}")
        return new_files

    @task
    def load_to_snowflake(new_files):
        """Loads only new files into Snowflake using COPY INTO."""
        if not new_files:
            print("Skipping Snowflake load, no new files found.")
            return

        snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)

        try:
            print("Loading new files into Snowflake...")

            file_list = ", ".join([f"'{file}'" for file in new_files])

            copy_query = f"""
                COPY INTO {RAW_TABLE_NAME}
                FROM @{STAGE_NAME}
                FILE_FORMAT = (FORMAT_NAME = '{FILE_FORMAT}')
                FILES = ({file_list})
                ON_ERROR = 'CONTINUE';
            """
            snowflake_hook.run(copy_query)

            print(f"Data successfully loaded for files: {new_files}")

        except Exception as e:
            print(f"Error loading data into Snowflake: {e}")
            raise

    new_files = get_new_files()
    load_to_snowflake(new_files)

data_to_raw_layer_dag = data_to_raw_layer2()
