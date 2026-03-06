/*
 * SETUP SCRIPT - FINTECH MOCK DATABASE
 * This script creates the necessary tables to execute and test all scripts in the src/ folder.
 * Useful for loading into a local environment (e.g., PostgreSQL) or using DB Fiddle.
 */

-- Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Internal Transactions Table
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    amount DECIMAL(10, 2),
    status VARCHAR(20), -- 'completed', 'pending', 'failed'
    transaction_date TIMESTAMP
);

-- External Payment Processor Logs (For Bank Reconciliation)
CREATE TABLE external_gateway_logs (
    gateway_trx_id VARCHAR(50) PRIMARY KEY,
    internal_trx_id INT,
    amount DECIMAL(10, 2),
    status VARCHAR(20)
);

-- App Events Table (For the KYC Funnel)
CREATE TABLE app_events (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    event_name VARCHAR(50), -- 'app_downloaded', 'email_verified', 'kyc_documents_uploaded', 'first_deposit_made'
    event_timestamp TIMESTAMP
);
