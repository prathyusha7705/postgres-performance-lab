-- ============================================================
-- postgres-performance-lab: Setup
-- Creates sample transactions table with 1M rows for benchmarking
-- ============================================================

CREATE TABLE IF NOT EXISTS transactions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     VARCHAR(50) NOT NULL,
    amount      NUMERIC(19,4) NOT NULL,
    currency    VARCHAR(3) NOT NULL DEFAULT 'USD',
    status      VARCHAR(20) NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ
);

-- Seed 1 million rows for realistic benchmarking
INSERT INTO transactions (user_id, amount, currency, status, description, created_at)
SELECT
    'user-' || (random() * 1000)::int,
    (random() * 10000)::numeric(10,2),
    'USD',
    (ARRAY['PENDING','COMPLETED','FAILED','REFUNDED'])[ceil(random()*4)::int],
    'Payment ' || generate_series,
    NOW() - (random() * interval '365 days')
FROM generate_series(1, 1000000);

SELECT COUNT(*) AS total_rows FROM transactions;
