# PostgreSQL Performance Lab

Benchmarks, before/after comparisons, and real optimization techniques for high-volume PostgreSQL tables. Based on actual optimization work at OnePay where I cut query times from **3-4 seconds → sub-100ms** on a 30M row transactions table.

## What's inside

| File | What it does |
|------|-------------|
| `sql/01_setup.sql` | Creates a 1M row transactions table for benchmarking |
| `sql/02_slow_queries.sql` | Original slow queries — full table scans |
| `sql/03_add_indexes.sql` | Adds composite and partial indexes |
| `sql/04_fast_queries.sql` | Same queries — now using indexes |
| `sql/05_partitioning.sql` | Monthly range partitioning setup |

## Results

| Query | Before | After | Improvement |
|-------|--------|-------|-------------|
| User history (50 rows) | ~3,800ms | ~8ms | **475x faster** |
| User stats by status | ~2,100ms | ~12ms | **175x faster** |
| 30-day completed range | ~4,200ms | ~45ms | **93x faster** |

## Run locally

```bash
# Start PostgreSQL
docker run -d --name pg-lab -e POSTGRES_PASSWORD=password -p 5432:5432 postgres:16

# Connect
psql -h localhost -U postgres

# Run scripts in order
\i sql/01_setup.sql
\i sql/02_slow_queries.sql   -- see the slow plans
\i sql/03_add_indexes.sql    -- add indexes
\i sql/04_fast_queries.sql   -- see the fast plans
\i sql/05_partitioning.sql   -- try partitioning
```

## Key techniques used

**Composite indexes** — Index on `(user_id, created_at DESC)` supports both filtering by user AND sorting by date in a single index scan instead of a sort step.

**Partial indexes** — `WHERE status = 'COMPLETED'` on the date index means the index is smaller and only covers rows the query actually needs.

**Range partitioning** — Monthly partitions let PostgreSQL skip entire partitions when filtering by date. A query for "last 30 days" only touches 1-2 partitions instead of all 1M rows.

**CONCURRENTLY** — Always add production indexes with `CREATE INDEX CONCURRENTLY` to avoid locking the table while indexing.
