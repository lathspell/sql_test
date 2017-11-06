-- Write an SQL query to show all Departments along with the number of people there?

-- 1st try: WRONG as forgets empty Departments!
SELECT
  d.dept_name,
  count(*) as num_employee
FROM
  Department d
  inner join Employee e using (dept_id)
GROUP BY
  d.dept_name
;

-- 2nd try
SELECT
  d.dept_name,
  count(e.dept_id) as num_employee
FROM
  Department d
  left outer join Employee e using (dept_id)
GROUP BY
  d.dept_name
;
