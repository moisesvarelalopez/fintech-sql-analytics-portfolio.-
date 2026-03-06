/*
 * 08 - BANK RECONCILIATION & DATA QA 
 * ------------------------------------------------------------
 * BUSINESS PROBLEM: 
 * Our internal database does not always reflect the same reality as the External Payment Gateway (Stripe, Central Bank, SWIFT).
 * 
 * FINTECH USAGE:
 * - Operations / Finance: Automate the discovery of "ghost money", amount discrepancies, or dropped webhooks.
 * - Quality Assurance (QA): Trigger real-time alerts regarding failing payment APIs.
 */

SELECT 
    t.id AS internal_trx_id,
    e.gateway_trx_id,
    t.amount AS internal_amount,
    e.amount AS external_bank_amount,
    t.status AS internal_status,
    e.status AS external_status
FROM transactions t
-- We use a FULL OUTER JOIN to avoid losing blind spots from either internal or external ecosystems
FULL OUTER JOIN external_gateway_logs e ON t.id = e.internal_trx_id
WHERE 
    /* DISCREPANCY SCENARIOS (THE AUDIT TRIGGERS) */
    
    -- Case 1: Amounts differ (Usually due to hidden micro-commissions in the bridge or currency exchange float errors).
    t.amount != e.amount 
    
    -- Case 2: The asynchronous systems contradict each other (e.g., Completed internally, Failed externally).
    OR t.status != e.status
    
    -- Case 3: A record exists in the external processor, but we don't have it (Incoming ghost money, orphan webhooks).
    OR t.id IS NULL
    
    -- Case 4: We recorded a successful payment to the user, but the external gateway has no knowledge of it.
    OR e.gateway_trx_id IS NULL;
