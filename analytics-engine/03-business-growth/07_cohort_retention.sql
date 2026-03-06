/*
 * 07 - COHORT RETENTION ANALYSIS
 * ------------------------------------------------------------
 * BUSINESS PROBLEM: 
 * Measure the true long-term impact of marketing acquisition campaigns. 
 * E.g., Do users acquired in January keep transacting in March?
 * 
 * FINTECH USAGE:
 * - User Retention Rate: The primary metric utilized to raise venture capital from VCs.
 * - Product Management: Understand the Lifetime Value (LTV) lifecycle and structural platform decay.
 */

WITH first_transaction_month AS (
    -- Group 1: Define the "Birthday/Activation" Date (The Cohort)
    SELECT 
        user_id,
        DATE_TRUNC('month', MIN(transaction_date)) AS cohort_month
    FROM transactions
    WHERE status = 'completed'
    GROUP BY user_id
),
monthly_active_usage AS (
    -- Group 2: Distinct months where the account operated successfully
    SELECT DISTINCT
        user_id,
        DATE_TRUNC('month', transaction_date) AS activity_month
    FROM transactions
    WHERE status = 'completed'
)
-- Intersection: Calculate the delta in months since the initial cohort baseline
SELECT 
    p.cohort_month AS acquisition_period,
    EXTRACT(MONTH FROM AGE(a.activity_month, p.cohort_month)) AS months_since_onboarding,
    COUNT(DISTINCT a.user_id) AS active_users
FROM first_transaction_month p
JOIN monthly_active_usage a ON p.user_id = a.user_id
GROUP BY p.cohort_month, months_since_onboarding
ORDER BY p.cohort_month, months_since_onboarding;
