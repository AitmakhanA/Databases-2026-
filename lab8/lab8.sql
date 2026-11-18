-- PART 2: CREATING BASIC INDEXES

-- Exercise 2.1
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- Answer: 2 indexes, employees_pkey and emp_salary_idx.

-- Exercise 2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;

-- Answer: Foreign key indexes improve JOINs and filtering.

-- Exercise 2.3
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Answer: departments_pkey, employees_pkey,
-- projects_pkey were created automatically.
-- emp_salary_idx and emp_dept_idx were created manually.


-- PART 3: MULTICOLUMN INDEXES

-- Exercise 3.1
CREATE INDEX emp_dept_salary_idx
ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

-- Answer: Less useful for salary-only queries
-- because dept_id is the leading column.

-- Exercise 3.2
CREATE INDEX emp_salary_dept_idx
ON employees(salary, dept_id);

SELECT *
FROM employees
WHERE dept_id = 102 AND salary > 50000;

SELECT *
FROM employees
WHERE salary > 50000 AND dept_id = 102;

-- Answer: Index column order matters.
-- WHERE condition order does not matter.


-- PART 4: UNIQUE INDEXES

-- Exercise 4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
-- VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

-- Answer: ERROR: duplicate key value violates unique constraint.

-- Exercise 4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees'
AND indexname LIKE '%phone%';

-- Answer: PostgreSQL automatically creates a unique B-tree index.


-- PART 5: INDEXES AND SORTING

-- Exercise 5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- Answer: The index can avoid a separate sorting operation.

-- Exercise 5.2
CREATE INDEX proj_budget_nulls_first_idx
ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;


-- PART 6: INDEXES ON EXPRESSIONS

-- Exercise 6.1
CREATE INDEX emp_name_lower_idx
ON employees(LOWER(emp_name));

SELECT *
FROM employees
WHERE LOWER(emp_name) = 'john smith';

-- Answer: Without the index, PostgreSQL may use a Seq Scan.

-- Exercise 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx
ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


-- PART 7: MANAGING INDEXES

-- Exercise 7.1
ALTER INDEX emp_salary_idx
RENAME TO employees_salary_index;

SELECT indexname
FROM pg_indexes
WHERE tablename = 'employees';

-- Exercise 7.2
DROP INDEX emp_salary_dept_idx;

-- Answer: Unused indexes waste space and slow down writes.

-- Exercise 7.3
REINDEX INDEX employees_salary_index;

-- Answer: REINDEX is useful for bloated or corrupted indexes.


-- PART 8: PRACTICAL SCENARIOS

-- Exercise 8.1
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

CREATE INDEX emp_salary_filter_idx
ON employees(salary)
WHERE salary > 50000;

EXPLAIN
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

-- Exercise 8.2
CREATE INDEX proj_high_budget_idx
ON projects(budget)
WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

-- Answer: Partial indexes use less space and maintenance
-- by indexing only matching rows.

-- Exercise 8.3
EXPLAIN
SELECT *
FROM employees
WHERE salary > 52000;

-- Answer: Index Scan uses an index; Seq Scan scans the table.
-- The actual plan depends on PostgreSQL's cost estimates.


-- PART 9: INDEX TYPES COMPARISON

-- Exercise 9.1
CREATE INDEX dept_name_hash_idx
ON departments USING HASH (dept_name);

SELECT *
FROM departments
WHERE dept_name = 'IT';

-- Answer: HASH supports equality only;
-- B-tree also supports range queries and ordering.

-- Exercise 9.2
CREATE INDEX proj_name_btree_idx ON projects(proj_name);

CREATE INDEX proj_name_hash_idx
ON projects USING HASH (proj_name);

SELECT *
FROM projects
WHERE proj_name = 'Website Redesign';

SELECT *
FROM projects
WHERE proj_name > 'Database';

-- Answer: Both support equality; only B-tree supports ranges.


-- PART 10: CLEANUP AND BEST PRACTICES

-- Exercise 10.1
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

SELECT
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexname::regclass) DESC
LIMIT 1;

-- Answer: The largest index depends on actual data and storage.
-- Several indexes may have equal sizes.

-- Exercise 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;

-- Exercise 10.3
CREATE OR REPLACE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;


-- SUMMARY QUESTIONS

-- 1. B-tree.
-- 2. WHERE filtering, JOINs, ORDER BY.
-- 3. Very small tables; rarely queried columns.
-- 4. Indexes are maintained, increasing write overhead.
-- 5. EXPLAIN or EXPLAIN ANALYZE.


-- ADDITIONAL CHALLENGES (OPTIONAL)

-- Challenge 1
CREATE INDEX emp_hire_month_idx
ON employees(EXTRACT(MONTH FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(MONTH FROM hire_date) = 1;

-- Challenge 2
CREATE UNIQUE INDEX emp_dept_email_unique_idx
ON employees(dept_id, email);

-- Challenge 3
EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE salary > 52000;

DROP INDEX emp_salary_filter_idx;

EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE salary > 52000;

CREATE INDEX emp_salary_filter_idx
ON employees(salary)
WHERE salary > 50000;

-- Answer: Other salary indexes still exist,
-- so this is not a fully index-free comparison.

-- Challenge 4
CREATE INDEX emp_dept_cover_idx
ON employees(dept_id)
INCLUDE (emp_name, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101;


-- REFLECTION
-- Indexes improve read performance but consume storage
-- and add overhead to INSERT, UPDATE, DELETE.
-- Use EXPLAIN ANALYZE to check their effectiveness.
