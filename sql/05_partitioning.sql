-- ============================================================
-- Optimization Step 2: Table partitioning by month
-- Massive queries skip entire partitions they don't need
-- ============================================================

-- Create partitioned table
CREATE TABLE transactions_partitioned (
    id          UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id     VARCHAR(50) NOT NULL,
    amount      NUMERIC(19,4) NOT NULL,
    currency    VARCHAR(3) NOT NULL DEFAULT 'USD',
    status      VARCHAR(20) NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ
) PARTITION BY RANGE (created_at);

-- Create monthly partitions for the last 12 months
DO $$
DECLARE
    month_start DATE;
    month_end   DATE;
    partition_name TEXT;
BEGIN
    FOR i IN 0..11 LOOP
        month_start := DATE_TRUNC('month', NOW() - (i || ' months')::interval)::date;
        month_end   := month_start + INTERVAL '1 month';
        partition_name := 'transactions_' || TO_CHAR(month_start, 'YYYY_MM');

        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS %I PARTITION OF transactions_partitioned
             FOR VALUES FROM (%L) TO (%L)',
            partition_name, month_start, month_end
        );
    END LOOP;
END $$;

-- Migrate data from original table
INSERT INTO transactions_partitioned
SELECT * FROM transactions;

-- Add indexes on the partitioned table (applies to all partitions)
CREATE INDEX ON transactions_partitioned(user_id, created_at DESC);
CREATE INDEX ON transactions_partitioned(status) WHERE status = 'COMPLETED';

-- Partition pruning in action — only scans the relevant month partition
EXPLAIN ANALYZE
SELECT * FROM transactions_partitioned
WHERE created_at >= '2024-08-01'
  AND created_at < '2024-09-01'
  AND user_id = 'user-500';
