/*
 * 00 - DATA SANITIZATION & CLEANING SCRIPT
 * ------------------------------------------------------------
 * BUSINESS PROBLEM: 
 * Real-world data is messy. Users input blank spaces, uppercase/lowercase irregularly,
 * records get duplicated by API retries, and numerical values might be negative when they shouldn't.
 * 
 * FINTECH USAGE:
 * - Data Engineering: Normalizing data before it reaches the Data Warehouse to prevent reporting errors.
 * - KYC/AML: Ensuring user emails and names are standardized for proper cross-referencing against global watchlists.
 */

-- 1. HANDLING DUPLICATES (De-duplication)
-- Problem: An API retry might have inserted the same transaction twice.
-- Solution: Identify exact duplicates using ROW_NUMBER() and window functions.
WITH DeduplicatedTransactions AS (
    SELECT 
        id,
        user_id,
        amount,
        status,
        transaction_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, amount, status, transaction_date 
            ORDER BY id ASC
        ) as row_num
    FROM 
        transactions
)
-- Soft logic: Keep only the first instance of the transaction (row_num = 1)
-- In a real destructive update, you would DELETE WHERE row_num > 1
SELECT * 
FROM DeduplicatedTransactions 
WHERE row_num = 1;

-- 2. TEXT NORMALIZATION & NULL HANDLING
-- Problem: User inputs have trailing spaces, inconsistent casing, missing emails.
-- Solution: Use TRIM(), LOWER(), INITCAP(), and COALESCE() / NullIF().
SELECT 
    id AS user_id,
    
    -- Format names: Remove extra spaces and capitalize the first letter of each word (e.g., ' JOHN doe ' -> 'John Doe')
    -- Note: INITCAP() syntax may vary slightly by SQL dialect. Using a standard representation here.
    INITCAP(TRIM(name)) AS sanitized_name,
    
    -- Format emails: Always lowercase, remove spaces. Handle missing emails by assigning a default 'No Email Provided'
    COALESCE(LOWER(TRIM(email)), 'no_email_provided@domain.com') AS sanitized_email,
    
    -- Handle missing creation dates by defaulting to a known epoch or current timestamp
    COALESCE(created_at, CURRENT_TIMESTAMP) AS valid_creation_date

FROM 
    users;

-- 3. NUMERICAL VALIDATION & OUTLIER HANDLING
-- Problem: Transaction amounts should never be negative unless properly flagged, and system errors might insert NULLs.
SELECT 
    id AS transaction_id,
    user_id,
    
    -- Ensure amount is not null, default to 0.00
    COALESCE(amount, 0.00) AS valid_amount,
    
    -- Flag negative amounts which might indicate system errors or refunds mixed with deposits
    CASE 
        WHEN amount < 0 THEN 'Error: Negative Amount'
        WHEN amount IS NULL THEN 'Error: NULL Amount'
        ELSE 'Valid'
    END AS amount_validation_flag,
    
    status
FROM 
    transactions
WHERE 
    amount < 0 OR amount IS NULL; -- Query specifically alerting on invalid data formats
