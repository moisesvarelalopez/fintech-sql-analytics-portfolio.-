/*
 * 01 - NET REVENUE REPORT BY USER
 * ------------------------------------------------------------
 * BUSINESS PROBLEM: 
 * Determine how much "real" (successful) money each user has processed on the platform.
 * 
 * FINTECH USAGE:
 * - Finance: Understand the baseline transactional volume (TPV - Total Payment Volume).
 * - Product: Identify the core revenue-generating user base.
 */

WITH UserRevenue AS (
    -- Step 1: Calculate total net revenue per user
    SELECT 
        user_id,
        SUM(amount) AS net_revenue
    FROM 
        transactions
    WHERE 
        status = 'completed'
    GROUP BY 
        user_id
)
-- Step 2: Join the totals with user information
SELECT 
    u.name AS user_name,
    u.email AS user_email,
    r.net_revenue
FROM 
    users u
JOIN 
    UserRevenue r ON u.id = r.user_id
ORDER BY 
    r.net_revenue DESC;
