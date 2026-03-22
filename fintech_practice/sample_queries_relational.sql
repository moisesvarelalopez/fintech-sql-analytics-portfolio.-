-- ==============================================================================
-- SQL Practice: Relational Bank Database
-- Database: relational_bank_practice.db
-- Tables: branches, customers, accounts, loans, transactions
-- ==============================================================================

-- 1. INNER JOIN: Get all customers and their assigned branch city
SELECT c.first_name, c.last_name, b.branch_name, b.city
FROM customers c
INNER JOIN branches b ON c.branch_id = b.branch_id
LIMIT 10;

-- 2. LEFT JOIN & Aggregation: Find the total account balance per customer
SELECT c.first_name, c.last_name, 
       COUNT(a.account_id) as total_accounts,
       SUM(a.balance) as total_balance
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id
ORDER BY total_balance DESC
LIMIT 10;

-- 3. Complex JOINs: List the latest 5 transactions for a specific customer (e.g., customer_id = 1)
SELECT c.first_name, a.account_type, t.transaction_type, t.amount, t.transaction_date
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
WHERE c.customer_id = 1
ORDER BY t.transaction_date DESC
LIMIT 5;

-- 4. Aggregate Function on Joins: Which branch has issued the highest total volume of loans?
SELECT b.branch_name, 
       COUNT(l.loan_id) as number_of_loans,
       SUM(l.loan_amount) as total_loan_volume
FROM branches b
JOIN customers c ON b.branch_id = c.branch_id
JOIN loans l ON c.customer_id = l.customer_id
GROUP BY b.branch_name
ORDER BY total_loan_volume DESC;

-- 5. Subqueries: Find customers who have a transaction larger than their maximum account balance
SELECT DISTINCT c.first_name, c.last_name
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
WHERE t.amount > (
    SELECT MAX(balance) 
    FROM accounts 
    WHERE customer_id = c.customer_id
);
