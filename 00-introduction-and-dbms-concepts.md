# 00 · Introduction & DBMS Concepts

> Course notes for MySQL 8.0+. All examples run against a single practice
> database called **`companydb`** built from `sql/00_schema.sql` and
> `sql/01_sample_data.sql` in this repository. Every module in this course
> reuses the same theme: **employees, departments, jobs, locations, and
> projects.**

## Course Contents

| DBMS Concepts | SQL | Database Objects |
|---|---|---|
| File systems vs DBMS | SQL architecture | Constraints |
| DBMS / RDBMS | Data types | Joins |
| Database models | Operators | Subqueries |
| DB design (ER modeling, normalization) | Built-in SQL languages (DDL/DML/DCL/TCL) | Views |
| RDBMS architecture | Functions | Indexes |
| About MySQL | | Auto-increment / surrogate keys |

## Key Terms

| Term | Meaning | Example |
|---|---|---|
| Data | Collection of raw facts | Salaries of all employees |
| Information | Processed, meaningful data | The employee with the highest salary |
| Metadata | Data about data | Column names/types of the `employees` table |
| Row / Record | A single structured item in a table | One employee's details |
| Column / Field | A set of values of the same kind for every row | `first_name` |
| Table / Relation | Data organized into rows and columns | The `employees` table |
| Database | An organized collection of interrelated data | `companydb` |

**Sample table — `employees`**

| employee_id (PK) | first_name | last_name | salary | department_id (FK) |
|---|---|---|---|---|
| 101 | Anil | Joshi | 145000.00 | 10 |
| 102 | Sunil | Reddy | 62000.00 | 10 |
| 103 | Pooja | Thakur | 95000.00 | 10 |
| 104 | Manisha | Singh | 48000.00 | 20 |

## File Systems vs DBMS

**File Management System (FMS)** — a collection of flat files with no
relationships between them.

**Disadvantages of FMS**
- Data redundancy (duplicate data)
- Insert/update/delete anomalies
- Weak security
- No data sharing across applications
- No enforced data integrity

**DBMS (Database Management System)** — software that creates and manages
databases, mediating between end users, applications, and the stored data.

**Advantages of a DBMS**
- Reduced redundancy
- Stronger security
- Easier, controlled access
- Easier manipulation of data
- Controlled data sharing
- Enforced data integrity
- Transaction support

## Database Models / Types of DBMS

- **HDBMS** – Hierarchical Database Management System
- **NDBMS** – Network Database Management System
- **RDBMS** – Relational Database Management System
- **ORDBMS** – Object-Relational Database Management System
- **OODBMS** – Object-Oriented Database Management System

## RDBMS

An RDBMS is a DBMS based on the **relational model**, introduced by
**Dr. E. F. Codd** in 1970. Codd proposed 12 rules ("Codd's Rules") that
describe an ideal relational database; no commercial RDBMS — including
MySQL, Oracle, or SQL Server — implements every rule, but all mainstream
products satisfy the two most practical ones:

- Every table must have a **primary key** that uniquely identifies each row.
- Related tables are connected through **foreign keys**.

### CRUD & ACID

A database should:

- Support **CRUD** operations — **C**reate, **R**ead, **U**pdate, **D**elete
- Guarantee **ACID** properties — **A**tomicity, **C**onsistency,
  **I**solation, **D**urability (covered in detail in
  [04-dml-and-transactions](04-dml-and-transactions.md))

### Some Relational Database Products

| Product | Vendor | Primary Language(s) |
|---|---|---|
| MySQL | Oracle Corporation | SQL |
| Oracle Database | Oracle Corporation | SQL, PL/SQL |
| SQL Server | Microsoft | SQL, T-SQL |
| PostgreSQL | Open Source (PostgreSQL Global Development Group) | SQL, PL/pgSQL |
| MariaDB | Open Source (MariaDB Foundation) | SQL |
| DB2 | IBM | SQL |

## Three-Tier Architecture

Most production database applications follow a three-tier architecture:

```
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│  Presentation │ ───▶ │ Application/ │ ───▶ │   Database    │
│   (Client)    │      │ Business     │      │  (MySQL)      │
│               │ ◀─── │ Logic Layer  │ ◀─── │               │
└──────────────┘      └──────────────┘      └──────────────┘
```

- **Presentation tier** — the UI the end user interacts with.
- **Application tier** — business logic, validation, orchestration
  (for example, a Node.js/Express API).
- **Data tier** — the MySQL server that stores and serves data.

## Roles and Responsibilities

| Database Administrator (DBA) | Database Developer |
|---|---|
| Install and configure MySQL | Create tables |
| Create users and manage privileges | Create views |
| Backup the database (`mysqldump`) | Create indexes |
| Restore the database | Design auto-increment / surrogate keys |
| Upgrade the server | Write stored procedures & functions |
| Tune performance | Write triggers |
| Monitor replication | Write DML queries and reports |

## About MySQL

MySQL is an open-source relational database management system, originally
released in 1995 and currently owned and maintained by **Oracle
Corporation** (Oracle acquired MySQL through its purchase of Sun
Microsystems in 2010). It is one of the most widely used RDBMS products in
the world, especially for web and full-stack applications.

**Storage engines**

MySQL supports multiple storage engines; the default and recommended
engine is **InnoDB**, which supports:

- Transactions and ACID compliance
- Row-level locking
- Foreign key constraints

> All examples in this course assume the **InnoDB** engine (MySQL's
> default since version 5.5).

**Editions**

- **MySQL Community Edition** — free, open-source, used throughout this
  course.
- **MySQL Enterprise Edition** — commercial, adds enterprise backup,
  auditing, and support.
- **MySQL Cluster / HeatWave** — for high availability and analytics at
  scale.

**Tools for MySQL**

- `mysql` — the command-line client
- **MySQL Workbench** — official GUI client
- **MySQL Shell** — modern scripting shell (SQL, Python, JavaScript modes)
- `mysqldump` / `mysqlpump` — backup utilities
- Third-party GUI tools: DBeaver, DataGrip, TablePlus

## Getting Connected

After installing MySQL Server (see the official install guide for your
OS), connect with the command-line client:

```bash
mysql -u root -p
```

Then build the practice schema used throughout this course:

```bash
mysql -u root -p < sql/00_schema.sql
mysql -u root -p < sql/01_sample_data.sql
```

Verify the setup:

```sql
USE companydb;
SHOW TABLES;
SELECT * FROM employees;
```

## Practice Database Overview

All notes in this course query the same nine tables:

| Table | Purpose |
|---|---|
| `regions` | Geographic regions (Asia, Europe, Americas) |
| `countries` | Countries, linked to a region |
| `locations` | Office locations, linked to a country |
| `departments` | Company departments, linked to a location and a manager |
| `jobs` | Job titles with salary bands |
| `employees` | Employee master data, linked to a job, department, and manager |
| `job_history` | Historical record of an employee's past jobs/departments |
| `projects` | Projects run by a department |
| `employee_projects` | Which employees work on which projects (many-to-many) |

The full entity relationships are covered in
[01-database-design-normalization](01-database-design-normalization.md).

---
**Next:** [01 · Database Design & Normalization](01-database-design-normalization.md)
