-- ============================================================
-- Optimization Step 1: Add targeted indexes
-- ============================================================

-- Index for user_id lookups (most common query pattern)
CREATE INDEX CONCURRENTLY idx_transactions_user_id
    ON transactions(user_id);

-- Composite index for user + date ordered queries
CREATE INDEX CONCURRENTLY idx_transactions_user_created
    ON transactions(user_id, created_at DESC);

-- Index for status filtering
CREATE INDEX CONCURRENTLY idx_transactions_status
    ON transactions(status);

-- Composite index for date range + status queries
CREATE INDEX CONCURRENTLY idx_transactions_created_status
    ON transactions(created_at DESC, status)
    WHERE status = 'COMPLETED';  -- Partial index — only completed transactions

-- Verify indexes were created
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'transactions'
ORDER BY indexname;
