-- 2. Write an SQL query to find Employees who have the biggest salary in their Department?

-- Better with CTE or temporary table?
SELECT
  e.emp_name,
  e.dept_id,
  e.salary
FROM
  Employee e
WHERE
  e.salary = (SELECT max(e2.salary) FROM Employee e2 WHERE e2.dept_id = e.dept_id)
ORDER BY
  e.dept_id,
  e.emp_name
;

-- No CTE in Derby so Subquery-Join like in Solution
SELECT
  e.emp_name,
  e.dept_id,
  e.salary
FROM
  Employee e
  inner join (
    SELECT 
      mse.dept_id, 
      max(mse.salary) as max_salary 
    FROM
      Employee mse
    GROUP BY
      mse.dept_id
   ) sub on (e.dept_id = sub.dept_id and e.salary = sub.max_salary)
ORDER BY
  e.dept_id,
  e.emp_name
;

-- Solution
SELECT
  a.emp_name,  
  a.dept_id,
  a.salary 
FROM 
  Employee a 
  JOIN (
    SELECT 
      a.dept_id,
      MAX(salary) as max_salary
    FROM 
      Employee a
      JOIN Department b ON (a.dept_id = b.dept_id)
    GROUP BY 
      a.dept_id
    ) b ON (a.salary = b.max_salary AND a.dept_id = b.dept_id)
;
