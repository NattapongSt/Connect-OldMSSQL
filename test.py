import os
import pyodbc
from dotenv import load_dotenv

load_dotenv()

# server = os.getenv("portal-server")  # <== edit as needed
# port = os.getenv("portal-port")
# database = os.getenv("portal-database")
# username = os.getenv("portal-username")
# password = os.getenv("portal-password")

server = os.getenv("airflow-server")  # <== edit as needed
port = os.getenv("airflow-port")
database = os.getenv("airflow-database")
username = os.getenv("airflow-username")
password = os.getenv("airflow-password")

# server = os.getenv("finance-server")  # <== edit as needed
# port = os.getenv("finance-port")
# database = os.getenv("finance-database")
# username = os.getenv("finance-username")
# password = os.getenv("finance-password")

tds_version = "7.0"  

conn_str = (
    f"DRIVER={{FreeTDS}};"
    f"SERVER={server};"
    f"PORT={port};"
    f"DATABASE={database};UID={username};PWD={password};"
    f"TDS_Version={tds_version};"  
)

print(f"Connecting to {database} ({server}:{port}) using FreeTDS (TDS Version {tds_version})...")
conn = pyodbc.connect(conn_str)
print("Connected!")
cursor = conn.cursor()
cursor.execute("SELECT GETDATE()")
print("Server time:", cursor.fetchone()[0])
conn.close()