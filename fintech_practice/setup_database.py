import sqlite3
import urllib.request
import os
import sys

url = "https://raw.githubusercontent.com/gastonstat/CreditScoring/master/CreditScoring.csv"
print(f"Downloading data from {url}...")

def load_data():
    import pandas as pd
    try:
        # Some CSVs from UCI have an extra header row with the ID, LIMIT_BAL string, we'll just read and clean columns
        df = pd.read_csv(url)
        # Clean column names to be valid and friendly SQL column identifiers
        df.columns = [str(c).lower().replace(' ', '_').replace('.', '') for c in df.columns]
        
        # Connect to SQLite and write data
        db_path = "finance_practice.db"
        conn = sqlite3.connect(db_path)
        print("Writing to SQLite database -> finance_practice.db")
        df.to_sql("credit_card_data", conn, if_exists="replace", index=False)
        conn.close()
        print(f"Successfully created database and populated 'credit_card_data' table with {len(df)} rows.")
    except Exception as e:
        print(f"Error reading and inserting data using pandas: {e}")

try:
    import pandas as pd
    print("Pandas is already installed. Using pandas to load CSV...")
    load_data()
except ImportError:
    print("Pandas not found! Attempting to pip install pandas...")
    os.system(f"{sys.executable} -m pip install pandas")
    print("Retrying load_data...")
    load_data()
