import sqlite3
import random
from datetime import datetime, timedelta

def create_db():
    conn = sqlite3.connect("relational_bank_practice.db")
    cursor = conn.cursor()

    # Create schema
    cursor.executescript('''
        DROP TABLE IF EXISTS transactions;
        DROP TABLE IF EXISTS loans;
        DROP TABLE IF EXISTS accounts;
        DROP TABLE IF EXISTS customers;
        DROP TABLE IF EXISTS branches;

        CREATE TABLE branches (
            branch_id INTEGER PRIMARY KEY AUTOINCREMENT,
            branch_name TEXT,
            city TEXT,
            state TEXT
        );

        CREATE TABLE customers (
            customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT,
            last_name TEXT,
            email TEXT,
            phone TEXT,
            branch_id INTEGER,
            joined_date DATE,
            FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        );

        CREATE TABLE accounts (
            account_id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER,
            account_type TEXT,
            balance REAL,
            open_date DATE,
            FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        );

        CREATE TABLE loans (
            loan_id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER,
            loan_type TEXT,
            loan_amount REAL,
            outstanding_balance REAL,
            interest_rate REAL,
            start_date DATE,
            FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        );

        CREATE TABLE transactions (
            transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
            account_id INTEGER,
            transaction_type TEXT,
            amount REAL,
            transaction_date DATETIME,
            description TEXT,
            FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        );
    ''')

    # Seed data
    branches = [
        ('Main Street Branch', 'New York', 'NY'),
        ('Downtown Branch', 'Chicago', 'IL'),
        ('Westside Branch', 'Los Angeles', 'CA'),
        ('Silicon Valley Branch', 'San Jose', 'CA'),
        ('Southpark Branch', 'Austin', 'TX')
    ]
    cursor.executemany("INSERT INTO branches (branch_name, city, state) VALUES (?, ?, ?)", branches)

    first_names = ['James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'David', 'Elizabeth', 'William', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica']
    last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas']
    
    customers = []
    for i in range(1, 251): # 250 customers
        fn = random.choice(first_names)
        ln = random.choice(last_names)
        email = f"{fn.lower()}.{ln.lower()}{i}@example.com"
        phone = f"555-{random.randint(100,999)}-{random.randint(1000,9999)}"
        branch_id = random.randint(1, len(branches))
        joined = (datetime.now() - timedelta(days=random.randint(100, 3000))).date()
        customers.append((fn, ln, email, phone, branch_id, joined))
    
    cursor.executemany("INSERT INTO customers (first_name, last_name, email, phone, branch_id, joined_date) VALUES (?, ?, ?, ?, ?, ?)", customers)

    accounts = []
    account_types = ['Checking', 'Savings', 'Credit Card']
    for cid in range(1, 251):
        # Each customer gets 1 to 4 accounts
        num_accounts = random.randint(1, 4)
        for _ in range(num_accounts):
            atype = random.choice(account_types)
            balance = round(random.uniform(-500.0, 75000.0), 2)
            open_date = (datetime.now() - timedelta(days=random.randint(10, 2000))).date()
            accounts.append((cid, atype, balance, open_date))
    
    cursor.executemany("INSERT INTO accounts (customer_id, account_type, balance, open_date) VALUES (?, ?, ?, ?)", accounts)

    # Some customers get loans
    loans = []
    loan_types = ['Mortgage', 'Auto Loan', 'Personal Loan']
    for cid in random.sample(range(1, 251), 80): # 80 customers have loans
        ltype = random.choice(loan_types)
        lamount = round(random.uniform(5000.0, 500000.0), 2)
        outstanding = round(lamount * random.uniform(0.1, 0.95), 2)
        irate = round(random.uniform(3.0, 12.0), 2)
        start_date = (datetime.now() - timedelta(days=random.randint(50, 1500))).date()
        loans.append((cid, ltype, lamount, outstanding, irate, start_date))
        
    cursor.executemany("INSERT INTO loans (customer_id, loan_type, loan_amount, outstanding_balance, interest_rate, start_date) VALUES (?, ?, ?, ?, ?, ?)", loans)

    # transactions
    cursor.execute("SELECT account_id, open_date FROM accounts")
    acc_rows = cursor.fetchall()
    
    transactions = []
    txn_types = ['Deposit', 'Withdrawal', 'Transfer', 'Payment', 'Fee']
    for acc_id, op_date in acc_rows:
        num_txns = random.randint(10, 100)
        open_dt = datetime.strptime(op_date, '%Y-%m-%d')
        for _ in range(num_txns):
            ttype = random.choice(txn_types)
            amount = round(random.uniform(2.0, 3500.0), 2)
            days_since_open = (datetime.now() - open_dt).days
            if days_since_open > 0:
                txn_date = open_dt + timedelta(days=random.randint(0, days_since_open), hours=random.randint(0,23), minutes=random.randint(0,59))
            else:
                txn_date = open_dt
            
            # Format to ISO string for cleaner sqlite imports
            txn_date_str = txn_date.strftime('%Y-%m-%d %H:%M:%S')
            desc = f"{ttype} via online banking"
            transactions.append((acc_id, ttype, amount, txn_date_str, desc))
            
    cursor.executemany("INSERT INTO transactions (account_id, transaction_type, amount, transaction_date, description) VALUES (?, ?, ?, ?, ?)", transactions)

    conn.commit()
    conn.close()
    
    print(f"Created relational_bank_practice.db with 5 tables and {len(transactions)} transactions!")

if __name__ == '__main__':
    create_db()
