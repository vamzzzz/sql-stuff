-- =====================================================================
-- companydb  --  practice schema used throughout 01_SQL_Notes (MySQL 8.0+)
-- Run this file first, then 01_sample_data.sql
-- =====================================================================

DROP DATABASE IF EXISTS companydb;
CREATE DATABASE companydb
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE companydb;

-- ---------------------------------------------------------------------
-- regions
-- ---------------------------------------------------------------------
CREATE TABLE regions (
    region_id   INT AUTO_INCREMENT,
    region_name VARCHAR(25) NOT NULL,
    CONSTRAINT pk_regions PRIMARY KEY (region_id)
);

-- ---------------------------------------------------------------------
-- countries
-- ---------------------------------------------------------------------
CREATE TABLE countries (
    country_id   CHAR(2) NOT NULL,
    country_name VARCHAR(40) NOT NULL,
    region_id    INT,
    CONSTRAINT pk_countries PRIMARY KEY (country_id),
    CONSTRAINT fk_countries_region FOREIGN KEY (region_id)
        REFERENCES regions (region_id)
);

-- ---------------------------------------------------------------------
-- locations
-- ---------------------------------------------------------------------
CREATE TABLE locations (
    location_id    INT AUTO_INCREMENT,
    street_address VARCHAR(40),
    city           VARCHAR(30) NOT NULL,
    state_province VARCHAR(25),
    postal_code    VARCHAR(12),
    country_id     CHAR(2),
    CONSTRAINT pk_locations PRIMARY KEY (location_id),
    CONSTRAINT fk_locations_country FOREIGN KEY (country_id)
        REFERENCES countries (country_id)
);

-- ---------------------------------------------------------------------
-- departments  (manager_id added later with ALTER TABLE to avoid a
-- circular reference with employees)
-- ---------------------------------------------------------------------
CREATE TABLE departments (
    department_id   INT AUTO_INCREMENT,
    department_name VARCHAR(30) NOT NULL,
    location_id     INT,
    manager_id      INT,
    CONSTRAINT pk_departments PRIMARY KEY (department_id),
    CONSTRAINT fk_departments_location FOREIGN KEY (location_id)
        REFERENCES locations (location_id)
);

-- ---------------------------------------------------------------------
-- jobs
-- ---------------------------------------------------------------------
CREATE TABLE jobs (
    job_id     INT AUTO_INCREMENT,
    job_title  VARCHAR(35) NOT NULL,
    min_salary DECIMAL(8,2),
    max_salary DECIMAL(8,2),
    CONSTRAINT pk_jobs PRIMARY KEY (job_id),
    CONSTRAINT chk_jobs_salary_range CHECK (max_salary >= min_salary)
);

-- ---------------------------------------------------------------------
-- employees  (self-referencing manager_id)
-- ---------------------------------------------------------------------
CREATE TABLE employees (
    employee_id    INT AUTO_INCREMENT,
    first_name     VARCHAR(20),
    last_name      VARCHAR(25) NOT NULL,
    email          VARCHAR(50) NOT NULL,
    phone_number   VARCHAR(20),
    hire_date      DATE NOT NULL,
    job_id         INT NOT NULL,
    salary         DECIMAL(8,2) NOT NULL,
    commission_pct DECIMAL(4,2),
    manager_id     INT,
    department_id  INT,
    CONSTRAINT pk_employees PRIMARY KEY (employee_id),
    CONSTRAINT uq_employees_email UNIQUE (email),
    CONSTRAINT chk_employees_salary CHECK (salary > 0),
    CONSTRAINT fk_employees_job FOREIGN KEY (job_id)
        REFERENCES jobs (job_id),
    CONSTRAINT fk_employees_department FOREIGN KEY (department_id)
        REFERENCES departments (department_id),
    CONSTRAINT fk_employees_manager FOREIGN KEY (manager_id)
        REFERENCES employees (employee_id)
);

-- now that employees exists, link departments.manager_id to it
ALTER TABLE departments
    ADD CONSTRAINT fk_departments_manager FOREIGN KEY (manager_id)
        REFERENCES employees (employee_id);

-- ---------------------------------------------------------------------
-- job_history  (composite primary key)
-- ---------------------------------------------------------------------
CREATE TABLE job_history (
    employee_id   INT NOT NULL,
    start_date    DATE NOT NULL,
    end_date      DATE NOT NULL,
    job_id        INT NOT NULL,
    department_id INT,
    CONSTRAINT pk_job_history PRIMARY KEY (employee_id, start_date),
    CONSTRAINT chk_job_history_dates CHECK (end_date > start_date),
    CONSTRAINT fk_job_history_employee FOREIGN KEY (employee_id)
        REFERENCES employees (employee_id),
    CONSTRAINT fk_job_history_job FOREIGN KEY (job_id)
        REFERENCES jobs (job_id),
    CONSTRAINT fk_job_history_department FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
);

-- ---------------------------------------------------------------------
-- projects
-- ---------------------------------------------------------------------
CREATE TABLE projects (
    project_id    INT AUTO_INCREMENT,
    project_name  VARCHAR(60) NOT NULL,
    start_date    DATE,
    end_date      DATE,
    budget        DECIMAL(10,2),
    department_id INT,
    CONSTRAINT pk_projects PRIMARY KEY (project_id),
    CONSTRAINT fk_projects_department FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
);

-- ---------------------------------------------------------------------
-- employee_projects  (many-to-many junction table)
-- ---------------------------------------------------------------------
CREATE TABLE employee_projects (
    employee_id INT NOT NULL,
    project_id  INT NOT NULL,
    role        VARCHAR(30),
    CONSTRAINT pk_employee_projects PRIMARY KEY (employee_id, project_id),
    CONSTRAINT fk_emp_proj_employee FOREIGN KEY (employee_id)
        REFERENCES employees (employee_id),
    CONSTRAINT fk_emp_proj_project FOREIGN KEY (project_id)
        REFERENCES projects (project_id)
);
