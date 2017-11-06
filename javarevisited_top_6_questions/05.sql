-- Can you write an SQL query to show all Employees that don't have a manager in the same department?

SELECT
  e.emp_name,
  e.dept_id,
  e2.emp_name,
  e2.dept_id
FROM
  Employee e
  inner join Employee e2 on (e.mngr_id = e2.emp_id)
WHERE
  e.dept_id != e2.dept_id
;
