from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.hooks.base_hook import BaseHook
from datetime import datetime
import pandas as pd
import pyodbc

def fetch_data_from_view(view_name, **context):
    conn = BaseHook.get_connection('mssql_default')
    conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={conn.host};DATABASE={conn.schema};UID={conn.login};PWD={conn.password}'
    connection = pyodbc.connect(conn_str)
    
    query = f"SELECT * FROM {view_name}"
    df = pd.read_sql(query, connection)
    connection.close()
    
    context['task_instance'].xcom_push(key=f'{view_name}_data', value=df.to_json())

def export_views_to_excel(view_names, excel_path, **context):
    with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
        for view in view_names:
            df_json = context['task_instance'].xcom_pull(key=f'{view}_data')
            df = pd.read_json(df_json)
            df.to_excel(writer, sheet_name=view, index=False)
    print(f"Data from views {view_names} has been written to {excel_path}")

# Define default_args
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 7, 1),
    'retries': 1,
}

# Instantiate the DAG
dag = DAG(
    'osiris_export_SQL_to_excel',
    default_args=default_args,
    description='A DAG to extract data from MSSQL views and save to an Excel file',
    schedule_interval='0 0 * * 1', 
    catchup=False,
)
#&TbS$Jhp!jyTfX83gWe#!@WBu=&98=%SYwJK

# server = 'ssdenaacc.database.windows.net'
# database = 'DB_DENA_DWH'
# username = 'sa-dsp-python-p@hu.nl'
# password = '&TbS$Jhp!jyTfX83gWe#!@WBu=&98=%SYwJK'


view_names = ['view1', 'view2', 'view3', 'view4', 'view5']

# Create tasks to fetch data from each view
fetch_tasks = []
for view in view_names:
    fetch_task = PythonOperator(
        task_id=f'fetch_{view}',
        python_callable=fetch_data_from_view,
        op_kwargs={'view_name': view},
        provide_context=True,
        dag=dag,
    )
    fetch_tasks.append(fetch_task)

# Create task to export all views data to Excel
export_task = PythonOperator(
    task_id='export_views_to_excel',
    python_callable=export_views_to_excel,
    op_kwargs={
        'view_names': view_names,
        'excel_path': '/data/raw/output.xlsx',  # Corrected path for Docker setup
    },
    provide_context=True,
    dag=dag,
)

# Set task dependencies
for fetch_task in fetch_tasks:
    fetch_task >> export_task
