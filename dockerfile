# Start with the base Airflow image
FROM apache/airflow:2.10.4

RUN pip install apache-airflow-providers-snowflake

# Install deps
RUN pip install dbt-core dbt-snowflake dbt-unit-testing apache-airflow-providers-dbt


# Set the DBT profiles and project directory environment variables
ENV DBT_PROFILES_DIR=/opt/airflow/dbts
ENV DBT_PROJECT_DIR=/opt/airflow/dbts

RUN chmod -R 775 /opt/airflow/dbts

# Run DBT commands to ensure everything is set up correctly
RUN dbt deps --profiles-dir $DBT_PROFILES_DIR
RUN dbt clean --profiles-dir $DBT_PROFILES_DIR
RUN dbt compile --profiles-dir $DBT_PROFILES_DIR