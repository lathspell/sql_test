-- create table ddl statments
CREATE TABLE Employee(
    emp_id INTEGER PRIMARY KEY,
    dept_id INTEGER,
    mngr_id INTEGER,
    emp_name VARCHAR(20),
    salary INTEGER);

CREATE TABLE Department(
    dept_id INTEGER PRIMARY KEY,
    dept_name VARCHAR(20));

-- alter table to add foreign keys
ALTER TABLE Employee ADD FOREIGN KEY (mngr_id) REFERENCES Employee(emp_id);
ALTER TABLE Employee ADD FOREIGN KEY (dept_id) REFERENCES Department(dept_id);

-- populating department table with sample data
INSERT INTO Department (dept_id, dept_name) VALUES
(1, 'Finance'),
(2, 'Legal'),
(3, 'IT'),
(4, 'Admin'),
(5, 'Empty Department');

-- populating employee table with sample data
INSERT INTO Employee(emp_id, dept_id, mngr_id, emp_name, salary) VALUES
( 1, 1, 1, 'CEO', 100),
( 2, 3, 1, 'CTO', 95),
( 3, 2, 1, 'CFO', 100),
( 4, 3, 2, 'Java Developer', 90),
( 5, 3, 2, 'DBA', 90),
( 6, 4, 1, 'Adm 1', 20),
( 7, 4, 1, 'Adm 2', 110),
( 8, 3, 2, 'Web Developer', 50),
( 9, 3, 1, 'Middleware', 60),
( 10, 2, 3, 'Legal 1', 110),
( 11, 3, 3, 'Network', 80),
( 12, 3, 1, 'UNIX', 200);
