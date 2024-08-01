import pyodbc

def test_mssql_connection(server, database, username, password):
    try:
        conn_str = f'DRIVER={{FreeTDS}};SERVER={server},1433;DATABASE={database};UID={username};PWD={password};TDS_Version=8.0;Encrypt=yes;TrustServerCertificate=no'
        print(f"Attempting to connect with: {conn_str}")
        connection = pyodbc.connect(conn_str)
        print("Connection successful!")
        connection.close()
    except pyodbc.Error as e:
        print(f"Connection failed: {str(e)}")

server = 'ssdenaacc.database.windows.net'
database = 'DB_DENA_DWH'
username = 'sa-dsp-python-p@hu.nl'
password = '&TbS$Jhp!jyTfX83gWe#!@WBu=&98=%SYwJK'

test_mssql_connection(server, database, username, password)