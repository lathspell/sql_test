-- 11. How to find 2nd highest salary without using a co-related subquery? (solution)

-- Using CROSS JOIN
SELECT
  max(e.salary) as second_highest_salary
FROM
  Employee e
  cross join Employee e2
WHERE
  e.salary < e2.salary
;

-- Using RANK in PostgreSQL
