from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import os
import re
import pandas as pd
from sqlalchemy import create_engine, inspect, text
import logging
import stat

def clean_column_name(name):
    name = name.lower().replace(' ', '_')
    name = re.sub(r'[^\w]', '', name)
    return name

def process_excel_files(**kwargs):
    engine = create_engine('postgresql://dspTeam:dsp2024@postgres/studentdropout')
    raw_dir = '/data/raw'
    created_tables = []
    
    for file in os.listdir(raw_dir):
        if 'Osiris' in file and file.endswith('.xlsx'):
            excel_file = pd.ExcelFile(os.path.join(raw_dir, file))
            
            for sheet in excel_file.sheet_names[1:]: 
                df = pd.read_excel(excel_file, sheet_name=sheet)
                
                # Clean column names
                df.columns = [clean_column_name(col) for col in df.columns]
                
                table_name = clean_column_name(sheet.replace('ODS.', ''))
                
                df.to_sql(table_name, engine, if_exists='replace', index=False)
                created_tables.append(table_name)
    
    # Push the list of created tables to XCom
    kwargs['ti'].xcom_push(key='created_tables', value=created_tables)

def combine_tables():
    engine = create_engine('postgresql://dspTeam:dsp2024@postgres/studentdropout')
    
    logging.info("Starting to combine tables")

#USE THIS IF YOU NEED TO FIX OR AD COLUMNS TO MAKE SURE THEY ARE UNIQUE
        #         WITH column_names AS (
        #     SELECT table_name, column_name,
        #            CASE table_name
        #                WHEN 'oss_student' THEN 's'
        #                WHEN 'oss_student_examen' THEN 'e'
        #                WHEN 'oss_student_inschrijfhist' THEN 'i'
        #                WHEN 'oss_student_vooropleiding' THEN 'v'
        #                WHEN 'oss_vooropleiding' THEN 'vr'
        #            END AS table_alias
        #     FROM information_schema.columns
        #     WHERE table_name IN ('oss_student', 'oss_student_examen', 'oss_student_inschrijfhist', 'oss_student_vooropleiding', 'oss_vooropleiding')
        # )
        
        # select concat(table_alias,'.',column_name,',') as new_column from column_names order by table_alias,column_name

    # SQL query to combine tables
    query = """
        DROP TABLE IF EXISTS combined_data;
          SELECT DISTINCT
                ROW_NUMBER() OVER (PARTITION BY s.studentnummer ORDER BY s.studentnummer) AS row_num,
        s.studentnummer 
        ,e.aanvangsdatum
        ,e.deelname_honours
        ,e.eerste_graad
        ,e.examendatum
        ,e.examenprogramma
        ,e.examentype
        ,e.judicium
        ,i.actiefcode_opleiding_csa
        ,i.afloopdatum
        ,i.beeindigingsreden
        ,i.bekostiging
        ,i.collegejaar
        ,i.croho
        ,i.datum_bewijs_inschrijving
        ,i.datum_eerste_inschr_verz_ho
        ,i.datum_studiekeuzecheck
        ,i.datum_verzoek_inschr
        ,i.datum_verzoek_stoppen
        ,i.decentrale_selectie_resultaat
        ,i.decentrale_selectie_volgnummer
        ,i.deelname_studiekeuzecheck
        ,i.examentype_csa
        ,i.hoofd_opleiding
        ,i.ingangsdatum
        ,i.intrekking_vooraanmelding
        ,i.loting_ibg_status
        ,i.loting_reden_afkeur
        ,i.loting_reden_voorbehoud
        ,i.lotingresultaat
        ,i.lotingvorm
        ,i.mutatiedatum_actiefcode
        ,i.opleiding
        ,i.result_studiekeuzecheck
        ,i.soort_inschrijving_fac
        ,i.toelaatb_studiekeuzecheck
        ,i.voltijd_deeltijd
        ,s.aanvangsjaar_uu_student
        ,s.geboortedatum
        ,s.geslacht
        ,s.nationaliteit
        ,v.datum_verificatie
        ,v.diploma_behaald
        ,v.eindexamendatum
        ,v.extensie_code
        ,v.extensie_naam
        ,v.school_naam
        ,v.status_verificatie
        ,vr.actueel
        ,vr.naam
        ,vr.type_vooropleiding
        ,vr.typv_omschrijving_nls
        ,vr.vooropleiding

            into combined_data
            FROM 
                oss_student s
            LEFT OUTER JOIN 
                oss_student_examen e 
            ON 
                s.studentnummer = e.studentnummer
            LEFT OUTER JOIN 
                oss_student_inschrijfhist i
            ON 
                s.studentnummer = i.studentnummer
            LEFT OUTER JOIN 
                oss_student_vooropleiding v 
            ON s.studentnummer = v.studentnummer
            LEFT OUTER JOIN 
                oss_vooropleiding vr 
            ON  v.vooropleiding = vr.vooropleiding
            ORDER BY s.studentnummer

    """
   
    with engine.connect() as connection:
        try:
            connection.execute(text(query))
            logging.info("Successfully combined tables")
        except Exception as e:
            logging.error("Error combining tables: %s", e)

def set_directory_permissions(directory):
    try:
        os.chmod(directory, stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO)
        logging.info(f"Set permissions for directory {directory}")
    except Exception as e:
        logging.error(f"Error setting permissions for directory {directory}: {e}")

def export_combined_data_to_csv():
    raw_dir = '/tmp'
    set_directory_permissions(raw_dir)
    
    engine = create_engine('postgresql://dspTeam:dsp2024@postgres/studentdropout')
    query = "SELECT * FROM combined_data"
    
    with engine.connect() as connection:
        try:
            df = pd.read_sql(query, connection)
            output_file = os.path.join(raw_dir, 'combined_data.csv')
            df.to_csv(output_file, index=False)
            logging.info(f"Exported combined data to {output_file}")
        except Exception as e:
            logging.error("Error exporting combined data to CSV: %s", e)

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
    'excel_to_postgres_and_combine',
    default_args=default_args,
    description='Extract data from Excel, insert into PostgreSQL, and combine tables',
    schedule_interval=timedelta(days=1),
)

process_task = PythonOperator(
    task_id='process_excel_files',
    python_callable=process_excel_files,
    provide_context=True,
    dag=dag,
)

combine_task = PythonOperator(
    task_id='combine_tables',
    python_callable=combine_tables,
    dag=dag,
)

export_task = PythonOperator(
    task_id='export_combined_data_to_csv',
    python_callable=export_combined_data_to_csv,
    dag=dag,
)

process_task >> combine_task >> export_task
