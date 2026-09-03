# 08 · Joins

A join is a query that fetches related rows from two or more tables in a
single result set.

**Key concepts**

- **Parent table** — the table whose primary key is referenced by another
  table (e.g. `departments`).
- **Child table** — the table whose foreign key refers to the parent's
  primary key (e.g. `employees`).
- **Matching rows** — rows from the child table that have a foreign key
  value, matched against rows in the parent whose primary key is
  referenced.
- **Non-matching rows** — rows on one side with no corresponding row on
  the other side.

## Types of Join

- Inner join (equi join)
- Outer join — left, right, full
- Non-equi join
- Natural join
- Self join
- Cross join (Cartesian product)

## Inner Join (Equi Join)

An inner join returns only rows that have a match in **both** tables,
based on an equality condition.

```sql
SELECT table1.column1, ..., table2.column1, ...
FROM table1
JOIN table2 ON table1.foreign_key = table2.primary_key;
```

```sql
SELECT e.first_name, d.department_id, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;
```

**Joining more than two tables**

```sql
SELECT e.employee_id, e.first_name, d.department_name, j.job_title
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN jobs j        ON e.job_id = j.job_id;
```

**Table aliases** make multi-table queries far more readable, and are
required once a table appears more than once in the same query (as in a
self join).

## Outer Join

An outer join returns matching rows **plus** unmatched rows from one or
both tables, filling the missing side with `NULL`.

### LEFT (OUTER) JOIN

Returns every row from the left table, matched with the right table
where possible — `NULL` on the right where there's no match.

```sql
SELECT e.employee_id, e.first_name, d.department_id, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;
```

**Left join across three tables**

```sql
SELECT
    e.employee_id, e.first_name,
    d.department_id, d.department_name,
    l.city
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l   ON d.location_id = l.location_id;
```

### RIGHT (OUTER) JOIN

Returns every row from the right table, matched with the left table
where possible.

```sql
SELECT e.employee_id, e.first_name, d.department_id, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id;
```

### FULL OUTER JOIN

MySQL has **no native `FULL OUTER JOIN`**. Emulate it by combining a
`LEFT JOIN` and a `RIGHT JOIN` with `UNION` (which also removes the
duplicate matching rows):

```sql
SELECT e.employee_id, e.first_name, d.department_id, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id

UNION

SELECT e.employee_id, e.first_name, d.department_id, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id;
```

## Non-Equi Join

A join whose condition uses a comparison operator (`<`, `>`, `BETWEEN`,
...) instead of `=`.

```sql
SELECT table1.*, table2.*
FROM table1, table2
WHERE table1.column BETWEEN table2.low_column AND table2.high_column;
```

**Match each employee to the job band their salary falls into:**

```sql
SELECT e.employee_id, e.first_name, e.salary, j.job_title
FROM employees e
JOIN jobs j ON e.salary BETWEEN j.min_salary AND j.max_salary;
```

This pattern can be combined with equi-join conditions across other
tables in the same query.

## Self Join

A self join joins a table to itself, treating it as if it were two
separate tables — one aliased as the "employee" side, one as the
"manager" side. It relies on a recursive foreign key, exactly like
`employees.manager_id`.

```sql
SELECT a.column_name, b.column_name, ...
FROM table1 a
JOIN table1 b ON a.foreign_key = b.primary_key;
```

**Employees and their managers:**

```sql
SELECT e.employee_id, e.first_name, m.employee_id AS manager_id, m.first_name AS manager_name
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id;
```

**Employees who earn more than their manager:**

```sql
SELECT e.first_name AS employee_name, m.first_name AS manager_name
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

**Employees senior (by hire date) to their manager:**

```sql
SELECT e.first_name AS junior, m.first_name AS manager
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.hire_date < m.hire_date;
```

**Everyone who reports to a specific manager:**

```sql
SELECT e.first_name AS direct_report
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE m.employee_id = 101;
```

## Natural Join

A natural join is like an equi join, but MySQL infers the join condition
automatically from every column the two tables have **in common**
(matching name and compatible type) — no `ON` clause is written.

```sql
SELECT columns FROM table1 NATURAL JOIN table2;
```

```sql
SELECT department_id, department_name, city
FROM departments
NATURAL JOIN locations;
```

> Natural joins are convenient but risky in real projects: if a table
> later gains an unrelated column that happens to share a name with
> another table's column, the join condition silently changes. Prefer an
> explicit `JOIN ... ON` in production code.

## Cross Join (Cartesian Product)

A cross join pairs **every** row of one table with **every** row of the
other — rarely useful directly, mostly relevant as what happens if you
forget a join condition.

```sql
SELECT table1.column1, table2.column1
FROM table1
CROSS JOIN table2;
```

```sql
SELECT e.employee_id, e.first_name, d.department_id, d.department_name
FROM employees e
CROSS JOIN departments d;
```

## Joins With Aggregates

**Department-wise total salary, with the department name:**

```sql
SELECT d.department_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;
```

**Employee count and total project budget per department:**

```sql
SELECT
    d.department_name,
    COUNT(DISTINCT e.employee_id) AS headcount,
    COALESCE(SUM(DISTINCT p.budget), 0) AS total_project_budget
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
LEFT JOIN projects p  ON p.department_id = d.department_id
GROUP BY d.department_name;
```

---
**Next:** [09 · Subqueries & Set Operators](09-subqueries-and-set-operators.md)
