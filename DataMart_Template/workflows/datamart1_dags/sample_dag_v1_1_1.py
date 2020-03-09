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
    'retry_delay':timedelta(minutes=5)
}


dag = DAG('Datamart_Template',
        default_args=default_args,
        description='Datamart Template',
        schedule_interval=timedelta(days=1)
        )


display_msg = BashOperator(task_id='print_msg',
                    bash_command='echo "Hello world, Connecting Bigquery..............."' ,
                    dag=dag)

run_bigquery = BigQueryOperator(
    task_id='get_sample_data',
    sql='DataMart_Template/bigquery/bigquery_sample.sql',
    use_legacy_sql=False,
    dag=dag
)
display_msg.set_downstream(run_bigquery)