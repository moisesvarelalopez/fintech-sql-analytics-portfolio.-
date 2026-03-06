# 00 - Data Setup & Cleaning

This module establishes the foundational data architecture and ensures data quality before any analysis begins.

## Key Operations
* **Database Schema Setup:** Defines the core tables, constraints, and relationships for the NeoBank system.
* **Data Sanitization:** Implements robust data cleaning protocols, including:
    * Handling `NULL` values to prevent calculation errors.
    * Deduplication of transactional records.
    * Normalization of date and text formats.

## Why this is critical
High-quality analysis is impossible without high-quality data. By implementing these cleaning procedures upfront, we ensure that subsequent financial reports and risk metrics are accurate, reliable, and trustworthy.