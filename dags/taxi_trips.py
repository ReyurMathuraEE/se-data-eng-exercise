from airflow.decorators import dag, task
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.operators.bash import BashOperator
from datetime import datetime
import os

# Constants
SNOWFLAKE_CONN_ID = "snowflake_default"
RAW_TABLE_NAME = "TAXI_TRIPS_RAW"
STAGE_NAME = "REYUR_STAGE"
FILE_FORMAT = "CSV_FORMAT"
DBT_PROJECT_DIR = "/opt/airflow/dbts"
DBT_PROFILES_DIR = "/opt/airflow/dbts"


@dag(
    schedule_interval=None,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["Load Taxi Trips Data To Snowflake Raw Layer"],
)
def taxi_trips_dag():

    @task
    def load_to_snowflake():
        # Loads new files into Snowflake using COPY INTO with PATTERN
        snowflake_hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN_ID)

        copy_query = f"""
            COPY INTO {RAW_TABLE_NAME}
            FROM @{STAGE_NAME}
            FILE_FORMAT = (FORMAT_NAME = '{FILE_FORMAT}')
            PATTERN = '.*taxi_trips_\\\\d{{10}}_\\\\d{{2}}_\\\\d{{2}}\\.csv';            
        """#ON_ERROR = 'CONTINUE'""";

        snowflake_hook.run(copy_query)
        print(f"Data successfully loaded from stage {STAGE_NAME} into {RAW_TABLE_NAME}")

        # Debug scripts
        # files_and_folders = os.listdir()
        # script_dir = os.path.dirname(os.path.abspath(__file__))
        # print(f"Files and folders: {files_and_folders}")
        # print(f"Script: {script_dir}")

    @task
    def dbt_run_model():
        # Runs DBT model to load data into the staging table
        # Set the DBT_PROFILES_DIR environment variable to tell DBT where to find the profiles.yml file
        os.environ["DBT_PROFILES_DIR"] = DBT_PROFILES_DIR

        dbt_run = BashOperator(
            task_id="dbt_run_model",
            bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --models stg_taxi_trips_consistent",
        )

        dbt_run.execute(context={})
        print("DBT model run successful")

    @task
    def dbt_test_model():
        #Runs DBT data tests

        dbt_run = BashOperator(
            task_id="dbt_test_model",
            bash_command=f"cd {DBT_PROJECT_DIR} && dbt test --select test_type:data",
        )

        dbt_run.execute(context={})
        print("DBT model run successful")

    @task
    def dbt_cleansed_model():
        # Runs DBT data tests

        dbt_run = BashOperator(
            task_id="dbt_test_model",
            bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --models taxi_trips_consistent",
        )

        dbt_run.execute(context={})
        print("DBT model run successful")

    load_to_snowflake() >> dbt_run_model() >> dbt_test_model() >> dbt_cleansed_model()

taxi_trips_dag_instance = taxi_trips_dag()