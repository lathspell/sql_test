-- 3. Write an SQL query to list Departments that have less than 3 people in it?

SELECT
  d.dept_name,
  count(*) as num_employee
FROM
  Department d
  inner join Employee e using (dept_id)
GROUP BY
  d.dept_name
HAVING
  count(*) < 3
;
