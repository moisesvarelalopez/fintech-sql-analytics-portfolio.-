import os
import sys

# Ensure dependencies are installed
try:
    import psycopg2
    from sqlalchemy import create_engine
except ImportError:
    print("Libraries missing. Installing psycopg2-binary and sqlalchemy...")
    os.system(f"{sys.executable} -m pip install psycopg2-binary sqlalchemy")
    import psycopg2
    from sqlalchemy import create_engine

import pandas as pd

def import_to_postgres():
    url = "https://raw.githubusercontent.com/gastonstat/CreditScoring/master/CreditScoring.csv"
    print(f"Downloading data from {url}...")
    df = pd.read_csv(url)
    df.columns = [str(c).lower().replace(' ', '_').replace('.', '') for c in df.columns]

    user = "postgres"
    password = "postgres"
    host = "localhost"
    port = "5432"
    dbname_new = "finance_practice_db"

    print("Connecting to PostgreSQL to create the database...")
    try:
        # Connect to default postgres DB
        conn = psycopg2.connect(dbname="postgres", user=user, password=password, host=host, port=port)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Terminate existing connections to allow dropping if it exists
        cursor.execute(f"SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '{dbname_new}' AND pid <> pg_backend_pid();")
        cursor.execute(f"DROP DATABASE IF EXISTS {dbname_new};")
        cursor.execute(f"CREATE DATABASE {dbname_new};")
        cursor.close()
        conn.close()
        print(f"Successfully created database '{dbname_new}'.")
    except Exception as e:
        print(f"Error creating db '{dbname_new}': {e}")
        print("Please check if the PostgreSQL service is running and the password is 'postgres'.")
        sys.exit(1)

    print("Connecting to the new database to push data...")
    try:
        engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{dbname_new}')
        df.to_sql('credit_card_data', engine, if_exists='replace', index=False)
        print(f"Success! Populated 'credit_card_data' table with {len(df)} rows in PostgreSQL.")
    except Exception as e:
        print(f"Error pushing data: {e}")
        sys.exit(1)

if __name__ == '__main__':
    import_to_postgres()
