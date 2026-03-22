import pandas as pd
import numpy as np
from sqlalchemy import create_engine
import os
import time
from faker import Faker
import random
import datetime

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:password123@postgres-db:5432/bank_practice")
CSV_URL = "https://raw.githubusercontent.com/nsethi31/Kaggle-Data-Credit-Card-Fraud-Detection/master/creditcard.csv"

# Configuración de fakes reproducibles
fake = Faker('es_MX') # Generaremos datos de sucursales con nombres realistas locales
Faker.seed(42)
np.random.seed(42)
random.seed(42)

def wait_for_db(engine, max_retries=10, delay=5):
    for i in range(max_retries):
        try:
            with engine.connect() as conn:
                print("Successfully connected to the database!")
                return
        except Exception as e:
            print(f"Database not ready yet... retrying in {delay} seconds. ({i+1}/{max_retries})")
            time.sleep(delay)
    raise Exception("Could not connect to database after maximum retries.")

def main():
    print(f"Connecting to database at {DATABASE_URL}...")
    engine = create_engine(DATABASE_URL)
    wait_for_db(engine)

    print(f"Downloading real credit card transactions dataset from {CSV_URL}...")
    # Leemos solo 35,000 registros para que se mantenga ligero y rápido el contenedor.
    # Estos son datos reales de transacciones incluyendo montos y clasificación de fraude (Class).
    df = pd.read_csv(CSV_URL, nrows=35000)

    print("Synthesizing relational ecosystem (Branches, Customers, Accounts, Cards)...")
    NUM_BRANCHES = 35
    NUM_CUSTOMERS = 2000
    NUM_ACCOUNTS = 2500
    NUM_CARDS = 3000

    # 1. GENERATE BRANCHES
    branches = pd.DataFrame([{
        'branch_id': i,
        'branch_name': f"Sucursal {fake.city()}",
        'city': fake.city(),
        'state': fake.state(),
        'zip_code': fake.postcode()
    } for i in range(1, NUM_BRANCHES + 1)])

    # 2. GENERATE CUSTOMERS
    jobs = ['Ingeniero de Software', 'Profesor', 'Médico', 'Gerente', 'Analista de Datos', 'Director', 'Consultor', 'Comerciante', 'Abogado']
    customers = pd.DataFrame([{
        'customer_id': i,
        'first_name': fake.first_name(),
        'last_name': fake.last_name(),
        'email': fake.ascii_company_email(),
        'job_title': random.choice(jobs),
        'dob': fake.date_of_birth(minimum_age=18, maximum_age=80),
        'branch_id': random.randint(1, NUM_BRANCHES)
    } for i in range(1, NUM_CUSTOMERS + 1)])

    # 3. GENERATE ACCOUNTS
    acc_types = ['checking', 'savings', 'credit']
    accounts = pd.DataFrame([{
        'account_id': i,
        'customer_id': random.randint(1, NUM_CUSTOMERS),
        'account_type': random.choice(acc_types),
        'balance': round(random.uniform(500.0, 150000.0), 2),
        'created_at': fake.date_time_between(start_date='-5y', end_date='now')
    } for i in range(1, NUM_ACCOUNTS + 1)])

    # 4. GENERATE CARDS
    card_networks = ['Visa', 'MasterCard', 'American Express']
    cards = pd.DataFrame([{
        'card_id': i,
        'account_id': random.randint(1, NUM_ACCOUNTS),
        'card_number': fake.credit_card_number(card_type=None),
        'card_network': random.choice(card_networks),
        # Generar fechas expiración futuras correctas (pd.to_datetime para evitar problemas psycopg2 date)
        'expiration_date': pd.to_datetime(fake.date_between(start_date='now', end_date='+5y')),
        'cvv': fake.credit_card_security_code()
    } for i in range(1, NUM_CARDS + 1)])

    # 5. GENERATE TRANSACTIONS FROM CSV
    print(f"Mapping {len(df)} real transactions to synthetic ecosystem...")
    merchants = [fake.company() for _ in range(800)]
    categories = ['Supermercado', 'Electrónica', 'Viajes', 'Restaurante', 'Entretenimiento', 'Gasolina', 'Salud', 'Ropa']

    transactions = pd.DataFrame({
        'transaction_id': range(1, len(df) + 1),
        'card_id': [random.randint(1, NUM_CARDS) for _ in range(len(df))],
        # Convertimos la columna 'Time' (segundos) a fechas reales partiendo de un timestamp base
        'transaction_timestamp': pd.Timestamp('2023-01-01') + pd.to_timedelta(df['Time'], unit='s'),
        'merchant_name': [random.choice(merchants) for _ in range(len(df))],
        'category': [random.choice(categories) for _ in range(len(df))],
        'amount': df['Amount'],
        'is_fraud': df['Class'].astype(bool)
    })

    print("Loading data into PostgreSQL...")
    branches.to_sql('branches', engine, if_exists='append', index=False)
    print("✅ Branches loaded")
    
    customers.to_sql('customers', engine, if_exists='append', index=False)
    print("✅ Customers loaded")
    
    accounts.to_sql('accounts', engine, if_exists='append', index=False)
    print("✅ Accounts loaded")
    
    cards.to_sql('cards', engine, if_exists='append', index=False)
    print("✅ Cards loaded")
    
    transactions.to_sql('transactions', engine, if_exists='append', index=False)
    print("✅ Transactions loaded")

    print("""
    🎉 Advanced Schema setup complete!
    Total inserted:
    - Branches: 35
    - Customers: 2000
    - Accounts: 2500
    - Cards: 3000
    - Transactions: 35000
    """)

if __name__ == "__main__":
    main()
