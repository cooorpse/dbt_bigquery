FROM astrocrpublic.azurecr.io/runtime:3.0-10

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY /.dbt/profiles.yml /usr/local/airflow/.dbt/profiles.yml
COPY /.dbt/dbt_bq_dev-creds.json /usr/local/airflow/.dbt/dbt_bq_dev-creds.json