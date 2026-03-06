/*
 * 03 - CUSTOMER PROFITABILITY & COMMISSIONS ENGINE
 * ------------------------------------------------------------
 * BUSINESS PROBLEM: 
 * Calculate exactly how much in commissions the bank earned based on different conditional tiers (rules) related to transferred amounts.
 * 
 * FINTECH USAGE:
 * - Pricing Analytics: Simulate and record gross income based on pricing tiers.
 * - Strategy: Detect which clients generate the highest margins to target them with VIP loyalty campaigns (Tiering).
 */

WITH commission_calculation AS (
    -- Step 1: Calculate the individual commission for each transaction using an embedded pricing rule engine
    SELECT 
        user_id,
        amount,
        CASE 
            WHEN amount < 100 THEN amount * 0.02 -- 2% fee for amounts under $100
            WHEN amount >= 100 THEN amount * 0.01 -- 1% fee for amounts $100 or higher
            ELSE 0 
        END AS applied_commission
    FROM 
        transactions
    WHERE 
        status = 'completed'
)
-- Step 2: Sum commissions by user to discover the most profitable clients
SELECT 
    u.name AS client_name,
    u.email AS email_address,
    SUM(c.applied_commission) AS total_profitability
FROM 
    users u
JOIN 
    commission_calculation c ON u.id = c.user_id
GROUP BY 
    u.id, 
    u.name, 
    u.email
ORDER BY 
    total_profitability DESC;
