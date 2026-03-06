#  Fintech SQL Analytics Portfolio

Welcome to my Data Analytics portfolio focused on the **Fintech Niche**. 
This repository contains real-world use cases and advanced SQL queries that solve critical business problems for modern financial institutions.

## Project Objective
To demonstrate proficiency in financial data management and analytics through data extraction, transformation, and modeling in SQL. The included queries address 5 fundamental pillars in any Fintech:
1. **Finance**: Net revenue, banking reconciliations, and discrepancies.
2. **Security / Risk (AML)**: Fraud detection, money laundering, and "structuring" (smurfing).
3. **Product Metrics**: Cohort retention analysis, KYC conversion funnels.
4. **Marketing**: User segmentation (Credit Scoring), LTV, and average order value.
5. **Compliance**: Nightly transaction auditing for anomalous schedules.

---

## Project Structure

All scripts are located in the `src/` folder, logically organized by use case:

- `00_setup_database.sql`: Mock data generation (DDL & Main Tables).
- `00_data_cleaning.sql`: **[NEW]** Data sanitization: duplication handling, NULL management, and string normalization.
- `01_net_revenue.sql`: Net Revenue calculation using Common Table Expressions (CTEs).
- `02_daily_activity.sql`: "Structuring" / Smurfing detection and high-frequency transaction alerts.
- `03_profitability_commissions.sql`: Customer Profitability analysis simulating a Pricing Engine.
- `04_mom_spending_growth.sql`: Month-over-Month (MoM) Growth utilizing Window Functions (LAG).
- `05_credit_scoring.sql`: Scoring Engine classifying VIPs ("Whales") vs. standard users.
- `06_night_audit.sql`: Nightly Transaction Monitoring (Account Takeover / AML).
- `07_cohort_retention.sql`: Monthly Cohort Retention Analysis.
- `08_bank_reconciliation.sql`: Financial reconciliation with external payment gateways (FULL OUTER JOIN approach).
- `09_kyc_conversion_funnel.sql`: Conversion rates across the identity verification (KYC) funnel.

## Applied Technologies
- **Language**: Standard SQL (Compatible with PostgreSQL / Snowflake / BigQuery)
- **Advanced Techniques**: CTEs, Window Functions (LAG, OVER, PARTITION), Date/Time manipulation, advanced CASE Statements, FULL OUTER JOINs for Data QA, and string normalization.

Feel free to explore the code! Each script includes comments explaining the **business problem it solves** and the **technical logic implemented**.
