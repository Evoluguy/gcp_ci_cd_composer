from datetime import timedelta
import airflow
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.contrib.operators.bigquery_operator import BigQueryOperator
# from airflow.contrib.operators import bigquery_operator

default_args={
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(2),
    'depends_on_past': False,
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay':timedelta(seconds=20)
}


dag = DAG('dm_sample',
        default_args=default_args,
        description='Datamart Template DAG',
        schedule_interval=timedelta(days=1)
        )


display_msg = BashOperator(task_id='print_msg',
                    bash_command='echo "Connecting Bigquery from dag2..............."' ,
                    dag=dag)

run_bigquery = BigQueryOperator(
    task_id='get_sample_data',
    sql='bql/bigquery_sample2.sql',
    use_legacy_sql=False,
    dag=dag
)
display_msg >> run_bigquery