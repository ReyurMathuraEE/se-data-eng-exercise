from airflow.decorators import dag, task
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from datetime import datetime
import os

# Replace with your GCS bucket name
BUCKET_NAME = "se-data-landing-reyur"
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
LOCAL_FILE_PATH = os.path.join(SCRIPT_DIR, "hello_world.txt")
REMOTE_FILE_NAME = "hello_world.txt"


@dag(
    schedule_interval=None,  # Trigger manually
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["hello_world", "gcs", "taskflow_api"],
)
def hello_world_gcs():
    @task
    def read_local_file() -> str:
        """
        Reads content from a local file.
        """
        if not os.path.exists(LOCAL_FILE_PATH):
            raise FileNotFoundError(f"The file {LOCAL_FILE_PATH} does not exist.")

        with open(LOCAL_FILE_PATH, "r") as file:
            content = file.read()

        print(f"Read content from {LOCAL_FILE_PATH}: {content}")
        return content

    @task
    def write_to_gcs(file_content: str):
        """
        Uploads the local file content to the specified GCS bucket.
        """
        gcs_hook = GCSHook()
        gcs_hook.upload(
            bucket_name=BUCKET_NAME,
            object_name=REMOTE_FILE_NAME,
            data=file_content,
        )
        print(f"Uploaded content to GCS as {REMOTE_FILE_NAME}")

    @task
    def read_from_gcs():
        """
        Downloads the uploaded file content from GCS and prints it.
        """
        gcs_hook = GCSHook()
        content = gcs_hook.download(
            bucket_name=BUCKET_NAME,
            object_name=REMOTE_FILE_NAME,
        ).decode("utf-8")
        print(f"Content of {REMOTE_FILE_NAME} from GCS: {content}")

    # Task dependencies
    content = read_local_file()
    write_to_gcs(content)
    read_from_gcs()


hello_world_dag = hello_world_gcs()