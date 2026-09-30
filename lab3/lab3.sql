-- Part A
CREATE DATABASE advanced_lab;

CREATE TABLE employees 
(
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(100),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments 
(
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects 
(
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

--Part B

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'Alikhan', 'Aitmakhan', 'IT');


INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Aruzhan', 'Serikova', 'Sales', DEFAULT, '2022-05-10', DEFAULT);


INSERT INTO departments (dept_name, budget, manager_id)
VALUES ('IT', 150000, 1),('Sales', 120000, 2), ('HR', 80000, 3);



INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Dias', 'Nurgaliyev', 'IT', 50000 * 1.1, CURRENT_DATE);


CREATE TEMPORARY TABLE temp_employees 
(
    emp_id INTEGER,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(100),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20)
);

INSERT INTO temp_employees SELECT * FROM employees WHERE department = 'IT';

-- Part C

UPDATE employees
SET salary = salary * 1.10;


UPDATE employees SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';



UPDATE employees
SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;



UPDATE employees SET department = DEFAULT
WHERE status = 'Inactive';


UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
);



UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- Part D
DELETE FROM employees
WHERE status = 'Terminated';



DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;


DELETE FROM departments
WHERE dept_name NOT IN 
(
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);



DELETE FROM projects WHERE end_date < '2023-01-01'RETURNING *;

-- Part E
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Aibek', 'Sarsenov', NULL, NULL, '2024-03-15');



UPDATE employees SET department = 'Unassigned' WHERE department IS NULL;


DELETE FROM employees
WHERE salary=NULL OR department= NULL;

--Part F

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Nursultan', 'Amanov', 'IT', 70000, '2022-09-01')
RETURNING emp_id, first_name || ' ' || last_name AS full_name;



UPDATE employees SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id,
          salary - 5000 AS old_salary,
          salary AS new_salary;



DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- Part G


INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
SELECT
    'Aruzhan', 'Tulegenova', 'IT', 65000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'Aruzhan'
      AND last_name = 'Tulegenova'
);



UPDATE employees e
SET salary = salary *
    CASE
        WHEN (
            SELECT d.budget
            FROM departments d
            WHERE d.dept_name = e.department
        ) > 100000
        THEN 1.10
        ELSE 1.05
    END
WHERE EXISTS (
    SELECT 1
    FROM departments d
    WHERE d.dept_name = e.department
);



INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
VALUES
    ('Dias', 'Sultanov', 'IT', 60000, '2023-01-10'),
    ('Aigerim', 'Nurlanova', 'Sales', 55000, '2022-04-15'),
    ('Almas', 'Bekov', 'HR', 50000, '2021-08-20'),
    ('Dana', 'Serikova', 'IT', 70000, '2020-11-05'),
    ('Miras', 'Akhmetov', 'Sales', 65000, '2022-02-12');

UPDATE employees
SET salary = salary * 1.10
WHERE (first_name, last_name) IN (
    ('Dias', 'Sultanov'),
    ('Aigerim', 'Nurlanova'),
    ('Almas', 'Bekov'),
    ('Dana', 'Serikova'),
    ('Miras', 'Akhmetov')
);



CREATE TABLE employee_archive (
    emp_id INTEGER,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(100),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20)
);

INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';



UPDATE projects p SET end_date = end_date + INTERVAL '30 days' WHERE budget > 50000
AND (
      SELECT COUNT(*)
      FROM employees e
      JOIN departments d
        ON e.department = d.dept_name
      WHERE d.dept_id = p.dept_id
  ) > 3;