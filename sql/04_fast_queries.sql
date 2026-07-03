-- ============================================================
-- AFTER optimization: same queries, now using indexes
-- Compare the EXPLAIN ANALYZE output vs 02_slow_queries.sql
-- ============================================================

-- Query 1: User history — now uses idx_transactions_user_created
EXPLAIN ANALYZE
SELECT * FROM transactions
WHERE user_id = 'user-500'
ORDER BY created_at DESC
LIMIT 50;
-- Expected: Index Scan, cost <10ms

-- Query 2: Count by status — uses idx_transactions_user_id
EXPLAIN ANALYZE
SELECT status, COUNT(*), SUM(amount)
FROM transactions
WHERE user_id = 'user-500'
GROUP BY status;

-- Query 3: Date range — uses partial index idx_transactions_created_status
EXPLAIN ANALYZE
SELECT * FROM transactions
WHERE created_at >= NOW() - INTERVAL '30 days'
  AND status = 'COMPLETED'
ORDER BY created_at DESC;
