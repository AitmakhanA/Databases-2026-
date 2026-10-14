-- Task 1.1

CREATE TABLE employees
(
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

-- Task 1.2

CREATE TABLE products_catalog
(
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

-- Task 1.3:

CREATE TABLE bookings
(
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);


-- Task 1.4


INSERT INTO employees VALUES
(1, 'John', 'Smith', 25, 50000),
(2, 'Sarah', 'Johnson', 35, 65000);

-- Invalid age:violates age CHECK
-- INSERT INTO employees VALUES
-- (3, 'Timur', 'Brown', 17, 40000);

-- Invalid salary:violates salary CHECK
-- INSERT INTO employees VALUES
-- (4, 'Ali', 'Wilson', 30, -1000);


-- Valid products
INSERT INTO products_catalog VALUES
(1, 'Laptop', 500000, 450000),
(2, 'Phone', 300000, 250000);

-- Invalid regular_price:violates valid_discount
-- INSERT INTO products_catalog VALUES
-- (3, 'Tablet', -10000, 5000);

-- Invalid discount_price: violates valid_discount
-- INSERT INTO products_catalog VALUES
-- (4, 'Mouse', 10000, -500);

-- INSERT INTO products_catalog VALUES
-- (5, 'Keyboard', 15000, 20000);


-- Valid bookings
INSERT INTO bookings VALUES
(1, '2026-10-01', '2026-10-05', 2),
(2, '2026-11-10', '2026-11-15', 4);

-- Invalid guests: violates num_guests CHECK
-- INSERT INTO bookings VALUES
-- (3, '2026-10-01', '2026-10-05', 15);

-- Invalid dates: check_out_date must be later
-- INSERT INTO bookings VALUES
-- (4, '2026-10-10', '2026-10-05', 2);



-- Task 2.1:

CREATE TABLE customers
(
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- Task 2.2

CREATE TABLE inventory
(
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);


-- Task 2.3


INSERT INTO customers VALUES
(1, 'john@gmail.com', '+77011112233', '2026-01-10');


INSERT INTO customers VALUES
(2, 'sarah@gmail.com', NULL, '2026-02-15');

-- Invalid NULL email
-- INSERT INTO customers VALUES
-- (3, NULL, '+77033334444', '2026-03-01');

-- Invalid NULL customer_id
-- INSERT INTO customers VALUES
-- (NULL, 'test@gmail.com', NULL, '2026-03-01');

-- Invalid NULL registration_date
-- INSERT INTO customers VALUES
-- (4, 'test@gmail.com', NULL, NULL);



INSERT INTO inventory VALUES
(1, 'Laptop', 10, 450000, CURRENT_TIMESTAMP),
(2, 'Mouse', 0, 5000, CURRENT_TIMESTAMP);

-- Invalid NULL item_name
-- INSERT INTO inventory VALUES
-- (3, NULL, 5, 10000, CURRENT_TIMESTAMP);

-- Invalid NULL quantity
-- INSERT INTO inventory VALUES
-- (4, 'Keyboard', NULL, 12000, CURRENT_TIMESTAMP);

-- Invalid negative quantity
-- INSERT INTO inventory VALUES
-- (5, 'Monitor', -2, 70000, CURRENT_TIMESTAMP);

-- Invalid unit_price
-- INSERT INTO inventory VALUES
-- (6, 'Tablet', 3, 0, CURRENT_TIMESTAMP);

-- Invalid NULL timestamp
-- INSERT INTO inventory VALUES
-- (7, 'Printer', 2, 60000, NULL);



-- Task 3.

CREATE TABLE users
(
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);


-- Task 3.2

CREATE TABLE course_enrollments
(
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id, course_code, semester)
);


INSERT INTO course_enrollments VALUES
(1, 101, 'CS101', 'Fall 2026'),
(2, 101, 'CS102', 'Fall 2026'),
(3, 101, 'CS101', 'Spring 2027');

-- Duplicate combination: violates composite UNIQUE
-- INSERT INTO course_enrollments VALUES
-- (4, 101, 'CS101', 'Fall 2026');


-- Task 3.3


ALTER TABLE users
DROP CONSTRAINT users_username_key;

ALTER TABLE users
DROP CONSTRAINT users_email_key;


ALTER TABLE users
ADD CONSTRAINT unique_username UNIQUE (username);

ALTER TABLE users
ADD CONSTRAINT unique_email UNIQUE (email);


INSERT INTO users VALUES
(1, 'alikhan', 'alikhan@gmail.com', CURRENT_TIMESTAMP),
(2, 'timur', 'timur@gmail.com', CURRENT_TIMESTAMP);

-- Duplicate username: violates unique_username
-- INSERT INTO users VALUES
-- (3, 'alikhan', 'other@gmail.com', CURRENT_TIMESTAMP);

-- Duplicate email: violates unique_email
-- INSERT INTO users VALUES
-- (4, 'dias', 'timur@gmail.com', CURRENT_TIMESTAMP);



-- Task 4.1

CREATE TABLE departments
(
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);


INSERT INTO departments VALUES
(1, 'IT', 'Almaty'),
(2, 'Sales', 'Astana'),
(3, 'HR', 'Shymkent');

-- Duplicate PRIMARY KEY
-- INSERT INTO departments VALUES
-- (1, 'Finance', 'Almaty');

-- NULL PRIMARY KEY
-- INSERT INTO departments VALUES
-- (NULL, 'Marketing', 'Astana');


-- Task 4.2

CREATE TABLE student_courses
(
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);


INSERT INTO student_courses VALUES
(101, 1, '2026-09-01', 'A'),
(101, 2, '2026-09-01', 'B'),
(102, 1, '2026-09-01', 'A');

-- Duplicate composite PRIMARY KEY
-- INSERT INTO student_courses VALUES
-- (101, 1, '2026-09-05', 'C');


-- Task 4.3

-- 1. UNIQUE vs PRIMARY KEY
-- PRIMARY KEY uniquely identifies each row.
-- PRIMARY KEY does not allow NULL values.
-- UNIQUE prevents duplicate values.
-- UNIQUE normally allows NULL values.

-- 2. Single-column vs composite PRIMARY KEY
-- Single-column PRIMARY KEY is used when one column
-- uniquely identifies each record.
-- Composite PRIMARY KEY is used when a combination
-- of multiple columns uniquely identifies a record.

-- 3. One PRIMARY KEY vs multiple UNIQUE constraints
-- A table has one PRIMARY KEY because it defines
-- the table's primary row identifier.
-- Multiple UNIQUE constraints can enforce uniqueness
-- on different columns or combinations of columns.


-- Task 5.1: Basic Foreign Key

CREATE TABLE employees_dept
(
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);


INSERT INTO employees_dept VALUES
(1, 'John Smith', 1, '2024-01-10'),
(2, 'Sarah Johnson', 2, '2024-02-15'),
(3, 'Michael Brown', 3, '2024-03-20');

-- Non-existent department: FOREIGN KEY violation
-- INSERT INTO employees_dept VALUES
-- (4, 'Invalid Employee', 99, '2024-04-01');


-- Task 5.2

CREATE TABLE authors
(
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);


CREATE TABLE publishers
(
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);


CREATE TABLE books
(
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);


INSERT INTO authors VALUES
(1, 'George Orwell', 'United Kingdom'),
(2, 'J.K. Rowling', 'United Kingdom'),
(3, 'Abai Kunanbayev', 'Kazakhstan');


INSERT INTO publishers VALUES
(1, 'Penguin Books', 'London'),
(2, 'Bloomsbury', 'London'),
(3, 'Kazakh Publishing', 'Almaty');


INSERT INTO books VALUES
(1, '1984', 1, 1, 1949, '9780451524935'),
(2, 'Animal Farm', 1, 1, 1945, '9780451526342'),
(3, 'Harry Potter', 2, 2, 1997, '9780747532699'),
(4, 'Book of Words', 3, 3, 1909, '9786010000001');

-- Invalid author_id: FOREIGN KEY violation
-- INSERT INTO books VALUES
-- (5, 'Unknown Book', 99, 1, 2026, '9780000000001');

-- Invalid publisher_id: FOREIGN KEY violation
-- INSERT INTO books VALUES
-- (6, 'Another Book', 1, 99, 2026, '9780000000002');

-- Duplicate ISBN: UNIQUE violation
-- INSERT INTO books VALUES
-- (7, 'Duplicate ISBN', 1, 1, 2026, '9780451524935');


-- Task 5.3

CREATE TABLE categories
(
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);


CREATE TABLE products_fk
(
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER
        REFERENCES categories(category_id)
        ON DELETE RESTRICT
);


CREATE TABLE orders
(
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);


CREATE TABLE order_items
(
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER
        REFERENCES orders(order_id)
        ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);


INSERT INTO categories VALUES
(1, 'Electronics'),
(2, 'Clothing');


INSERT INTO products_fk VALUES
(1, 'Laptop', 1),
(2, 'Phone', 1),
(3, 'T-Shirt', 2);


INSERT INTO orders VALUES
(1, '2026-10-01'),
(2, '2026-10-02');


INSERT INTO order_items VALUES
(1, 1, 1, 2),
(2, 1, 2, 1),
(3, 2, 3, 3);


-- RESTRICT test
-- Category 1 has products.
-- Deleting it should fail.

-- DELETE FROM categories
-- WHERE category_id = 1;

-- Expected result:
-- ERROR: foreign key violation.
-- ON DELETE RESTRICT prevents deleting a category
-- while products reference it.


-- CASCADE test
-- Before deletion, order 1 has two order_items.

SELECT *
FROM order_items
WHERE order_id = 1;

DELETE FROM orders
WHERE order_id = 1;

-- ON DELETE CASCADE automatically removes
-- the two order_items belonging to order 1.

SELECT *
FROM order_items
WHERE order_id = 1;

-- Expected result: 0 rows.


-- Task 6.1

-- Customers

CREATE TABLE ecommerce.customers
(
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);


-- Products

CREATE TABLE ecommerce.products
(
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);


-- Orders

CREATE TABLE ecommerce.orders
(
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL
        REFERENCES ecommerce.customers(customer_id)
        ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL
        CHECK (total_amount >= 0),
    status TEXT NOT NULL
        CHECK (
            status IN (
                'pending',
                'processing',
                'shipped',
                'delivered',
                'cancelled'
            )
        )
);


-- Order Details

CREATE TABLE ecommerce.order_details
(
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL
        REFERENCES ecommerce.orders(order_id)
        ON DELETE CASCADE,
    product_id INTEGER NOT NULL
        REFERENCES ecommerce.products(product_id)
        ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);



-- Customers: 5 records

INSERT INTO ecommerce.customers VALUES
(1, 'Alikhan', 'alikhan@gmail.com', '+77011111111', '2026-01-10'),
(2, 'Timur', 'timur@gmail.com', '+77022222222', '2026-02-15'),
(3, 'Dias', 'dias@gmail.com', NULL, '2026-03-20'),
(4, 'Aruzhan', 'aruzhan@gmail.com', '+77044444444', '2026-04-25'),
(5, 'Dana', 'dana@gmail.com', '+77055555555', '2026-05-30');


-- Products: 5 records

INSERT INTO ecommerce.products VALUES
(1, 'Laptop', 'Gaming laptop', 500000, 10),
(2, 'Phone', 'Smartphone', 300000, 20),
(3, 'Mouse', 'Wireless mouse', 10000, 50),
(4, 'Keyboard', 'Mechanical keyboard', 25000, 30),
(5, 'Monitor', '27 inch monitor', 120000, 15);


-- Orders: 5 records

INSERT INTO ecommerce.orders VALUES
(1, 1, '2026-10-01', 510000, 'delivered'),
(2, 2, '2026-10-02', 300000, 'shipped'),
(3, 3, '2026-10-03', 25000, 'processing'),
(4, 4, '2026-10-04', 120000, 'pending'),
(5, 5, '2026-10-05', 20000, 'cancelled');


-- Order Details: 6 records

INSERT INTO ecommerce.order_details VALUES
(1, 1, 1, 1, 500000),
(2, 1, 3, 1, 10000),
(3, 2, 2, 1, 300000),
(4, 3, 4, 1, 25000),
(5, 4, 5, 1, 120000),
(6, 5, 3, 2, 10000);

