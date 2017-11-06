-- 7. Can you write an SQL query to find the second highest salary of Employee?

-- Using an uncorrelated subquery
SELECT
  max(e.salary) as second_highest_salary
FROM
  Employee e
WHERE
  e.salary != (SELECT max(salary) FROM Employee)
;

-- Would work in MySQL
SELECT salary  FROM (SELECT salary FROM Employee ORDER BY salary DESC LIMIT 2) AS emp ORDER BY salary LIMIT 1;