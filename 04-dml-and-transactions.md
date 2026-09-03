# 04 · DML & Transactions

**DML — Data Manipulation Language:** `INSERT`, `UPDATE`, `DELETE`,
`REPLACE`.

- DML works on **data** inside a table (as opposed to DDL, which works on
  structure).
- DML statements can be undone with `ROLLBACK` — **provided** they are
  still inside an open transaction on a transactional storage engine
  (InnoDB) and have not yet been committed.
- DML statements can be made permanent with `COMMIT`.

## INSERT

Adds new rows to a table.

**Syntax 1 — explicit column list (recommended)**

```sql
INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...);
```

**Syntax 2 — positional, all columns**

```sql
INSERT INTO table_name VALUES (value1, value2, ...);
```

> String and date values must be enclosed in `'single quotes'`.

```sql
INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
VALUES (7, 'QA Engineer', 40000, 80000);

INSERT INTO jobs VALUES (8, 'DevOps Engineer', 55000, 110000);
```

### Multi-Row INSERT

MySQL lets you insert many rows in a single statement — this is both
simpler and considerably faster than one `INSERT` per row:

```sql
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES
    (9,  'Data Analyst', 45000, 85000),
    (10, 'UI/UX Designer', 40000, 75000),
    (11, 'Product Manager', 90000, 150000);
```

### Inserting NULL Values

**Explicitly insert `NULL`:**

```sql
INSERT INTO employees
    (employee_id, first_name, last_name, email, hire_date, job_id, salary, department_id)
VALUES
    (111, NULL, 'Kulkarni', 'k.kulkarni@company.com', '2023-01-15', 1, 45000, 10);
```

**Or simply omit the column** — MySQL inserts its default (`NULL` unless
a `DEFAULT` is defined):

```sql
INSERT INTO employees (employee_id, last_name, email, hire_date, job_id, salary, department_id)
VALUES (112, 'Iyer', 'i.iyer@company.com', '2023-02-20', 1, 46000, 10);
```

### INSERT ... SELECT (Insert From Another Table)

MySQL has no `INSERT ALL` statement (an Oracle-only extension). To copy
rows from one table into one or more tables, run separate
`INSERT ... SELECT` statements:

```sql
INSERT INTO emp_archive (employee_id, first_name, salary)
SELECT employee_id, first_name, salary FROM employees WHERE department_id = 10;
```

## UPDATE

- Modifies data in existing rows.
- **Never** forget the `WHERE` clause — an `UPDATE` without one changes
  every row in the table.
- Can be rolled back if still inside an open transaction.

```sql
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition;
```

```sql
UPDATE employees SET salary = salary * 1.10 WHERE department_id = 10;

UPDATE employees
SET job_id = 2, salary = 98000
WHERE employee_id = 103;
```

## DELETE

- Removes one, many, or all rows from a table.
- **Never** forget the `WHERE` clause.
- Can be rolled back if still inside an open transaction (unlike
  `TRUNCATE`).

```sql
DELETE FROM table_name WHERE condition;
```

```sql
-- delete one record
DELETE FROM employees WHERE employee_id = 112;

-- delete many records
DELETE FROM employees WHERE employee_id IN (110, 111);

-- delete all records (rarely what you want — prefer TRUNCATE if you also
-- want to reset AUTO_INCREMENT and don't need it to be rollback-able)
DELETE FROM employees;
-- ERROR 1451 (23000): Cannot delete or update a parent row: a foreign
-- key constraint fails (`departments`, CONSTRAINT `fk_departments_manager`
-- FOREIGN KEY (`manager_id`) REFERENCES `employees` (`employee_id`))
```

That last statement is blocked by MySQL itself — `departments.manager_id`,
`job_history.employee_id`, and `employee_projects.employee_id` all
reference `employees`, and the default `ON DELETE RESTRICT` behavior
won't let you delete a parent row that still has matching child rows.
This is referential integrity working as intended: to genuinely empty
`employees`, you'd first need to clear (or update) every table that
references it.

## Upsert: INSERT ... ON DUPLICATE KEY UPDATE

Oracle's `MERGE` statement has no direct equivalent in MySQL. For the
common "insert, or update if it already exists" pattern, MySQL provides
`INSERT ... ON DUPLICATE KEY UPDATE`, which triggers whenever the new row
would violate a `PRIMARY KEY` or `UNIQUE` constraint:

```sql
INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...)
ON DUPLICATE KEY UPDATE column2 = VALUES(column2), ...;
```

```sql
INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
VALUES (1, 'Software Engineer', 42000, 92000)
ON DUPLICATE KEY UPDATE
    min_salary = VALUES(min_salary),
    max_salary = VALUES(max_salary);
```

If `job_id = 1` doesn't exist yet, this inserts a new row; if it already
exists, it updates `min_salary` and `max_salary` on the existing row
instead. `VALUES(column2)` refers to the value that *would* have been
inserted.

For synchronizing a whole batch of rows from a staging table (the closer
analog to Oracle's set-based `MERGE`), combine this with
`INSERT ... SELECT`:

```sql
INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
SELECT job_id, job_title, min_salary, max_salary FROM jobs_staging
ON DUPLICATE KEY UPDATE
    job_title  = VALUES(job_title),
    min_salary = VALUES(min_salary),
    max_salary = VALUES(max_salary);
```

## Transaction Control Language (TCL)

- `START TRANSACTION` (or `BEGIN`)
- `COMMIT`
- `ROLLBACK`
- `SAVEPOINT`

MySQL's default `autocommit` mode commits every individual statement
immediately. To group several statements into one atomic unit of work,
start a transaction explicitly.

```sql
START TRANSACTION;

UPDATE employees SET department_id = 30 WHERE employee_id = 108;
UPDATE departments SET manager_id = 108 WHERE department_id = 30;

COMMIT;   -- makes both changes permanent together
```

### COMMIT

`COMMIT` saves the effect of all DML statements since the transaction
began (or since the last commit/rollback).

```sql
COMMIT;
```

The effect of a commit is also triggered implicitly by:

- Any DDL statement (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME`)
- A clean disconnect from the MySQL client

### ROLLBACK

`ROLLBACK` undoes the DML statements since the transaction began.

```sql
ROLLBACK;
```

### SAVEPOINT

A savepoint is a named marker inside a transaction that allows a
**partial** rollback.

```sql
SAVEPOINT savepoint_name;             -- create a savepoint
ROLLBACK TO savepoint_name;           -- roll back only to that point
RELEASE SAVEPOINT savepoint_name;     -- discard the savepoint
```

```sql
START TRANSACTION;

UPDATE employees SET salary = salary + 1000 WHERE employee_id = 110;
SAVEPOINT after_raise;

UPDATE employees SET salary = salary + 5000 WHERE employee_id = 110;
-- ...on reflection, the second raise was too large
ROLLBACK TO after_raise;

COMMIT;   -- only the first, smaller raise is kept
```

> **Requires InnoDB.** Transactions and `SAVEPOINT` only work on
> transactional storage engines. MySQL's default engine, InnoDB, is
> transactional; the older MyISAM engine is not, and silently ignores
> `ROLLBACK`.

## ACID Properties of Transactions

A **transaction** is a logical, atomic unit of work made up of one or
more SQL statements. **ACID** — Atomicity, Consistency, Isolation,
Durability — is the set of properties InnoDB guarantees for every
transaction.

**Atomicity**
All statements in a transaction succeed, or none of them do. If a
transaction updating 100 rows fails after 20 updates, InnoDB rolls back
all 20.

**Consistency**
A transaction takes the database from one valid state to another. For
example, a transfer that debits one account must also credit another —
never one without the other.

**Isolation**
Changes made by an in-progress transaction are not visible to other
transactions until it commits. One session updating `employees` does not
see uncommitted changes made concurrently by another session (the exact
level of isolation is tunable — see `innodb_lock_wait_timeout` and the
`SET TRANSACTION ISOLATION LEVEL` statement).

**Durability**
Once a transaction commits, its changes survive even a server crash —
InnoDB's redo log guarantees this.

## Locks in MySQL (InnoDB)

Locks prevent concurrent transactions from corrupting each other's
changes.

**Row-level locking (default, InnoDB)**

InnoDB automatically takes row-level locks as needed:

- A `SELECT` (a plain read) normally takes **no lock** at all — it reads
  a consistent snapshot.
- An `UPDATE` / `DELETE` takes an **exclusive lock** on the rows it
  touches, held until commit or rollback.

**Explicit locking reads**

```sql
-- take a shared lock: other sessions can read, none can update, until you commit
SELECT * FROM employees WHERE employee_id = 108 FOR SHARE;

-- take an exclusive lock: other sessions can't read-lock or write these rows
SELECT * FROM employees WHERE employee_id = 108 FOR UPDATE;
```

**Table-level locking** (rarely needed with InnoDB, but available):

```sql
LOCK TABLES employees WRITE;
-- ...
UNLOCK TABLES;
```

**Deadlocks**

A deadlock occurs when two transactions each hold a lock the other is
waiting for. InnoDB automatically detects deadlocks and rolls back one of
the two transactions with an error, letting the other proceed.

---
**Next:** [05 · SELECT, WHERE & Operators](05-select-where-and-operators.md)
