/*
 * SETUP SCRIPT - FINTECH MOCK DATABASE (POSTGRESQL OPTIMIZED)
 * ---------------------------------------------------------------------------------
 * This script creates the core schema for a Fintech or Neo-Bank environment.
 * It features an advanced Data Engineering block using GENERATE_SERIES and RANDOM()
 * to seed the database with tens of thousands of realistic records for practice.
 * 
 * Instructions: Execute this entire script in a PostgreSQL environment (pgAdmin, DBeaver, etc.)
 */

-- ==============================================================================
-- 1. DDL: TABLE CREATION
-- ==============================================================================

DROP TABLE IF EXISTS app_events CASCADE;
DROP TABLE IF EXISTS external_gateway_logs CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS users CASCADE;

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
    event_name VARCHAR(50), 
    event_timestamp TIMESTAMP
);

-- ==============================================================================
-- 2. DML: SYNTHETIC DATA GENERATION (MASSIVE MOCKING)
-- ==============================================================================

-- A. GENERATE 1,000 REALISTIC USERS
INSERT INTO users (name, email, created_at)
SELECT 
    'User_' || seq AS name,
    'user_' || seq || '_' || md5(random()::text) || '@fintech.internal' AS email,
    NOW() - (random() * interval '365 days') AS created_at -- Accounts created randomly over the last year
FROM generate_series(1, 1000) AS seq;

-- B. GENERATE 50,000 TRANSACTIONS CROSSING THE 1,000 USERS
INSERT INTO transactions (user_id, amount, status, transaction_date)
SELECT 
    (random() * 999 + 1)::INT AS user_id, -- Random user between 1 and 1000
    ROUND((random() * 5500 + 10)::numeric, 2) AS amount, -- Random amounts from $10 to $5510 (To trigger Whale conditions)
    CASE 
        WHEN random() < 0.85 THEN 'completed' -- 85% success rate
        WHEN random() < 0.95 THEN 'failed'    -- 10% failure rate
        ELSE 'pending'                        -- 5% pending
    END AS status,
    NOW() - (random() * interval '90 days') AS transaction_date -- Activity from the last 90 days
FROM generate_series(1, 50000);

-- INJECTING FRAUD / STRUCTURING SCENARIOS (Smurfing at 3 AM)
-- Let's force some high-frequency night transactions for User 500 to trigger the Night Audit and Daily Activity scripts.
INSERT INTO transactions (user_id, amount, status, transaction_date)
SELECT 
    500, 
    99.00, 
    'completed', 
    CURRENT_DATE - interval '2 days' + (time '03:15') + (seq * interval '5 minutes')
FROM generate_series(1, 15) AS seq;

-- C. GENERATE 48,000 EXTERNAL GATEWAY LOGS (Simulating Reconciliation Loss)
-- We insert 48k instead of 50k so the Bank Reconciliation script detects the missing 2,000 transactions (Ghost Money)
INSERT INTO external_gateway_logs (gateway_trx_id, internal_trx_id, amount, status)
SELECT 
    'stripe_pi_' || md5(random()::text) AS gateway_trx_id,
    id AS internal_trx_id,
    amount,
    status
FROM transactions
WHERE id <= 48000;

-- INJECTING DISCREPANCIES FOR RECONCILIATION SCRIPT
-- Altering a few amounts and statuses so the FULL OUTER JOIN script flags them
UPDATE external_gateway_logs SET amount = amount - 5.00 WHERE internal_trx_id IN (100, 200, 300); -- Hidden fees
UPDATE external_gateway_logs SET status = 'failed' WHERE internal_trx_id IN (400, 500, 600); -- System mismatch

-- D. GENERATE KYC FUNNEL EVENTS FOR USERS
-- Step 1: 100% downloaded the app
INSERT INTO app_events (user_id, event_name, event_timestamp)
SELECT id, 'app_downloaded', created_at + interval '1 hour' FROM users;

-- Step 2: 80% verified email
INSERT INTO app_events (user_id, event_name, event_timestamp)
SELECT id, 'email_verified', created_at + interval '2 hours' FROM users
WHERE random() < 0.80;

-- Step 3: 60% uploaded KYC documents (The Friction Point)
INSERT INTO app_events (user_id, event_name, event_timestamp)
SELECT id, 'kyc_documents_uploaded', created_at + interval '1 day' FROM users
WHERE id IN (SELECT user_id FROM app_events WHERE event_name = 'email_verified')
AND random() < 0.60;

-- Step 4: 40% actually made their first deposit
INSERT INTO app_events (user_id, event_name, event_timestamp)
SELECT id, 'first_deposit_made', created_at + interval '2 days' FROM users
WHERE id IN (SELECT user_id FROM app_events WHERE event_name = 'kyc_documents_uploaded')
AND random() < 0.40;

-- DONE! The database now has massive, realistic amounts of structured data to test all analytical queries at scale.
