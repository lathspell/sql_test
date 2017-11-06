-- How to find all duplicate records from a table?

SELECT
  *
FROM
  Department d1
  inner join Department d2 using (dept_id)
WHERE
  d1.dept_name != d2.dept_name
  /* ... */
;

-- Solution: What they ment was using HAVING to filter rows that are
-- duplicate after all relevant columns where grouped using GROUP BY.

SELECT
  e.DEPT_ID,
  count(*) c
FROM
  Employee e
GROUP BY
  e.DEPT_ID
HAVING
  count(*) > 1
;