-- Esquema Relacional Completo: Sistema de Tarjetas de Crédito y Sedes

-- 1. Sedes (Branches)
CREATE TABLE IF NOT EXISTS branches (
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(150),
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20)
);

-- 2. Clientes (Customers)
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150),
    job_title VARCHAR(150),
    dob DATE,
    branch_id INT REFERENCES branches(branch_id)
);

-- 3. Cuentas (Accounts)
CREATE TABLE IF NOT EXISTS accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    account_type VARCHAR(50), -- checking, savings, credit
    balance NUMERIC(15, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tarjetas de Crédito/Débito (Cards)
CREATE TABLE IF NOT EXISTS cards (
    card_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(account_id),
    card_number VARCHAR(20),
    card_network VARCHAR(50), -- Visa, MasterCard, Amex
    expiration_date DATE,
    cvv VARCHAR(4)
);

-- 5. Transacciones de Tarjetas (Card Transactions)
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id SERIAL PRIMARY KEY,
    card_id INT REFERENCES cards(card_id),
    transaction_timestamp TIMESTAMP,
    merchant_name VARCHAR(150),
    category VARCHAR(100), -- Groceries, Tech, Travel
    amount NUMERIC(15, 2),
    is_fraud BOOLEAN
);
