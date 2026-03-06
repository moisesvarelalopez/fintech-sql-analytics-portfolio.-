/*
 * 04 - MONTH OVER MONTH (MoM) SPENDING EVOLUTION
 * ------------------------------------------------------------
 * BUSINESS PROBLEM: 
 * Analyze whether clients are increasing or decreasing their application usage over the course of several months.
 * 
 * FINTECH USAGE:
 * - Marketing/Growth Strategy: Measure user adoption and calculate the impact of churn and cross-selling.
 * - Advanced SQL Application: Usage of Window Functions (LAG) on time-series data.
 */

WITH monthly_spending AS (
    SELECT 
        user_id,
        EXTRACT(MONTH FROM transaction_date) AS month,
        SUM(amount) AS total_monthly_amount
    FROM transactions
    WHERE status = 'completed'
    GROUP BY user_id, EXTRACT(MONTH FROM transaction_date)
)
SELECT 
    user_id,
    month,
    total_monthly_amount,
    -- Retrieve the value from the previous month for the same user
    LAG(total_monthly_amount) OVER (PARTITION BY user_id ORDER BY month) AS previous_month_amount,
    
    -- Calculate the net difference
    (total_monthly_amount - LAG(total_monthly_amount) OVER (PARTITION BY user_id ORDER BY month)) AS absolute_difference,
    
    -- Calculate the MoM Growth Percentage
    ROUND(
        ((total_monthly_amount - LAG(total_monthly_amount) OVER (PARTITION BY user_id ORDER BY month)) 
        / NULLIF(LAG(total_monthly_amount) OVER (PARTITION BY user_id ORDER BY month), 0)
        ) * 100.0, 2
    ) AS growth_percentage_mom
FROM monthly_spending;
