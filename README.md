# MySQL SQL Notes

A from-scratch MySQL 8.0+ course, rewritten from Oracle-based training
notes and adapted end-to-end for MySQL. Every module shares a single
practice database (**`companydb`**) built around one consistent theme:
**employees, departments, jobs, locations, and projects.**

## Repository Structure

```
mysql-sql-notes/
├── README.md
├── sql/
│   ├── 00_schema.sql        -- creates the companydb database and all tables
│   └── 01_sample_data.sql   -- populates companydb with practice data
└── docs/
    ├── 00-introduction-and-dbms-concepts.md
    ├── 01-database-design-normalization.md
    ├── 02-sql-basics-and-datatypes.md
    ├── 03-ddl-tables-and-constraints.md
    ├── 04-dml-and-transactions.md
    ├── 05-select-where-and-operators.md
    ├── 06-built-in-functions.md
    ├── 07-group-by-aggregate-and-window-functions.md
    ├── 08-joins.md
    ├── 09-subqueries-and-set-operators.md
    ├── 10-views-indexes-and-auto-increment.md
    └── 11-dcl-security-and-data-dictionary.md
```

## Getting Started

1. Install **MySQL Server 8.0+** and the `mysql` command-line client.
2. Clone this repository.
3. Build the practice database:

   ```bash
   mysql -u root -p < sql/00_schema.sql
   mysql -u root -p < sql/01_sample_data.sql
   ```

4. Verify the setup:

   ```bash
   mysql -u root -p companydb -e "SHOW TABLES; SELECT * FROM employees;"
   ```

5. Start with [`docs/00-introduction-and-dbms-concepts.md`](docs/00-introduction-and-dbms-concepts.md)
   and work through the modules in order — each one builds on objects
   and concepts introduced in the ones before it.

## The Practice Schema

| Table | Purpose |
|---|---|
| `regions` | Geographic regions |
| `countries` | Countries, linked to a region |
| `locations` | Office locations, linked to a country |
| `departments` | Company departments, linked to a location and a manager |
| `jobs` | Job titles with salary bands |
| `employees` | Employee master data (self-referencing `manager_id`) |
| `job_history` | An employee's past jobs/departments |
| `projects` | Projects run by a department |
| `employee_projects` | Many-to-many: which employees work on which projects |

## Scope Notes

These notes were adapted from an Oracle-based SQL course. Topics with no
direct MySQL equivalent — clusters, Data Pump, SQL*Loader, Flashback/
Purge, synonyms, and materialized views — were intentionally left out to
keep the course focused on core, portable SQL that maps cleanly onto
MySQL 8.0+. Every code sample in every file has been executed and
verified against a MySQL-compatible server as part of writing this
course.

## License

Free to use, adapt, and share with trainees.
