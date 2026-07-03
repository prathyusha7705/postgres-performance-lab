-- ============================================================
-- BEFORE optimization: queries that cause full table scans
-- Run EXPLAIN ANALYZE on each to see the query plan
-- ============================================================

-- Query 1: Get user transaction history (SLOW — sequential scan)
EXPLAIN ANALYZE
SELECT * FROM transactions
WHERE user_id = 'user-500'
ORDER BY created_at DESC
LIMIT 50;
-- Expected: Seq Scan, cost ~3000-4000ms on 1M rows

-- Query 2: Count by status (SLOW)
EXPLAIN ANALYZE
SELECT status, COUNT(*), SUM(amount)
FROM transactions
WHERE user_id = 'user-500'
GROUP BY status;

-- Query 3: Date range query (SLOW)
EXPLAIN ANALYZE
SELECT * FROM transactions
WHERE created_at >= NOW() - INTERVAL '30 days'
  AND status = 'COMPLETED'
ORDER BY created_at DESC;
