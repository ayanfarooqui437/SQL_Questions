-- Banking enterprise database

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS borrower;
DROP TABLE IF EXISTS depositor;
DROP TABLE IF EXISTS loan;
DROP TABLE IF EXISTS account;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS branch;

CREATE TABLE branch (
    branch_name VARCHAR(50) PRIMARY KEY,
    branch_city VARCHAR(50) NOT NULL,
    assets DECIMAL(15, 2) NOT NULL
);

CREATE TABLE account (
    accno INTEGER PRIMARY KEY,
    branch_name VARCHAR(50) NOT NULL,
    balance DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (branch_name) REFERENCES branch (branch_name)
);

CREATE TABLE customer (
    customer_name VARCHAR(50) PRIMARY KEY,
    customer_street VARCHAR(100) NOT NULL,
    customer_city VARCHAR(50) NOT NULL
);

CREATE TABLE depositor (
    customer_name VARCHAR(50) NOT NULL,
    accno INTEGER NOT NULL,
    PRIMARY KEY (customer_name, accno),
    FOREIGN KEY (customer_name) REFERENCES customer (customer_name),
    FOREIGN KEY (accno) REFERENCES account (accno)
);

CREATE TABLE loan (
    loan_number INTEGER PRIMARY KEY,
    branch_name VARCHAR(50) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (branch_name) REFERENCES branch (branch_name)
);

CREATE TABLE borrower (
    customer_name VARCHAR(50) NOT NULL,
    loan_number INTEGER NOT NULL,
    PRIMARY KEY (customer_name, loan_number),
    FOREIGN KEY (customer_name) REFERENCES customer (customer_name),
    FOREIGN KEY (loan_number) REFERENCES loan (loan_number)
);

INSERT INTO branch (branch_name, branch_city, assets) VALUES
    ('Main', 'Harrison', 10000000.00),
    ('Perryridge', 'Harrison', 8000000.00),
    ('Round Hill', 'Brooklyn', 6000000.00),
    ('Brighton', 'Brooklyn', 7500000.00),
    ('Downtown', 'New York', 9500000.00);

INSERT INTO customer (customer_name, customer_street, customer_city) VALUES
    ('Alice', '12 Main Street', 'Harrison'),
    ('Bob', '34 Pine Avenue', 'Brooklyn'),
    ('Carol', '56 Oak Road', 'Harrison'),
    ('David', '78 Elm Street', 'Brooklyn'),
    ('Eve', '90 Cedar Lane', 'New York');

INSERT INTO account (accno, branch_name, balance) VALUES
    (101, 'Main', 5000.00),
    (102, 'Main', 7500.00),
    (103, 'Perryridge', 3200.00),
    (104, 'Round Hill', 4100.00),
    (105, 'Brighton', 6800.00),
    (106, 'Downtown', 2900.00),
    (107, 'Main', 12500.00);

INSERT INTO depositor (customer_name, accno) VALUES
    ('Alice', 101),
    ('Alice', 102),
    ('Alice', 103),
    ('Bob', 104),
    ('Bob', 105),
    ('Carol', 107),
    ('David', 104),
    ('Eve', 106);

INSERT INTO loan (loan_number, branch_name, amount) VALUES
    (201, 'Main', 12000.00),
    (202, 'Perryridge', 8500.00),
    (203, 'Round Hill', 15000.00),
    (204, 'Brighton', 6000.00),
    (205, 'Downtown', 11000.00);

INSERT INTO borrower (customer_name, loan_number) VALUES
    ('Alice', 201),
    ('Bob', 202),
    ('Carol', 203),
    ('David', 204),
    ('Eve', 205);

-- Customers with at least two accounts at the Main branch.
SELECT d.customer_name
FROM depositor AS d
JOIN account AS a ON a.accno = d.accno
WHERE a.branch_name = 'Main'
GROUP BY d.customer_name
HAVING COUNT(*) >= 2;

-- Customers having an account at every branch in Brooklyn.
SELECT DISTINCT d.customer_name
FROM depositor AS d
WHERE NOT EXISTS (
    SELECT 1
    FROM branch AS b
    WHERE b.branch_city = 'Brooklyn'
      AND NOT EXISTS (
          SELECT 1
          FROM depositor AS bd
          JOIN account AS ba ON ba.accno = bd.accno
          WHERE bd.customer_name = d.customer_name
            AND ba.branch_name = b.branch_name
      )
);

-- Demonstration: delete all accounts at branches in Brooklyn.
-- Remove linked depositor rows first. Run this block in a transaction so
-- the demonstration can be inspected, then rolled back.
BEGIN;
DELETE FROM depositor
WHERE accno IN (
    SELECT accno
    FROM account
    WHERE branch_name IN (
        SELECT branch_name
        FROM branch
        WHERE branch_city = 'Brooklyn'
    )
);

DELETE FROM account
WHERE branch_name IN (
    SELECT branch_name
    FROM branch
    WHERE branch_city = 'Brooklyn'
);
ROLLBACK;
