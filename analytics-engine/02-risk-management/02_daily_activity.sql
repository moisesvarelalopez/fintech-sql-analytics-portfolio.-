/*
 * 02 - DAILY ACTIVITY & "STRUCTURING" DETECTION (AML)
 * ------------------------------------------------------------
 * BUSINESS PROBLEM: 
 * Detect accounts exhibiting unusually high transaction volume within a very short timeframe.
 * 
 * FINTECH USAGE:
 * - Compliance / AML: Identification of "Structuring" (Smurfing), which involves breaking down large transfers into smaller ones to evade automated red flags.
 * - Risk Management: Preventive heuristic account blocking.
 */

WITH daily_activity AS (
    -- Step 1: Group transactions by user and by day
    SELECT 
        user_id,
        transaction_date::DATE AS transaction_date,
        COUNT(*) AS transaction_count
    FROM 
        transactions
    WHERE 
        status = 'completed'
    GROUP BY 
        user_id,
        transaction_date::DATE
)
-- Step 2: Join with the users table and filter for the most active ones (e.g., > 3 per day)
SELECT 
    u.name AS user_name,
    a.transaction_date,
    a.transaction_count AS total_transactions
FROM 
    users u
JOIN 
    daily_activity a ON u.id = a.user_id
WHERE 
    a.transaction_count > 3
ORDER BY 
    a.transaction_count DESC, 
    a.transaction_date DESC;
