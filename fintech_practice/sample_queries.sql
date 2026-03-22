-- ==============================================================================
-- SQL Practice: Credit Scoring Dataset
-- Database: finance_practice.db
-- Table: credit_card_data
-- ==============================================================================

-- 1. Basic SELECT: View the first 10 rows
SELECT * 
FROM credit_card_data 
LIMIT 10;

-- 2. Filtering (WHERE): Find applicants with an income greater than 200
SELECT age, job, income, amount
FROM credit_card_data
WHERE income > 200
ORDER BY income DESC;

-- 3. Aggregation (GROUP BY): Understand average loan amount by marital status
SELECT marital, 
       COUNT(*) as applicant_count, 
       AVG(amount) as avg_loan_amount
FROM credit_card_data
GROUP BY marital
ORDER BY applicant_count DESC;

-- 4. Filtering and Aggregation: Look at the debt-to-income distribution for those with high debt
SELECT seniority, 
       age, 
       debt, 
       income, 
       CAST(debt AS FLOAT) / (income + 1) as debt_to_income_ratio -- +1 to avoid div by zero
FROM credit_card_data
WHERE debt > 1000
ORDER BY debt DESC
LIMIT 15;

-- 5. Case Statements: Categorize applicants into Age Groups
SELECT 
    CASE 
        WHEN age < 30 THEN 'Young Adult (<30)'
        WHEN age BETWEEN 30 AND 50 THEN 'Adult (30-50)'
        ELSE 'Senior (>50)'
    END AS age_group,
    COUNT(*) as total_applicants,
    AVG(expenses) as avg_expenses
FROM credit_card_data
GROUP BY age_group;
