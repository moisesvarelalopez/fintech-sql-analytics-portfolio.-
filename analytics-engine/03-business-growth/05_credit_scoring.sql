/*
 * 05 - CREDIT SCORING ENGINE (Segmentation & Account Health)
 * ------------------------------------------------------------
 * BUSINESS PROBLEM: 
 * Identify automatically which credit product tier or segment a user belongs to based on their historical behavioral metrics.
 * 
 * FINTECH USAGE:
 * - Lending (Credit Underwriting): Automatically grant premium credit cards or micro-loans based on this calculated "Score".
 * - CRM / Operations: Generate marketing cohorts to re-engage "Inactive" users.
 */

WITH user_metrics AS (
    -- Step 1: Calculate lifetime volume and transaction frequency
    SELECT 
        user_id,
        SUM(amount) AS total_spent,
        COUNT(*) AS transaction_count
    FROM 
        transactions
    WHERE 
        status = 'completed'
    GROUP BY 
        user_id
)
-- Step 2: Use a multi-conditional rule engine (CASE) factoring in Amount + Time constraints
SELECT 
    u.name AS customer_name,
    u.email AS contact_email,
    m.total_spent,
    m.transaction_count,
    CASE 
        -- "Whale" Segment: High volume AND high frequency guarantees reliable cash flow
        WHEN m.total_spent > 5000 AND m.transaction_count > 10 THEN 'Whale (Premium)'
        
        -- "Loyal" Segment: Consistent mid-tier volume
        WHEN m.total_spent BETWEEN 1000 AND 5000 THEN 'Loyal (Standard)'
        
        -- "New/Inactive" Segment: Low volume or recently onboarded
        WHEN m.total_spent < 1000 THEN 'New / Inactive'
        
        ELSE 'Unclassified' 
    END AS customer_segment,
    
    -- AOV (Average Order Value)
    ROUND((m.total_spent / NULLIF(m.transaction_count, 0)), 2) AS average_order_value
FROM 
    users u
JOIN 
    user_metrics m ON u.id = m.user_id
ORDER BY 
    m.total_spent DESC;
