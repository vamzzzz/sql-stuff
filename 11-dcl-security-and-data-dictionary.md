# 11 · DCL, Security & the Data Dictionary

**DCL — Data Control Language:** `CREATE USER`, `GRANT`, `REVOKE`.

DCL manages **who** can connect to the server and **what** they're
allowed to do once connected.

## Users

```sql
CREATE USER 'username'@'host' IDENTIFIED BY 'password';
```

```sql
CREATE USER 'trainee'@'localhost' IDENTIFIED BY 'Str0ngPassw0rd!';
```

- `'host'` restricts *where* the user is allowed to connect from —
  `'localhost'` only from the same machine, `'%'` from anywhere.
- MySQL enforces password strength via the `validate_password` component
  on servers where it's installed; choose a genuinely strong password in
  real environments, not just in training examples.

**Changing a password**

```sql
ALTER USER 'trainee'@'localhost' IDENTIFIED BY 'NewPassw0rd!';
```

**Dropping a user**

```sql
DROP USER 'trainee'@'localhost';
```

## Privileges: GRANT and REVOKE

Privileges (permissions) are given with `GRANT` and taken away with
`REVOKE`.

```sql
GRANT privilege [, privilege ...] ON schema_name.object_name TO 'user'@'host';

REVOKE privilege [, privilege ...] ON schema_name.object_name FROM 'user'@'host';
```

**Granting specific privileges**

```sql
GRANT SELECT, INSERT, UPDATE ON companydb.* TO 'trainee'@'localhost';
```

**Granting a privilege on a single column**

```sql
GRANT UPDATE (salary) ON companydb.employees TO 'trainee'@'localhost';
```

**Granting all privileges on a database**

```sql
GRANT ALL PRIVILEGES ON companydb.* TO 'trainee'@'localhost';
```

`ALL PRIVILEGES` includes: `SELECT`, `INSERT`, `UPDATE`, `DELETE`,
`CREATE`, `DROP`, `ALTER`, `INDEX`, `REFERENCES`, and more.

**Granting to multiple users at once**

```sql
GRANT SELECT ON companydb.* TO 'trainee'@'localhost', 'auditor'@'localhost';
```

**Revoking privileges**

```sql
REVOKE INSERT, UPDATE ON companydb.* FROM 'trainee'@'localhost';
```

**Viewing a user's current privileges**

```sql
SHOW GRANTS FOR 'trainee'@'localhost';
SHOW GRANTS FOR CURRENT_USER();
```

## Database Security — Three Layers

| Layer | Mechanism |
|---|---|
| **Server / connection level** | Users, passwords, host restrictions |
| **Object level** | `GRANT`/`REVOKE` on databases, tables, and columns |
| **Row / data level** | Views that expose only a filtered subset of rows |

For example, a view like `engineering_employees` (see
[10-views-indexes-and-auto-increment](10-views-indexes-and-auto-increment.md))
combined with a `GRANT SELECT ON companydb.engineering_employees` (and
**no** grant on the underlying `employees` table) gives a user row-level
access without ever touching table-level privileges.

## The Data Dictionary: `information_schema`

MySQL exposes its metadata — the structure of every database, table,
column, index, constraint, and privilege — through the built-in
**`information_schema`** database, a set of standard, read-only views.
This is MySQL's equivalent of Oracle's `USER_*`/`ALL_*`/`DBA_*` data
dictionary views.

| `information_schema` view | Contents |
|---|---|
| `SCHEMATA` | All databases on the server |
| `TABLES` | All tables and views |
| `COLUMNS` | Every column of every table, with type and nullability |
| `KEY_COLUMN_USAGE` | Which columns participate in which keys |
| `TABLE_CONSTRAINTS` | Primary key, foreign key, unique, and check constraints |
| `REFERENTIAL_CONSTRAINTS` | Foreign key relationships and their referential actions |
| `STATISTICS` | Index definitions |
| `VIEWS` | View definitions |
| `USER_PRIVILEGES` / `SCHEMA_PRIVILEGES` | Granted privileges |

```sql
-- every column of the employees table, in order
SELECT column_name, data_type, is_nullable, column_key
FROM information_schema.columns
WHERE table_schema = 'companydb' AND table_name = 'employees'
ORDER BY ordinal_position;

-- every constraint defined on the employees table
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'companydb' AND table_name = 'employees';

-- every table in companydb, with its storage engine and row count estimate
SELECT table_name, engine, table_rows
FROM information_schema.tables
WHERE table_schema = 'companydb';
```

## `SHOW` Statements — Quick Alternatives

MySQL also provides `SHOW` statements, which are quicker to type than the
equivalent `information_schema` query for everyday exploration:

```sql
SHOW DATABASES;
SHOW TABLES;                       -- (after USE companydb;)
SHOW FULL TABLES WHERE table_type = 'VIEW';
DESCRIBE employees;                -- or: SHOW COLUMNS FROM employees;
SHOW CREATE TABLE employees;       -- the exact DDL that would recreate the table
SHOW INDEX FROM employees;
SHOW CREATE VIEW employee_department_view;
SHOW GRANTS FOR 'trainee'@'localhost';
SHOW PROCESSLIST;                  -- currently running connections/queries
SHOW ENGINE INNODB STATUS;         -- InnoDB internals, useful for lock/deadlock debugging
```

## Backup and Restore (for completeness)

Day-to-day export/import of a MySQL database is handled by the
command-line utilities `mysqldump` and `mysql` (as the import target) —
this is the closest MySQL equivalent to Oracle's Data Pump / `expdp`
tooling:

```bash
# back up the whole database to a .sql file
mysqldump -u root -p companydb > companydb_backup.sql

# restore it into a fresh database
mysql -u root -p companydb_new < companydb_backup.sql
```

For loading data from an external CSV file (the MySQL equivalent of
Oracle's SQL*Loader), MySQL provides `LOAD DATA INFILE`:

```sql
LOAD DATA INFILE '/path/to/employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(first_name, last_name, email, hire_date, job_id, salary, department_id);
```

---

## Course Wrap-Up

You've now covered, in MySQL 8.0+ terms, everything the original course
outline set out to teach:

- DBMS fundamentals, ER modeling, and normalization
  ([00](00-introduction-and-dbms-concepts.md),
  [01](01-database-design-normalization.md))
- SQL data types, identifiers, and operators ([02](02-sql-basics-and-datatypes.md))
- DDL: tables and constraints ([03](03-ddl-tables-and-constraints.md))
- DML and transactions ([04](04-dml-and-transactions.md))
- Querying with `SELECT`/`WHERE` ([05](05-select-where-and-operators.md))
- Built-in functions ([06](06-built-in-functions.md))
- Aggregation and window functions ([07](07-group-by-aggregate-and-window-functions.md))
- Joins ([08](08-joins.md))
- Subqueries and set operators ([09](09-subqueries-and-set-operators.md))
- Views, indexes, and auto-increment keys ([10](10-views-indexes-and-auto-increment.md))
- DCL, security, and the data dictionary (this file)

The next step beyond this course is typically stored programs — MySQL
procedures, functions, and triggers — which is its own module once this
core SQL foundation is solid.
