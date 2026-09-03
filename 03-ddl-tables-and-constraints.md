# 03 · DDL — Tables & Constraints

**DDL — Data Definition Language:** `CREATE`, `ALTER`, `DROP`, `TRUNCATE`,
`RENAME`.

DDL works on **metadata** (the structure of the database) as opposed to
DML, which works on the data itself. Schema objects — tables, views,
indexes, procedures, and more — are created, modified, and removed with
DDL.

> **Note:** in MySQL, every DDL statement causes an **implicit commit** —
> there is no rolling back a `CREATE TABLE` or `ALTER TABLE` once it runs.

## CREATE TABLE

```sql
CREATE TABLE table_name (
    column1 data_type [constraints],
    column2 data_type [constraints],
    ...
);
```

```sql
CREATE TABLE contractors (
    contractor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(30),
    daily_rate    DECIMAL(8,2)
);
```

This mirrors how `companydb`'s core tables are defined — see
`sql/00_schema.sql` for the complete script that creates `employees`,
`departments`, `jobs`, and the rest.

## Constraints

- Constraints control what data can be inserted into a column.
- They are an optional part of `CREATE TABLE` or `ALTER TABLE`.
- Naming a constraint is optional but strongly recommended — it makes the
  constraint easy to find and drop later.

A constraint can be specified in one of two ways:

**Column-level constraint** — written right after the column, applies to
that one column:

```sql
CREATE TABLE table_name (
    column_name data_type [CONSTRAINT constraint_name] constraint_type,
    ...
);
```

**Table-level constraint** — written after all columns, can refer to one
or more columns:

```sql
CREATE TABLE table_name (
    column_name data_type,
    ...,
    [CONSTRAINT constraint_name] constraint_type (column1, ...)
);
```

`CHECK` constraints in particular are almost always written at the table
level in MySQL.

### Types of Constraints

| Category | Constraints |
|---|---|
| Entity integrity | `PRIMARY KEY`, `UNIQUE` |
| Domain integrity | `NOT NULL`, `CHECK` |
| Referential integrity | `FOREIGN KEY` |

### PRIMARY KEY

- Uniquely identifies each row in the table.
- Values must be unique.
- Values cannot be `NULL`.
- A table can have only one primary key (which may span multiple columns
  — a **composite key**, as used in `job_history`).

```sql
CREATE TABLE t1 (
    eid  INT,
    name VARCHAR(10),
    CONSTRAINT t1_pk PRIMARY KEY (eid)
);
```

### UNIQUE

- Values in the column must be unique.
- Unlike `PRIMARY KEY`, a `UNIQUE` column **can** contain `NULL` — and
  MySQL allows multiple `NULL`s in a `UNIQUE` column, since `NULL` is
  never considered equal to another `NULL`.

```sql
CREATE TABLE t2 (
    eid   INT CONSTRAINT t2_pk PRIMARY KEY,
    name  VARCHAR(10),
    phone VARCHAR(10) CONSTRAINT t2_un UNIQUE
);
```

### NOT NULL

- The column cannot hold `NULL` values.
- Duplicate (non-`NULL`) values are still allowed.

```sql
CREATE TABLE t3 (
    eid   INT CONSTRAINT t3_pk PRIMARY KEY,
    name  VARCHAR(10) CONSTRAINT t3_nn NOT NULL,
    phone VARCHAR(10) CONSTRAINT t3_un UNIQUE
);
```

### CHECK

- Restricts the values that can be inserted based on a boolean
  expression.
- Enforced by MySQL since version 8.0.16 (earlier versions parsed but
  silently ignored `CHECK` — always verify your server version).
- Accepts `NULL` (a `NULL` value doesn't violate a `CHECK`).

```sql
CREATE TABLE t4 (
    eid    INT CONSTRAINT t4_pk PRIMARY KEY,
    name   VARCHAR(10) CONSTRAINT t4_nn NOT NULL,
    gender CHAR(1),
    CONSTRAINT t4_chk CHECK (gender IN ('F', 'M'))
);
```

### FOREIGN KEY

References the primary key column of a parent table.

**Parent table**

| department_id (PK) | department_name |
|---|---|
| 10 | Engineering |
| 20 | Human Resources |

**Child table**

| employee_id | first_name | department_id (FK) |
|---|---|---|
| 101 | Anil | 10 |
| 104 | Manisha | 20 |

```sql
CREATE TABLE t5 (
    eid  INT CONSTRAINT t5_pk PRIMARY KEY,
    name VARCHAR(10) CONSTRAINT t5_nn NOT NULL,
    department_id INT,
    CONSTRAINT t5_fk FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
);
```

### Recursive (Self-Referencing) Foreign Key

A foreign key that references the primary key of the **same** table —
exactly how `employees.manager_id` works in `companydb`:

| employee_id | first_name | salary | manager_id |
|---|---|---|---|
| 101 | Anil | 145000 | *NULL* |
| 102 | Sunil | 62000 | 101 |
| 103 | Pooja | 95000 | 101 |

```sql
CREATE TABLE t6 (
    eid        INT CONSTRAINT t6_pk PRIMARY KEY,
    name       VARCHAR(10),
    manager_id INT,
    CONSTRAINT t6_fk FOREIGN KEY (manager_id) REFERENCES t6 (eid)
);
```

### Multiple Constraints on One Column

```sql
CREATE TABLE t7 (
    employee_code VARCHAR(20)
        CONSTRAINT t7_pk PRIMARY KEY
        CONSTRAINT t7_chk CHECK (employee_code LIKE 'EMP%'),
    ename VARCHAR(20)
        CONSTRAINT t7_nn NOT NULL
        CONSTRAINT t7_un UNIQUE,
    department_id INT
        CONSTRAINT t7_dept_chk CHECK (department_id IN (10, 20, 30))
);
```

### Table-Level Constraints After All Columns

```sql
CREATE TABLE t8 (
    eid   INT,
    name  VARCHAR(10),
    phone VARCHAR(10),
    CONSTRAINT t8_pk PRIMARY KEY (eid),
    CONSTRAINT t8_un UNIQUE (phone)
);
```

### Unnamed Constraints

Constraints can be created without an explicit name — MySQL generates one
automatically (e.g. `t9_ibfk_1`):

```sql
CREATE TABLE t9 (
    eid   INT PRIMARY KEY,
    name  VARCHAR(10) NOT NULL,
    phone VARCHAR(10) UNIQUE
);
```

Unnamed constraints are harder to reference later when you need to drop
them — prefer explicit names in real projects.

### Default Values

`DEFAULT` sets a fallback value for a column when an `INSERT` doesn't
supply one. It is not itself a constraint — it's part of the column
specification.

```sql
CREATE TABLE candidates (
    candidate_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(30),
    result       ENUM('PASS', 'FAIL') DEFAULT 'PASS'
);
```

## Adding and Dropping Constraints

**Add a constraint to an existing table**

```sql
ALTER TABLE table_name
    ADD CONSTRAINT constraint_name constraint_type (column1, ...);
```

```sql
ALTER TABLE projects
    ADD CONSTRAINT chk_projects_dates CHECK (end_date > start_date);
```

**Drop a constraint by name**

```sql
ALTER TABLE table_name DROP CONSTRAINT constraint_name;   -- CHECK, FOREIGN KEY (MySQL 8.0.19+ generic form)
ALTER TABLE table_name DROP FOREIGN KEY constraint_name;  -- foreign keys specifically
ALTER TABLE table_name DROP PRIMARY KEY;                  -- a table has only one, so no name needed
ALTER TABLE table_name DROP INDEX constraint_name;        -- UNIQUE constraints are implemented as indexes
```

**Find a constraint's name when you don't already know it**

```sql
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'companydb'
  AND table_name = 'employees';
```

**Enable/disable foreign key checks** (useful when loading data or
altering tables out of dependency order — MySQL has no per-constraint
enable/disable, only a session-wide switch):

```sql
SET FOREIGN_KEY_CHECKS = 0;
-- ... bulk operations ...
SET FOREIGN_KEY_CHECKS = 1;
```

## Referential Actions: ON DELETE / ON UPDATE

Referential actions decide what happens to child rows when a referenced
parent row is deleted or its key is updated.

**ON DELETE CASCADE** — deleting a parent row deletes matching child
rows.

```sql
CREATE TABLE emp1 (
    eid           INT CONSTRAINT em_pk PRIMARY KEY,
    name          VARCHAR(10),
    department_id INT,
    CONSTRAINT em_fk FOREIGN KEY (department_id)
        REFERENCES departments (department_id) ON DELETE CASCADE
);
```

**ON DELETE SET NULL** — deleting a parent row sets the child's foreign
key to `NULL` (the foreign key column must itself be nullable).

```sql
CREATE TABLE emp2 (
    eid           INT CONSTRAINT em_pk PRIMARY KEY,
    name          VARCHAR(10),
    department_id INT,
    CONSTRAINT em_fk FOREIGN KEY (department_id)
        REFERENCES departments (department_id) ON DELETE SET NULL
);
```

**ON DELETE RESTRICT** (the default) — blocks deletion of a parent row
that still has matching child rows.

## Remaining DDL: DROP, RENAME, TRUNCATE, ALTER

### DROP TABLE

```sql
DROP TABLE table_name;
DROP TABLE emp1;
```

Unlike Oracle, MySQL does not have a recycle bin — a dropped table is
gone immediately and cannot be recovered without a backup.

### RENAME TABLE

```sql
RENAME TABLE old_table_name TO new_table_name;
RENAME TABLE emp1 TO emp1_archive;
```

### TRUNCATE TABLE

- Removes **all** data from a table.
- Resets the `AUTO_INCREMENT` counter back to its starting value.
- Does not remove the table's structure.
- Cannot be rolled back — it is a DDL statement (an implicit `DROP` +
  `CREATE` internally).

```sql
TRUNCATE TABLE job_history;
```

### ALTER TABLE

`ALTER TABLE` is a family of commands to add, drop, modify, or rename
columns.

**Add a column**

```sql
ALTER TABLE employees ADD bonus DECIMAL(10,2) NOT NULL DEFAULT 0;
```

**Rename a column**

```sql
ALTER TABLE employees RENAME COLUMN bonus TO incentive;
```

**Drop a column**

```sql
ALTER TABLE employees DROP COLUMN incentive;
```

**Drop multiple columns**

```sql
ALTER TABLE employees DROP COLUMN column1, DROP COLUMN column2;
```

**Modify a column's data type**

```sql
ALTER TABLE employees MODIFY commission_pct DECIMAL(4,2);
```

(**Condition:** existing values must be compatible with the new type, or
the `ALTER TABLE` will fail.)

## Difference Between DROP, DELETE, and TRUNCATE

| | DROP | TRUNCATE | DELETE |
|---|---|---|---|
| Type | DDL | DDL | DML |
| Removes | Table structure + data | All data, keeps structure | Rows matching `WHERE` (or all rows) |
| `WHERE` clause | N/A | Not allowed | Allowed |
| Rollback | Not possible | Not possible (implicit commit) | Possible (inside a transaction, before `COMMIT`) |
| Resets `AUTO_INCREMENT` | N/A (table is gone) | Yes | No |
| Fires triggers | No | No | Yes |

## Creating a Table From an Existing Table

**Duplicate a table with the same structure and data**

```sql
CREATE TABLE table_name AS SELECT_query;
```

```sql
CREATE TABLE emp_copy1 AS
SELECT employee_id, first_name, last_name, salary FROM employees;
```

**Duplicate with different column names**

```sql
CREATE TABLE emp_copy2 (eid, ename, sal) AS
SELECT employee_id, first_name, salary FROM employees;
```

> **Note:** constraints (other than `NOT NULL` inferred from the source
> columns) are **not** copied to the new table — add them explicitly with
> `ALTER TABLE` if needed.

**Copy only the structure, no rows** — supply a condition that's always
false:

```sql
CREATE TABLE emp_copy3 AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE 1 = 0;
```

**Copy only rows into an existing table**

```sql
INSERT INTO target_table (column1, column2, ...)
SELECT column1, column2, ...
FROM source_table
WHERE condition;
```

---
**Next:** [04 · DML & Transactions](04-dml-and-transactions.md)
