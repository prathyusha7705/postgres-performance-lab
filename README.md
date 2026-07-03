# PostgreSQL Performance Lab

Real optimization techniques for high-volume PostgreSQL tables. Based on actual work at OnePay where I cut query times from 3-4 seconds to under 100ms on a 30 million row transactions table.

---

## What is inside

- 01_setup.sql — Creates a 1 million row transactions table for benchmarking
- 02_slow_queries.sql — Original slow queries with full table scans
- 03_add_indexes.sql — Adds composite and partial indexes
- 04_fast_queries.sql — Same queries now using indexes
- 05_partitioning.sql — Monthly range partitioning setup

---

## Results

| Query | Before | After | Improvement |
|-------|--------|-------|-------------|
| User history 50 rows | 3800ms | 8ms | 475x faster |
| User stats by status | 2100ms | 12ms | 175x faster |
| 30 day date range | 4200ms | 45ms | 93x faster |

---

## How to run locally

1. Install PostgreSQL or run via Docker
2. Connect to PostgreSQL
3. Run the SQL files in order from 01 to 05
4. Compare the EXPLAIN ANALYZE output between 02 and 04

---

## Key techniques used

- Composite indexes on user_id and created_at together
- Partial indexes only on completed transactions
- Monthly range partitioning so queries skip irrelevant data
- CONCURRENTLY keyword to add indexes without locking the table
