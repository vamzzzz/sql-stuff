-- =====================================================================
-- Sample data for companydb  --  run after 00_schema.sql
-- =====================================================================

USE companydb;

-- ---------------------------------------------------------------------
INSERT INTO regions (region_id, region_name) VALUES
    (1, 'Asia'),
    (2, 'Europe'),
    (3, 'Americas');

INSERT INTO countries (country_id, country_name, region_id) VALUES
    ('IN', 'India', 1),
    ('UK', 'United Kingdom', 2),
    ('US', 'United States', 3);

INSERT INTO locations (location_id, street_address, city, state_province, postal_code, country_id) VALUES
    (1, 'Hitech City Road', 'Hyderabad', 'Telangana', '500081', 'IN'),
    (2, 'Baker Street', 'London', NULL, 'NW1 6XE', 'UK'),
    (3, 'Market Street', 'San Francisco', 'CA', '94105', 'US');

INSERT INTO departments (department_id, department_name, location_id, manager_id) VALUES
    (10, 'Engineering', 1, NULL),
    (20, 'Human Resources', 1, NULL),
    (30, 'Sales', 2, NULL),
    (40, 'Finance', 3, NULL);

INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES
    (1, 'Software Engineer', 40000.00, 90000.00),
    (2, 'Senior Software Engineer', 80000.00, 140000.00),
    (3, 'HR Executive', 30000.00, 60000.00),
    (4, 'Sales Representative', 35000.00, 70000.00),
    (5, 'Finance Analyst', 45000.00, 85000.00),
    (6, 'Engineering Manager', 100000.00, 160000.00);

-- ---------------------------------------------------------------------
-- employees (manager_id left NULL for now on 101, updated after insert)
-- ---------------------------------------------------------------------
INSERT INTO employees
    (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES
    (101, 'Anil',    'Joshi',   'anil.joshi@company.com',    '9876543210', '2015-03-10', 6, 145000.00, NULL, NULL, 10),
    (102, 'Sunil',    'Reddy',   'sunil.reddy@company.com',   '9874563210', '2016-07-21', 1,  62000.00, NULL, 101, 10),
    (103, 'Pooja',    'Thakur',  'pooja.thakur@company.com',  '9874561230', '2017-01-15', 2,  95000.00, NULL, 101, 10),
    (104, 'Manisha',  'Singh',   'manisha.singh@company.com', '9874102563', '2018-05-30', 3,  48000.00, NULL, NULL, 20),
    (105, 'Rahul',    'Verma',   'rahul.verma@company.com',   '9812345670', '2019-02-11', 4,  52000.00, 0.10, NULL, 30),
    (106, 'Sneha',    'Kapoor',  'sneha.kapoor@company.com',  '9823456781', '2019-08-19', 4,  58000.00, 0.15, 105, 30),
    (107, 'Arjun',    'Mehta',   'arjun.mehta@company.com',   '9834567892', '2020-01-05', 5,  67000.00, NULL, NULL, 40),
    (108, 'Divya',    'Nair',    'divya.nair@company.com',    '9845678903', '2020-11-23', 1,  55000.00, NULL, 102, 10),
    (109, 'Karan',    'Gupta',   'karan.gupta@company.com',   '9856789014', '2021-06-14', 1,  49000.00, NULL, 102, 10),
    (110, 'Farhan',   'Ali',     'farhan.ali@company.com',    '9867890125', '2022-03-01', 3,  36000.00, NULL, 104, 20);

UPDATE departments SET manager_id = 101 WHERE department_id = 10;
UPDATE departments SET manager_id = 104 WHERE department_id = 20;
UPDATE departments SET manager_id = 105 WHERE department_id = 30;
UPDATE departments SET manager_id = 107 WHERE department_id = 40;

-- ---------------------------------------------------------------------
INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id) VALUES
    (102, '2016-07-21', '2018-12-31', 1, 10),
    (108, '2020-11-23', '2021-12-31', 1, 10);

-- ---------------------------------------------------------------------
INSERT INTO projects (project_id, project_name, start_date, end_date, budget, department_id) VALUES
    (1, 'Customer Portal Revamp', '2024-01-10', '2024-06-30', 250000.00, 10),
    (2, 'Payroll Automation',     '2024-02-01', '2024-09-15', 150000.00, 20),
    (3, 'Regional Sales Expansion', '2024-03-01', NULL,        400000.00, 30),
    (4, 'Quarterly Audit Tooling', '2024-04-01', '2024-08-31', 90000.00,  40);

INSERT INTO employee_projects (employee_id, project_id, role) VALUES
    (102, 1, 'Backend Developer'),
    (103, 1, 'Tech Lead'),
    (108, 1, 'Frontend Developer'),
    (104, 2, 'Project Coordinator'),
    (109, 2, 'Backend Developer'),
    (105, 3, 'Account Manager'),
    (106, 3, 'Sales Associate'),
    (107, 4, 'Finance Lead');
