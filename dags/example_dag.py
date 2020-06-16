from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.bash_operator import BashOperator

default_args = {
    'depends_on_past': False,
    'start_date': datetime(2020, 6, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
}

dag = DAG(
    'example_dag',
    default_args=default_args,
    description='Simple example DAG running every minute, showcasing two operators',
    schedule_interval=timedelta(minutes=1)
)

start_task = BashOperator(
    task_id='print_date',
    bash_command='date',
    dag=dag
)

end_task = DummyOperator(
    task_id='end_task',
    dag=dag
)

start_task >> end_task
