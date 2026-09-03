# 02 · SQL Basics & Data Types

## What is SQL?

- SQL stands for **Structured Query Language**.
- SQL is the standard language for managing data in a relational database.
- It is used to store, manipulate, and retrieve data.
- SQL is used — with vendor-specific extensions — by MySQL, Oracle,
  SQL Server, PostgreSQL, DB2, and virtually every other RDBMS.

> **Note:** To work effectively with MySQL, it is necessary to understand
> standard SQL first; MySQL adds its own extensions on top of it.

## Why SQL?

SQL allows users to:

- Access and query data in a relational database
- Describe and define the structure of the data (tables, columns, types)
- Manipulate that data (insert, update, delete)
- Be embedded within other languages, via drivers/connectors (e.g. the
  `mysql2` package in Node.js, JDBC in Java)
- Create and drop databases and tables
- Create views, stored procedures, and functions
- Set permissions on tables, procedures, and views

## A Brief History of SQL

- **1970** — Dr. E. F. Codd of IBM, considered the father of relational
  databases, published *"A Relational Model of Data for Large Shared Data
  Banks,"* describing the relational model.
- **1974** — Donald Chamberlin and Raymond Boyce at IBM developed SEQUEL
  (**S**tructured **E**nglish **Que**ry **L**anguage), the precursor to
  SQL.
- **1979** — Relational Software, Inc. (later Oracle Corporation) released
  the first commercially available implementation of SQL.
- **1986** — SQL was standardized by ANSI (American National Standards
  Institute), and later by ISO.
- **1995** — MySQL 1.0 was released by MySQL AB.
- **2010** — Oracle Corporation acquired MySQL through its purchase of
  Sun Microsystems; MySQL remains open source under the GPL.

## SQL Architecture

```
        ┌────────────┐        SQL        ┌──────────────────┐
        │  Client /  │  ───────────────▶ │   MySQL Server    │
        │ Application│                    │  (mysqld process) │
        │ (mysql CLI,│  ◀─────────────── │   ┌─────────────┐  │
        │  Workbench,│      Result set    │   │  Storage    │  │
        │  app code) │                    │   │  Engine     │  │
        └────────────┘                    │   │  (InnoDB)   │  │
                                            │   └─────────────┘  │
                                            │   Data files on disk │
                                            └──────────────────┘
```

The client sends SQL statements to the MySQL server over a connection;
the server parses, optimizes, and executes them through a storage engine
(InnoDB by default), then returns a result set to the client.

## SQL Coding Standards and Naming Conventions

- SQL **keywords** (`SELECT`, `FROM`, `WHERE`, ...) are **not** case
  sensitive, but the convention in this course is to write them in
  UPPERCASE for readability.
- **Table and column names** are written in `snake_case`, lowercase.
- Whether table names are case sensitive depends on the operating system
  and the `lower_case_table_names` server setting — Linux servers are
  case sensitive by default, Windows/macOS are not. **Always write
  identifiers consistently** so this never matters.
- **Data values** (the contents of rows) are case sensitive by default,
  governed by the column's collation (e.g. `utf8mb4_0900_ai_ci` is
  accent- and case-insensitive; `utf8mb4_0900_as_cs` is case sensitive).

> **Identifier** means the name of a table, column, procedure, function,
> index, or any other database object.

### Identifier Naming Rules (MySQL)

- May contain letters, digits, underscore `_`, and `$`.
- Cannot be entirely numeric.
- Maximum length is **64 characters** for most object names.
- Spaces are discouraged; if unavoidable, the identifier must be
  wrapped in backticks: `` `first name` ``.
- Reserved keywords used as identifiers must be wrapped in backticks:
  `` `order` ``, `` `select` ``.
- No two columns may share a name within the same table.
- No two tables may share a name within the same database/schema.

**Recommended practice used throughout this course**

- Table names: plural, `snake_case` — `employees`, `departments`.
- Column names: singular, `snake_case` — `first_name`, `hire_date`.
- Primary key columns: `<table_singular>_id` — `employee_id`,
  `department_id`.
- Foreign key columns: match the referenced primary key's name —
  `employees.department_id` references `departments.department_id`.

## SQL Editors / Clients

- **`mysql`** — the official command-line client
- **MySQL Workbench** — official GUI client (ER diagrams, query editor,
  admin)
- **MySQL Shell** — modern scripting shell
- DBeaver, DataGrip, TablePlus — popular third-party GUI clients
- VS Code with a MySQL extension — common in full-stack development
  workflows

## Categories of SQL Commands

| Category | Full Form | Commands |
|---|---|---|
| **DDL** | Data Definition Language | `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME` |
| **DML** | Data Manipulation Language | `INSERT`, `UPDATE`, `DELETE`, `REPLACE` |
| **DQL / DRL** | Data Query / Retrieval Language | `SELECT` |
| **DCL** | Data Control Language | `GRANT`, `REVOKE` |
| **TCL** | Transaction Control Language | `COMMIT`, `ROLLBACK`, `SAVEPOINT`, `START TRANSACTION` |

These are covered in detail in the modules that follow.

## Operators in SQL

| Category | Operators |
|---|---|
| Arithmetic | `+` `-` `*` `/` `%` (modulo, same as `MOD()`) |
| Comparison | `=` `!=` or `<>` `<` `>` `<=` `>=` `<=>` (NULL-safe equal) |
| Logical | `AND` `OR` `NOT` |
| Special | `BETWEEN`, `IN`, `LIKE`, `IS NULL`, `IS NOT NULL`, `EXISTS`, `%`/`_` (wildcards) |
| Set (on whole queries) | `UNION`, `UNION ALL`, `INTERSECT`, `EXCEPT` |
| String concatenation | `CONCAT(str1, str2, ...)` function — **not** `||` (see note below) |

> **Important MySQL note:** unlike Oracle, MySQL does **not** treat `||`
> as string concatenation by default — it behaves as logical `OR`. Always
> use the `CONCAT()` function to join strings in MySQL.
> (MySQL *can* be switched into `PIPES_AS_CONCAT` SQL mode to make `||`
> behave like Oracle, but relying on a non-default mode is discouraged in
> portable code.)

**Arithmetic operators**

```sql
SELECT salary + 2000 FROM employees;   -- addition
SELECT salary - 1000 FROM employees;   -- subtraction
SELECT salary * 2    FROM employees;   -- multiplication
SELECT salary / 2    FROM employees;   -- division
SELECT MOD(salary, 3) FROM employees;  -- remainder
```

**Comparison operators**

They compare one expression with another; the result is `1` (true),
`0` (false), or `NULL` (unknown).

```sql
SELECT * FROM employees WHERE salary > 60000;
SELECT * FROM employees WHERE department_id <> 10;
```

## Data Types in MySQL

A data type specifies:

- The type of data allowed in a column
- The amount of storage allocated for the column

### String / Character Data Types

| Type | Description |
|---|---|
| `CHAR(n)` | Fixed-length, up to 255 characters; always occupies `n` bytes |
| `VARCHAR(n)` | Variable-length, up to 65,535 bytes shared across the row; only actual length is stored |
| `TEXT` / `MEDIUMTEXT` / `LONGTEXT` | Large variable-length text, use for content beyond `VARCHAR`'s practical size |
| `ENUM('a','b','c')` | A string column restricted to a fixed list of values |

```sql
CREATE TABLE sample_types (
    first_name VARCHAR(20),
    last_name  VARCHAR(25) NOT NULL,
    grade      CHAR(1)
);
```

`CHAR('R')` always uses 1 byte per row regardless of content; `VARCHAR`
uses only as much space as the actual string plus a small length prefix.

### Numeric Data Types

| Type | Description |
|---|---|
| `INT` / `INTEGER` | Whole numbers, ~ -2.1 billion to 2.1 billion |
| `BIGINT` | Larger whole numbers, for very large ID ranges |
| `SMALLINT`, `TINYINT` | Smaller-range whole numbers |
| `DECIMAL(p,s)` / `NUMERIC(p,s)` | Exact fixed-point numbers with precision `p` and scale `s` — always use for money/salary |
| `FLOAT`, `DOUBLE` | Approximate floating-point numbers — avoid for currency |

```sql
employee_id INT AUTO_INCREMENT
salary      DECIMAL(8,2)   -- up to 6 digits before the decimal point, 2 after
```

> Use `DECIMAL(p,s)` — never `FLOAT`/`DOUBLE` — for salaries, prices, and
> any value where rounding errors are unacceptable.

### Date and Time Data Types

| Type | Format | Notes |
|---|---|---|
| `DATE` | `'YYYY-MM-DD'` | Date only, e.g. `'2017-12-10'` |
| `DATETIME` | `'YYYY-MM-DD HH:MI:SS'` | Date and time, no timezone, wide range (year 1000–9999) |
| `TIMESTAMP` | `'YYYY-MM-DD HH:MI:SS'` | Date and time, stored in UTC, range limited to 1970–2038 |
| `TIME` | `'HH:MI:SS'` | Time of day only |
| `YEAR` | `YYYY` | A 4-digit year |

```sql
hire_date    DATE
date_of_birth DATE
created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

> **`DATETIME` vs. `TIMESTAMP`:** prefer `DATETIME` for general business
> dates (hire dates, project dates); reserve `TIMESTAMP` for audit
> columns like `created_at`/`updated_at`, where its automatic
> UTC-conversion and `ON UPDATE CURRENT_TIMESTAMP` behavior is useful.

### Binary / Large Object Data Types

| Type | Description |
|---|---|
| `BLOB` / `MEDIUMBLOB` / `LONGBLOB` | Binary data (images, files) stored **inside** the database |
| `JSON` | Native JSON document type (MySQL 5.7.8+), with validation and functions |

MySQL has no direct equivalent of Oracle's `BFILE` (a pointer to a file
stored *outside* the database); this is typically handled at the
application layer by storing a file path or URL in a `VARCHAR` column
instead (e.g. a path to a file in cloud storage).

---
**Next:** [03 · DDL — Tables & Constraints](03-ddl-tables-and-constraints.md)
