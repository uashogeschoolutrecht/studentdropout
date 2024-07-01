from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import os
import pandas as pd
from sqlalchemy import create_engine

def process_excel_files():
    engine = create_engine('postgresql://dspTeam:dsp2024@postgres/studentdropout')
    raw_dir = '/data/raw'
    
    for file in os.listdir(raw_dir):
        if 'Osiris' in file and file.endswith('.xlsx'):
            excel_file = pd.ExcelFile(os.path.join(raw_dir, file))
            
            for sheet in excel_file.sheet_names[1:]:  # Skip the first sheet
                df = pd.read_excel(excel_file, sheet_name=sheet)
                table_name = sheet.replace('ODS', '').lower()
                
                df.to_sql(table_name, engine, if_exists='append', index=False)

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 7, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'excel_to_postgres',
    default_args=default_args,
    description='Extract data from Excel and insert into PostgreSQL',
    schedule_interval=timedelta(days=1),
)

process_task = PythonOperator(
    task_id='process_excel_files',
    python_callable=process_excel_files,
    dag=dag,
)