# 01 · Database Design & Normalization

## Keys

- **Primary key** — uniquely identifies each record in a table
  (`employees.employee_id`).
- **Foreign key** — a column that references another table's primary key
  (`employees.department_id` references `departments.department_id`).

## ER Modeling

**Entity-Relationship (ER) modeling** is a diagrammatic representation of
the conceptual design of a database.

**Key terms**

- **Entity** — anything with an independent existence about which data is
  collected (e.g. an Employee, a Department, a Project).
- **Attribute** — a property of an entity (e.g. an employee's salary).
- **Relationship** — an association between entities (e.g. an employee
  *works in* a department).

**Steps in ER modeling**

1. Identify the entities.
2. Find the relationships between them.
3. Identify the key attribute(s) for every entity.
4. Identify the other relevant attributes.

### ER Model of `companydb`

```
REGION 1 ──< COUNTRY 1 ──< LOCATION 1 ──< DEPARTMENT 1 ──< EMPLOYEE
                                                │                │
                                                │                │
                                                └──< PROJECT >──┘
                                                  (via employee_projects)

JOB 1 ──< EMPLOYEE >── EMPLOYEE (self-reference: manager_id)
```

| Entity | Key Attribute | Other Attributes |
|---|---|---|
| DEPARTMENT | department_id | department_name, location_id, manager_id |
| EMPLOYEE | employee_id | first_name, last_name, salary, hire_date |
| JOB | job_id | job_title, min_salary, max_salary |
| PROJECT | project_id | project_name, start_date, end_date, budget |

A department **has many** employees; an employee **belongs to one**
department (one-to-many). An employee **can work on many** projects, and a
project **can have many** employees — a many-to-many relationship,
resolved with the junction table `employee_projects`.

## Normalization

**Normalization** is the process of organizing the columns and tables of
a relational database to reduce data **redundancy** and improve data
**integrity**.

**Anomalies in an unnormalized table**

- **Insert anomaly** — you can't add a new project without also
  duplicating employee details.
- **Update anomaly** — changing an employee's phone number means updating
  it in every row that mentions that employee.
- **Delete anomaly** — deleting the last row for a project can
  accidentally delete the only record of an employee's details.

### Unnormalized data — `employee_project_report`

| emp_id | emp_name | phone | project_ids | project_names | hours_logged | rating |
|---|---|---|---|---|---|---|
| 102 | Sunil | 9874563210 | 1 | Customer Portal Revamp | 120 | A |
| 103 | Pooja | 9874561230 | 1 | Customer Portal Revamp | 95 | B |

The `project_ids`/`project_names`/`hours_logged` group is **repeating** —
one employee can log hours against several projects, but this design only
leaves room for one.

**Functional dependencies**

- **Fully functional dependency** — a non-key attribute depends on the
  *complete* key. E.g. `hours_logged` depends on the full
  (`emp_id`, `project_id`) pair.
- **Partial functional dependency** — a non-key attribute depends on only
  *part* of a composite key. E.g. `emp_name`, `phone` depend only on
  `emp_id`, not on `project_id`.
- **Transitive dependency** — a non-key attribute depends on another
  non-key attribute rather than on the key. E.g. `rating` depends on
  `hours_logged`, not directly on (`emp_id`, `project_id`).

### Normal Forms

- **1NF** — First Normal Form
- **2NF** — Second Normal Form
- **3NF** — Third Normal Form
  - **BCNF** — Boyce–Codd Normal Form (a stronger version of 3NF)

#### First Normal Form (1NF)

A table is in 1NF if every column holds **atomic** (indivisible) values —
no repeating groups or multi-valued columns.

**`employee_project_report` in 1NF** (one row per employee/project pair):

| emp_id | emp_name | phone | project_id | project_name | hours_logged | rating |
|---|---|---|---|---|---|---|
| 102 | Sunil | 9874563210 | 1 | Customer Portal Revamp | 120 | A |
| 103 | Pooja | 9874561230 | 1 | Customer Portal Revamp | 95 | B |

#### Second Normal Form (2NF)

A table is in 2NF if it is in 1NF **and** every non-key attribute depends
on the *whole* primary key — no partial dependencies. This is achieved by
splitting different entities into different tables.

**Tables in 2NF**

`employees` (`employee_id`, `emp_name`, `phone`)
`projects` (`project_id`, `project_name`)
`employee_projects` (`employee_id`, `project_id`, `hours_logged`, `rating`)

#### Third Normal Form (3NF)

A table is in 3NF if it is in 2NF **and** no transitive dependencies
exist — every non-key attribute depends only on the key, not on another
non-key attribute.

**Tables in 3NF**

`employees` (`employee_id`, `emp_name`, `phone`)
`projects` (`project_id`, `project_name`)
`employee_projects` (`employee_id`, `project_id`, `hours_logged`)
`ratings` (`min_hours`, `max_hours`, `rating`)

| min_hours | max_hours | rating |
|---|---|---|
| 100 | 999 | A |
| 50 | 99 | B |
| 0 | 49 | C |

#### Boyce–Codd Normal Form (BCNF)

BCNF is a stricter version of 3NF: for every functional dependency
`X → Y`, `X` must be a **candidate key**. Most 3NF tables in practice are
already in BCNF; BCNF mainly matters when a table has multiple
overlapping candidate keys.

`companydb`'s `employees`, `departments`, `jobs`, and `projects` tables,
as created in `sql/00_schema.sql`, are all in at least 3NF.

## Constraints Preview

Normalization tells you *how* to split data across tables; **constraints**
(covered next) are how you *enforce* the resulting rules — primary keys,
foreign keys, `NOT NULL`, `CHECK`, and `UNIQUE` — inside MySQL itself.

---
**Next:** [02 · SQL Basics & Data Types](02-sql-basics-and-datatypes.md)
