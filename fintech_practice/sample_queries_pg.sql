-- ==============================================================================
-- ANSI SQL Practice: Relational Credit Scoring Database (PostgreSQL)
-- Database Name: finance_practice_db
-- Tables: branches, customers, credit_card_data, accounts, transactions
-- ==============================================================================

-- 1. Simple JOIN: Connect the original Credit Data to their Customer Profile
SELECT c.first_name, c.last_name, cc.age, cc.job, cc.amount as original_loan_amount
FROM customers c
INNER JOIN credit_card_data cc ON c.customer_id = cc.customer_id
LIMIT 10;

-- 2. Many-to-One Aggregation: Find out which Branch has the most total loan volume (using the original dataset's amount)
SELECT b.branch_name, b.city, 
       SUM(cc.amount) as total_credit_issued,
       COUNT(cc.credit_id) as total_applications
FROM branches b
JOIN customers c ON b.branch_id = c.branch_id
JOIN credit_card_data cc ON c.customer_id = cc.customer_id
GROUP BY b.branch_name, b.city
ORDER BY total_credit_issued DESC;

-- 3. Complex Multi-Join & CTE: Find customers whose original credit loan amount is MORE than all their checking/savings balances combined
WITH CustomerBalances AS (
    SELECT customer_id, SUM(balance) as total_balance
    FROM accounts
    GROUP BY customer_id
)
SELECT c.first_name, c.last_name, 
       cc.amount as credit_loan_amount, 
       cb.total_balance
FROM customers c
JOIN credit_card_data cc ON c.customer_id = cc.customer_id
JOIN CustomerBalances cb ON c.customer_id = cb.customer_id
WHERE cc.amount > cb.total_balance
ORDER BY credit_loan_amount DESC
LIMIT 15;

-- 4. Window Function on New Transactions: Running total of transaction amounts per checking account
SELECT t.account_id, 
       t.transaction_date, 
       t.amount,
       t.transaction_type,
       SUM(t.amount) OVER (PARTITION BY t.account_id ORDER BY t.transaction_date) as running_total
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE a.account_type = 'Checking'
LIMIT 20;
