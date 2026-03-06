/*
 * 06 - NIGHT AUDIT & RISK MONITORING
 * ------------------------------------------------------------
 * BUSINESS PROBLEM: 
 * Identify anomalous transactions that occur while the majority of the local user demographic is asleep.
 * 
 * FINTECH USAGE:
 * - Fraud Prevention: Account Takeover (ATO) mitigation, defense against credential stuffing or social engineering (Phishing).
 * - Compliance: Regulatory requirement to monitor and flag unusual cross-border or off-hour fund flows to the AML team.
 */

WITH night_audit AS (
    -- Extract the hour and isolate high-risk timeframes (11:00 PM - 5:00 AM)
    SELECT 
        user_id,
        amount,
        transaction_date,
        EXTRACT(HOUR FROM transaction_date) AS transaction_hour
    FROM 
        transactions
    WHERE 
        (EXTRACT(HOUR FROM transaction_date) >= 23 OR EXTRACT(HOUR FROM transaction_date) < 5)
        AND status = 'completed'
)
-- Join with the users table to pinpoint the compromised or suspicious accounts
SELECT 
    u.name AS suspicious_customer,
    u.email AS contact_info,
    a.amount AS transaction_amount,
    a.transaction_date AS exact_datetime,
    a.transaction_hour
FROM 
    users u
JOIN 
    night_audit a ON u.id = a.user_id
ORDER BY 
    a.amount DESC,
    a.transaction_date DESC;
