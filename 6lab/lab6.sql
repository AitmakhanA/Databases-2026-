-- Exercise 2.1

SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;
-- 5*4=20 

-- a

SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- b

SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;

-- Exercise 2.3

SELECT e.emp_name, p.project_name
FROM employees e
CROSS JOIN projects p;

-- Exercise 3.1

SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id;

-- 4 rows.
-- Tom Brown is not included because dept_id is NULL.

-- Exercise 3.2

SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);

-- Exercise 3.3

SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;


-- Exercise 3.4

SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id
INNER JOIN projects p
    ON d.dept_id = p.dept_id;



-- Exercise 4.1

SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id;

-- Exercise 4.2

SELECT
    emp_name,
    dept_id,
    dept_name
FROM employees
LEFT JOIN departments USING (dept_id);


-- Exercise 4.3

SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;


-- Exercise 4.4

SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;


-- Exercise 5.1

SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d
    ON e.dept_id = d.dept_id;


-- Exercise 5.2

SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id;


-- Exercise 5.3

SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d
    ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;




-- Exercise 6.1

SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
FULL JOIN departments d
    ON e.dept_id = d.dept_id;


-- Exercise 6.2

SELECT
    d.dept_name,
    p.project_name,
    p.budget
FROM departments d
FULL JOIN projects p
    ON d.dept_id = p.dept_id;


-- Exercise 6.3

SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d
    ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL
   OR d.dept_id IS NULL;



-- Exercise 7.1

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id
    AND d.location = 'Building A';


-- Exercise 7.2

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';


-- Exercise 7.3a

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id
    AND d.location = 'Building A';


-- Exercise 7.3b: INNER JOIN with filter in WHERE

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';



-- Exercise 8.1

SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
LEFT JOIN projects p
    ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;




SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.emp_id;


-- Exercise 8.3

SELECT
    d.dept_name,
    s.avg_salary
FROM departments d
INNER JOIN
(
    SELECT
        dept_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
    HAVING AVG(salary) > 50000
) s
    ON d.dept_id = s.dept_id;


-- 1. INNER JOIN returns only matching rows.
--    LEFT JOIN returns all rows from the left table
--    and matching rows from the right table.

-- 2. CROSS JOIN is useful for creating all possible
--    combinations.

-- 3. In OUTER JOIN, ON filters matching rows before
--    unmatched rows are preserved.
--    WHERE filters the final result and can remove
--    rows with NULL values.
--    For INNER JOIN, these filters usually give
--    the same result.

-- 4. 5 * 10 = 50 rows.

-- 5. NATURAL JOIN automatically joins using all
--    columns that have the same names in both tables.

-- 6. NATURAL JOIN can accidentally use additional
--    same-named columns and produce unexpected results.

-- 7. LEFT JOIN:
--    SELECT *
--    FROM A LEFT JOIN B ON A.id = B.id;
--
--    RIGHT JOIN:
--    SELECT *
--    FROM B RIGHT JOIN A ON A.id = B.id;

-- 8. FULL OUTER JOIN is useful when we need all rows
--    from both tables, including unmatched rows.
