-- Recursive CTE to generate quadratic numbers
CREATE OR REPLACE VIEW powers_of_two AS
  WITH RECURSIVE tmp_rcsv(i) AS (
	SELECT 1                    -- seed for 2^0
	UNION ALL
	SELECT 2*i FROM tmp_rcsv    -- further numbers
  )
  SELECT i FROM tmp_rcsv;

-- Tests
CREATE EXTENSION IF NOT EXISTS pgtap;
SELECT is(
    array((SELECT i FROM powers_of_two LIMIT 5)),
    array [1, 2, 4, 8, 16]
);
