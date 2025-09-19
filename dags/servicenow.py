from airflow import DAG
from datetime import datetime
from cosmos import DbtDag, DbtTaskGroup, ProjectConfig, ProfileConfig, RenderConfig, LoadMode

DBT_PROJECT_DIR = "/usr/local/airflow/projects/bq_servicenow"
DBT_PROFILES_YML = "/usr/local/airflow/.dbt/profiles.yml"

profile_config = ProfileConfig(
    profile_name="bq_servicenow",
    target_name="dev",
    profiles_yml_filepath=DBT_PROFILES_YML,
)

my_dag = DbtDag(
    # Cosmos parameters
    project_config=ProjectConfig(DBT_PROJECT_DIR),
    profile_config=profile_config,
    operator_args={"install_deps": True},
    render_config=RenderConfig(
        load_method=LoadMode.DBT_LS,
        # select=["stg_Incidents", "fct_Incidents_daily_state", "fct_Incidents"],
        test_behavior="after_all",
        # exclude=["tag:experimental", "path:models/ServiceNow/staging"]  # Opcional
    ),

    # dbt Parameters
    dag_id="dbt_servicenow",
    start_date=datetime(2025, 1, 1),
    # schedule="@daily",
    catchup=False,
    tags=["servicenow", "bigquery"],
    default_args={"retries": 0},
)