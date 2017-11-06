-- 6. Can you write SQL query to list all Departments along with the total salary there?

SELECT
  d.dept_id,
  d.dept_name,
  sum(e.salary) as sum_salary
FROM
  Department d
  left outer join Employee e using (dept_id)
GROUP BY
  d.dept_id,
  d.dept_name
;
