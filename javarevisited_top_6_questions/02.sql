-- 2. Write an SQL query to find Employees who have the biggest salary in their Department?

-- Better with CTE or temporary table?
SELECT
  d.dept_name,
  e.emp_name,
  e.salary
FROM
  Department d
  inner join Employee e on (d.dept_id = e.dept_id)
WHERE
  e.salary = (SELECT max(e2.salary) FROM Employee e2 WHERE e2.dept_id = e.dept_id)
ORDER BY
  d.dept_name,
  e.emp_name
;
