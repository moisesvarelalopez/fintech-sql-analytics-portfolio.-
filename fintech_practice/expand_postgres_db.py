import psycopg2
import psycopg2.extras
import random
from datetime import datetime, timedelta

def expand_db():
    user = "postgres"
    password = "postgres"
    host = "localhost"
    port = "5432"
    dbname = "finance_practice_db"

    conn = psycopg2.connect(dbname=dbname, user=user, password=password, host=host, port=port)
    conn.autocommit = True
    cursor = conn.cursor()

    print("Dropping old relational tables if they exist...")
    cursor.execute("DROP TABLE IF EXISTS transactions CASCADE;")
    cursor.execute("DROP TABLE IF EXISTS accounts CASCADE;")
    cursor.execute("DROP TABLE IF EXISTS customers CASCADE;")
    cursor.execute("DROP TABLE IF EXISTS branches CASCADE;")

    print("Altering credit_card_data to append IDs...")
    try:
        cursor.execute("ALTER TABLE credit_card_data ADD COLUMN credit_id SERIAL PRIMARY KEY;")
        cursor.execute("ALTER TABLE credit_card_data ADD COLUMN customer_id INTEGER;")
    except Exception as e:
        print("Columns might already exist. Ignored.")

    print("Creating schema for branches, customers, accounts, and transactions...")
    cursor.execute("""
        CREATE TABLE branches (
            branch_id SERIAL PRIMARY KEY,
            branch_name VARCHAR(100),
            city VARCHAR(100),
            state VARCHAR(50)
        );
    """)

    branches = [
        ('Main Street Branch', 'New York', 'NY'),
        ('Downtown Branch', 'Chicago', 'IL'),
        ('Westside Branch', 'Los Angeles', 'CA'),
        ('Silicon Valley Branch', 'San Jose', 'CA'),
        ('Southpark Branch', 'Austin', 'TX')
    ]
    psycopg2.extras.execute_values(cursor, "INSERT INTO branches (branch_name, city, state) VALUES %s", branches)

    cursor.execute("""
        CREATE TABLE customers (
            customer_id SERIAL PRIMARY KEY,
            first_name VARCHAR(50),
            last_name VARCHAR(50),
            email VARCHAR(100),
            phone VARCHAR(20),
            branch_id INTEGER REFERENCES branches(branch_id),
            joined_date DATE
        );
    """)

    cursor.execute("SELECT credit_id, age FROM credit_card_data;")
    credit_rows = cursor.fetchall()
    
    first_names = ['James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'David', 'Elizabeth', 'William', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica']
    last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas']

    # Generate exact number of customers as credit rows
    print(f"Generating {len(credit_rows)} mock customers to map to credit_card_data...")
    customer_data = []
    
    for i in range(len(credit_rows)):
        fn = random.choice(first_names)
        ln = random.choice(last_names)
        email = f"{fn.lower()}.{ln.lower()}{i+1}@example.com"
        phone = f"555-{random.randint(100,999)}-{random.randint(1000,9999)}"
        branch_id = random.randint(1, len(branches))
        joined = (datetime.now() - timedelta(days=random.randint(100, 3000))).date()
        customer_data.append((fn, ln, email, phone, branch_id, joined))
    
    psycopg2.extras.execute_values(
        cursor, 
        "INSERT INTO customers (first_name, last_name, email, phone, branch_id, joined_date) VALUES %s", 
        customer_data
    )

    print("Mapping credit_card_data customer_ids...")
    cursor.execute("""
        UPDATE credit_card_data
        SET customer_id = credit_id;
    """)
    cursor.execute("ALTER TABLE credit_card_data ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id);")

    print("Generating accounts...")
    cursor.execute("""
        CREATE TABLE accounts (
            account_id SERIAL PRIMARY KEY,
            customer_id INTEGER REFERENCES customers(customer_id),
            account_type VARCHAR(50),
            balance NUMERIC(15, 2),
            open_date DATE
        );
    """)
    
    accounts_data = []
    account_types = ['Checking', 'Savings']
    for cid in range(1, len(credit_rows) + 1):
        num_accounts = random.randint(1, 2)
        for _ in range(num_accounts):
            atype = random.choice(account_types)
            balance = round(random.uniform(-100.0, 50000.0), 2)
            open_date = (datetime.now() - timedelta(days=random.randint(10, 2000))).date()
            accounts_data.append((cid, atype, balance, open_date))
            
    psycopg2.extras.execute_values(
        cursor,
        "INSERT INTO accounts (customer_id, account_type, balance, open_date) VALUES %s",
        accounts_data
    )

    print("Generating checking and savings transactions...")
    cursor.execute("""
        CREATE TABLE transactions (
            transaction_id SERIAL PRIMARY KEY,
            account_id INTEGER REFERENCES accounts(account_id),
            transaction_type VARCHAR(50),
            amount NUMERIC(15, 2),
            transaction_date TIMESTAMP,
            description TEXT
        );
    """)
    
    # generate transactions for first 1000 accounts for safety and speed
    cursor.execute("SELECT account_id, open_date FROM accounts LIMIT 1000;")
    acc_rows = cursor.fetchall()
    
    transactions_data = []
    txn_types = ['Deposit', 'Withdrawal', 'Transfer', 'Payment', 'Fee']
    for acc_id, op_date in acc_rows:
        num_txns = random.randint(5, 30)
        for _ in range(num_txns):
            ttype = random.choice(txn_types)
            amount = round(random.uniform(5.0, 1500.0), 2)
            days_since_open = (datetime.now().date() - op_date).days
            if days_since_open > 0:
                txn_date = op_date + timedelta(days=random.randint(0, days_since_open))
            else:
                txn_date = op_date
            # Create timestamp
            txn_timestamp = datetime.combine(txn_date, datetime.min.time()) + timedelta(hours=random.randint(0,23), minutes=random.randint(0,59))
            desc = f"{ttype} via online banking"
            transactions_data.append((acc_id, ttype, amount, txn_timestamp.strftime('%Y-%m-%d %H:%M:%S'), desc))

    psycopg2.extras.execute_values(
        cursor,
        "INSERT INTO transactions (account_id, transaction_type, amount, transaction_date, description) VALUES %s",
        transactions_data
    )

    print(f"Successfully linked original credit_card_data with a relational postgres database populated with {len(customer_data)} customers and {len(transactions_data)} transactions!")

    cursor.close()
    conn.close()

if __name__ == '__main__':
    expand_db()
