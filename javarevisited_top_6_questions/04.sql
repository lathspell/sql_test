-- Write an SQL query to show all Departments along with the number of people there?

SELECT
  d.dept_name,
  count(*) as num_employee
FROM
  Department d
  inner join Employee e using (dept_id)
GROUP BY
  d.dept_name
;
