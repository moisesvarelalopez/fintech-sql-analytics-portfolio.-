/*
 * 09 - KYC (KNOW YOUR CUSTOMER) CONVERSION FUNNEL
 * ------------------------------------------------------------
 * BUSINESS PROBLEM: 
 * Users tend to drop off during the bureaucratic and legal identity verification process (Uploading IDs, selfies).
 * 
 * FINTECH USAGE:
 * - Product Analytics: Identify exactly which step in the User Interface is scaring users away.
 * - Growth Strategy: Calculate the true Customer Acquisition Cost (CAC) for a fully verified and funded user account.
 */

WITH funnel_steps AS (
    -- Consolidate user event presence into a single flattened row (Event Vectorization)
    SELECT 
        user_id,
        MAX(CASE WHEN event_name = 'app_downloaded' THEN 1 ELSE 0 END) AS step_1_app_download,
        MAX(CASE WHEN event_name = 'email_verified' THEN 1 ELSE 0 END) AS step_2_email_verification,
        MAX(CASE WHEN event_name = 'kyc_documents_uploaded' THEN 1 ELSE 0 END) AS step_3_kyc_docs,
        MAX(CASE WHEN event_name = 'first_deposit_made' THEN 1 ELSE 0 END) AS step_4_first_deposit
    FROM app_events
    GROUP BY user_id
)
SELECT 
    -- Total User Volume at Each Funnel Stage (Drop-off observation)
    SUM(step_1_app_download) AS total_downloads,
    SUM(step_2_email_verification) AS total_emails_verified,
    SUM(step_3_kyc_docs) AS total_kyc_uploaded,
    SUM(step_4_first_deposit) AS total_first_deposits,
    
    -- Critical Conversion Rates
    
    -- 1. Global / End-to-End Conversion Rate (Download to Deposit)
    ROUND(SUM(step_4_first_deposit) * 100.0 / NULLIF(SUM(step_1_app_download), 0), 2) AS global_conversion_rate_pct,
    
    -- 2. Granular Drop-off: How successful is the Document Upload step specifically?
    ROUND(SUM(step_3_kyc_docs) * 100.0 / NULLIF(SUM(step_2_email_verification), 0), 2) AS document_upload_success_rate_pct
FROM funnel_steps;
