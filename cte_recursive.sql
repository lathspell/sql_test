-- Recursive CTE to generate quadratic numbers
WITH RECURSIVE tmp_rcsv(i) AS (
	SELECT 1                   -- seed
	UNION ALL
	SELECT 2*i FROM tmp_rcsv   -- further numbers
)
SELECT i FROM tmp_rcsv LIMIT 5;
