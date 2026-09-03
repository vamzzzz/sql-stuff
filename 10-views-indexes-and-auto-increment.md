# 10 · Views, Indexes & Auto-Increment

## Views

- A view is a logical representation of a subset of data from one or
  more tables — a named, reusable query.
- It's a "window" onto the underlying tables — not a copy of the data.
- `SELECT` and (under certain conditions) DML statements can be run
  against a view.

**Views are used to:**

- Restrict which columns or rows a user can see
- Simplify complex, frequently-repeated queries
- Present different perspectives of the same underlying data

**General syntax**

```sql
CREATE [OR REPLACE] VIEW view_name AS select_query [WITH CHECK OPTION];
```

### Simple View

A view built on some or all columns of **one** table.

```sql
CREATE VIEW engineering_employees AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE department_id = 10;

SELECT * FROM engineering_employees;

UPDATE engineering_employees SET salary = salary + 1000 WHERE employee_id = 102;
```

- If a column used by the view is dropped from the base table, the view
  becomes invalid.
- You cannot add columns to a view that don't exist in its underlying
  query.
- A view built from a single table, with no aggregates, `GROUP BY`,
  `DISTINCT`, or set operators, is generally **updatable** — inserts,
  updates, and deletes on the view pass through to the base table.

**A subtlety with `INSERT` through a view:** an `INSERT` still has to
satisfy every constraint on the *base* table — including columns the
view doesn't expose. `engineering_employees` leaves out `email`,
`hire_date`, and `job_id`, all `NOT NULL` with no `DEFAULT` on
`employees`, so an insert through this view fails:

```sql
INSERT INTO engineering_employees (employee_id, first_name, last_name, salary)
VALUES (113, 'Neha', 'Patil', 50000);
-- ERROR 1423 (HY000): Field of view 'companydb.engineering_employees'
-- underlying table doesn't have a default value
```

To make a view insertable in practice, either include every `NOT NULL`,
no-default column from the base table in the view's column list, or just
plan to use the view for `SELECT`/`UPDATE` only, and insert directly
against the base table.

### Complex View

A view built from **multiple** tables (usually via a join) or containing
aggregation.

```sql
CREATE VIEW employee_department_view AS
SELECT e.employee_id, e.first_name, d.department_id, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

SELECT * FROM employee_department_view;
```

Views that join multiple tables, group data, or use `DISTINCT` are
generally **not** updatable through the view directly.

### WITH CHECK OPTION

`WITH CHECK OPTION` prevents an `INSERT` or `UPDATE` through the view
from creating a row that the view's own `WHERE` clause wouldn't return.

```sql
CREATE VIEW high_earners AS
SELECT employee_id, first_name, salary
FROM employees
WHERE salary > 50000
WITH CHECK OPTION;

-- fails: dropping the salary below 50000 would make the row
-- disappear from the view's own definition
UPDATE high_earners SET salary = 40000 WHERE employee_id = 101;
-- ERROR 1369 (44000): CHECK OPTION failed 'companydb.high_earners'
```

> MySQL has no `WITH READ ONLY` clause like Oracle. To make a view
> strictly read-only, either don't rely on it being updatable in
> application code, or restrict the underlying table privileges for the
> account that queries the view (see
> [11-dcl-security-and-data-dictionary](11-dcl-security-and-data-dictionary.md)).

### Replacing / Altering a View

```sql
CREATE OR REPLACE VIEW engineering_employees AS
SELECT employee_id, first_name, last_name, salary, hire_date
FROM employees
WHERE department_id = 10;

-- equivalent, explicit form
ALTER VIEW engineering_employees AS
SELECT employee_id, first_name, last_name, salary, hire_date
FROM employees
WHERE department_id = 10;
```

### Viewing Existing Views

```sql
SHOW FULL TABLES IN companydb WHERE table_type = 'VIEW';

SELECT table_name FROM information_schema.views WHERE table_schema = 'companydb';
```

### Dropping a View

```sql
DROP VIEW view_name;
DROP VIEW IF EXISTS engineering_employees, employee_department_view;
```

> **Materialized views:** MySQL has no built-in materialized view object
> (unlike Oracle or PostgreSQL). For a query that's expensive to
> recompute and doesn't need to be perfectly live, the common MySQL
> pattern is a real "summary" table that you refresh on a schedule, e.g.
> `CREATE TABLE department_salary_summary AS SELECT ...`, then
> periodically `TRUNCATE` + re-populate it (via a scheduled `EVENT` or an
> external job scheduler).

## Indexes

An index is a database object that speeds up `SELECT` queries (and
`WHERE`/`JOIN`/`ORDER BY` clauses) on the columns it covers, at the cost
of extra storage and slightly slower writes.

- MySQL **automatically** creates an index for every `PRIMARY KEY` and
  `UNIQUE` constraint.
- You can **manually** create additional (non-unique) indexes on columns
  frequently used in filtering, joining, or sorting.

```sql
CREATE INDEX index_name ON table_name (column1, column2, ...);
```

```sql
CREATE INDEX idx_emp_name ON employees (first_name, last_name);

SHOW INDEX FROM employees;
```

**Guidelines for creating an index**

- Index columns with a wide range of distinct values (high cardinality).
- Index columns frequently used together in a `WHERE` clause or a join
  condition.
- Avoid indexing small tables, or columns where most queries retrieve a
  large percentage of the table's rows anyway — the index adds overhead
  without much benefit.
- Every index slows down `INSERT`/`UPDATE`/`DELETE` slightly, since the
  index itself must also be maintained — don't over-index.

**Checking query performance**

```sql
EXPLAIN SELECT * FROM employees WHERE first_name = 'Sunil';
```

`EXPLAIN` shows whether MySQL used an index (and which one) to satisfy
the query — MySQL's equivalent of Oracle's `autotrace`.

**Dropping an index**

```sql
DROP INDEX index_name ON table_name;
DROP INDEX idx_emp_name ON employees;
```

## Auto-Increment (Surrogate Keys)

MySQL has no `SEQUENCE` object in standard edition (unlike Oracle or
PostgreSQL). Instead, a column marked `AUTO_INCREMENT` generates its own
sequential value on every `INSERT` — this is the standard way to
populate a surrogate primary key in MySQL, and is how every primary key
in `companydb` (`employee_id`, `department_id`, `job_id`, ...) is
defined.

```sql
CREATE TABLE table_name (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    ...
);
```

**Starting value**

By default, `AUTO_INCREMENT` starts at 1 and increases by 1. To start
from a different value:

```sql
CREATE TABLE contractors (
    contractor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(30)
) AUTO_INCREMENT = 1000;
```

Or on an existing table:

```sql
ALTER TABLE contractors AUTO_INCREMENT = 1000;
```

**Using the generated value**

You never supply a value for an `AUTO_INCREMENT` column yourself in
normal use — omit it (or pass `NULL`/`DEFAULT`), and MySQL fills it in:

```sql
INSERT INTO contractors (full_name) VALUES ('Sanjay Rao');

-- retrieve the value that was just generated, in the same session
SELECT LAST_INSERT_ID();
```

`LAST_INSERT_ID()` is scoped per-connection — safe to use even if other
sessions are inserting concurrently.

**`TRUNCATE TABLE`** resets the `AUTO_INCREMENT` counter back to its
starting value; a plain `DELETE FROM table` does **not**.

---
**Next:** [11 · DCL, Security & the Data Dictionary](11-dcl-security-and-data-dictionary.md)
