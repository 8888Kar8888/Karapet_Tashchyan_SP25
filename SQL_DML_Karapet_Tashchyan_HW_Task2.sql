--TaskN2

--2.1
CREATE TABLE table_to_delete AS
               SELECT 'veeeeeeery_long_string' || x AS col
               FROM generate_series(1,(10^7)::int) x; -- generate_series() creates 10^7 rows of sequential numbers from 1 to 10000000 (10^7)

            
--2.2
SELECT *, pg_size_pretty(total_bytes) AS total,
                                    pg_size_pretty(index_bytes) AS INDEX,
                                    pg_size_pretty(toast_bytes) AS toast,
                                    pg_size_pretty(table_bytes) AS TABLE
               FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
                               FROM (SELECT c.oid,nspname AS table_schema,
                                                               relname AS TABLE_NAME,
                                                              c.reltuples AS row_estimate,
                                                              pg_total_relation_size(c.oid) AS total_bytes,
                                                              pg_indexes_size(c.oid) AS index_bytes,
                                                              pg_total_relation_size(reltoastrelid) AS toast_bytes
                                              FROM pg_class c
                                              LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
                                              WHERE relkind = 'r'
                                              ) a
                                    ) a
               WHERE table_name LIKE '%table_to_delete%';
               

--2.3
DELETE FROM table_to_delete
               WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0; -- removes 1/3 of all rows

--2.3.1 -- It takes 14 seconds(updated rows 3333333)
 
--2.3.2
SELECT *, pg_size_pretty(total_bytes) AS total,
                                    pg_size_pretty(index_bytes) AS INDEX,
                                    pg_size_pretty(toast_bytes) AS toast,
                                    pg_size_pretty(table_bytes) AS TABLE
               FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
                               FROM (SELECT c.oid,nspname AS table_schema,
                                                               relname AS TABLE_NAME,
                                                              c.reltuples AS row_estimate,
                                                              pg_total_relation_size(c.oid) AS total_bytes,
                                                              pg_indexes_size(c.oid) AS index_bytes,
                                                              pg_total_relation_size(reltoastrelid) AS toast_bytes
                                              FROM pg_class c
                                              LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
                                              WHERE relkind = 'r'
                                              ) a
                                    ) a
               WHERE table_name LIKE '%table_to_delete%';

-- Rows before delete  - 10,000,565
-- Rows after delete - 6,666,507
-- Table Size before - 575 MB
-- Table Size after - 575 MB
-- Even though 1/3 of the rows were deleted, the table size did not decrease,the deleted rows remain as dead tuples, waiting for VACUUM to clean them up.


--2.3.3
VACUUM FULL VERBOSE table_to_delete;

--vacuuming "public.table_to_delete"
--"public.table_to_delete": found 0 removable, 6666667 nonremovable row versions in 73536 pages

--2.3.4
SELECT *, pg_size_pretty(total_bytes) AS total,
                                    pg_size_pretty(index_bytes) AS INDEX,
                                    pg_size_pretty(toast_bytes) AS toast,
                                    pg_size_pretty(table_bytes) AS TABLE
               FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
                               FROM (SELECT c.oid,nspname AS table_schema,
                                                               relname AS TABLE_NAME,
                                                              c.reltuples AS row_estimate,
                                                              pg_total_relation_size(c.oid) AS total_bytes,
                                                              pg_indexes_size(c.oid) AS index_bytes,
                                                              pg_total_relation_size(reltoastrelid) AS toast_bytes
                                              FROM pg_class c
                                              LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
                                              WHERE relkind = 'r'
                                              ) a
                                    ) a
               WHERE table_name LIKE '%table_to_delete%';

 -- The table's size decreased from 575 MB to 383 MB after VACUUM FULL. This means PostgreSQL reclaimed space by removing dead tuples, but there’s still some residual overhead (the table is still holding the TOAST data for large values)
--Total size before VACUUM FULL: 575 MB
--Total size after VACUUM FULL: 383 MB

--2.3.5

DROP TABLE IF EXISTS table_to_delete;

CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1, (10^7)::int) x;

--2.4.1

TRUNCATE table_to_delete;
--It takes 0.037 seconds
--Truncate is quicker , it does not scan the table

SELECT *, pg_size_pretty(total_bytes) AS total,
                                    pg_size_pretty(index_bytes) AS INDEX,
                                    pg_size_pretty(toast_bytes) AS toast,
                                    pg_size_pretty(table_bytes) AS TABLE
               FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
                               FROM (SELECT c.oid,nspname AS table_schema,
                                                               relname AS TABLE_NAME,
                                                              c.reltuples AS row_estimate,
                                                              pg_total_relation_size(c.oid) AS total_bytes,
                                                              pg_indexes_size(c.oid) AS index_bytes,
                                                              pg_total_relation_size(reltoastrelid) AS toast_bytes
                                              FROM pg_class c
                                              LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
                                              WHERE relkind = 'r'
                                              ) a
                                    ) a
               WHERE table_name LIKE '%table_to_delete%';

-- TRUNCATE successfully removed all rows, leaving the table empty, and freed up almost all the storage.
--The table now only occupies about 8 KB because it's an empty structure, but the TOAST storage is still there, as it holds the storage for large values (even though no rows remain).
--TRUNCATE is extremely fast compared to DELETE and has effectively removed all data with minimal overhead.


--Task 2.5.1

--   Operation	   Before	              					After
--Initial Table	-  Rows: ~10M	     				- Total Size: 575 MB
--      DELETE	-  Rows: ~10M		 				- Rows: ~6.67M 
--              - Total Size: 575 MB				- Total Size: 575 MB
--  VACUUM FULL	- Rows: ~6.67M						- Rows: ~6.67M
--				- Total Size: 575 MB				- Total Size: 383 MB
--    TRUNCATE	- Rows: ~10M						- Rows: 0
--				- Total Size: 575 MB				- Total Size: ~8 KB


