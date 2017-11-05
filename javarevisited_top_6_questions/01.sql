-- 1. Can you write an SQL query to show Employee (names) who have a bigger salary than their manager?

SELECT
  e.emp_name
FROM
  Employee e
  inner join Employee m on (e.mngr_id = m.emp_id)
WHERE
  e.salary > m.salary
;
