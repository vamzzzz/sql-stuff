# 07 · GROUP BY, Aggregate & Window Functions

## Aggregate (Group) Functions

Aggregate functions take many rows as input and return a single summary
row per group.

| Function | Description |
|---|---|
| `COUNT(*)` / `COUNT(column)` | Number of rows / non-`NULL` values |
| `SUM(column)` | Total of a numeric column |
| `AVG(column)` | Average of a numeric column |
| `MAX(column)` | Largest value |
| `MIN(column)` | Smallest value |

```sql
SELECT MAX(salary), MIN(salary), COUNT(salary), AVG(salary) FROM employees;
```

## GROUP BY

Groups rows sharing the same value(s) in one or more columns so an
aggregate function can summarize each group separately.

```sql
SELECT department_id, COUNT(*) AS headcount
FROM employees
GROUP BY department_id;

SELECT department_id, SUM(salary) AS total_salary
FROM employees
GROUP BY department_id;
```

> Every column in the `SELECT` list that is **not** wrapped in an
> aggregate function must appear in the `GROUP BY` clause (MySQL enforces
> this under the default `ONLY_FULL_GROUP_BY` SQL mode).

## HAVING

`HAVING` filters **groups** after aggregation — `WHERE` filters
individual rows before aggregation, so `WHERE` cannot reference an
aggregate function.

```sql
SELECT department_id, SUM(salary) AS total_salary
FROM employees
GROUP BY department_id
HAVING SUM(salary) > 100000;

SELECT department_id, MAX(salary)
FROM employees
WHERE department_id IN (10, 20, 30)
GROUP BY department_id
HAVING MAX(salary) > 90000;
```

## Order of Execution

MySQL's logical processing order for a query is:

```
FROM  →  WHERE  →  GROUP BY  →  HAVING  →  SELECT  →  ORDER BY  →  LIMIT
```

This is why `WHERE` can't use a `SELECT`-list alias, and why `HAVING` can
reference aggregates that `WHERE` cannot.

## Window (Analytic) Functions

Window functions calculate a value across a "window" of related rows —
similar to an aggregate, but **without** collapsing the rows into one
per group. Available in MySQL 8.0+.

```sql
function_name() OVER (
    [PARTITION BY column, ...]
    [ORDER BY column, ...]
)
```

### RANK, DENSE_RANK, ROW_NUMBER

| Function | Behavior on ties |
|---|---|
| `ROW_NUMBER()` | Always unique, sequential — no ties possible |
| `RANK()` | Ties share a rank; next rank **skips** (1, 1, 3, ...) |
| `DENSE_RANK()` | Ties share a rank; next rank does **not** skip (1, 1, 2, ...) |

**Rank employees by salary, highest first:**

```sql
SELECT employee_id, first_name, salary,
    RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees
ORDER BY salary DESC;
```

```sql
SELECT employee_id, first_name, salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees
ORDER BY salary DESC;
```

### PARTITION BY — Rank Within Groups

`PARTITION BY` restarts the window calculation for each group — here,
each department is ranked independently.

```sql
SELECT employee_id, first_name, department_id, salary,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
FROM employees
ORDER BY department_id, salary DESC;
```

**Rank employees within a project by hours logged, tie-broken by hire
date:**

```sql
SELECT
    ep.project_id,
    e.employee_id,
    e.first_name,
    e.hire_date,
    DENSE_RANK() OVER (
        PARTITION BY ep.project_id
        ORDER BY e.hire_date ASC
    ) AS seniority_rank
FROM employee_projects ep
JOIN employees e ON e.employee_id = ep.employee_id
ORDER BY ep.project_id, seniority_rank;
```

## GROUP BY ... WITH ROLLUP

`WITH ROLLUP` adds subtotal and grand-total rows to a grouped result —
MySQL's equivalent of Oracle's `ROLLUP()` function, with different
syntax.

```sql
SELECT department_id, job_id, SUM(salary)
FROM employees
GROUP BY department_id, job_id WITH ROLLUP;
```

This returns one row per (`department_id`, `job_id`) combination, plus a
subtotal row per `department_id` (with `job_id = NULL`), plus one final
grand-total row (with both columns `NULL`).

```sql
SELECT department_id, SUM(salary)
FROM employees
GROUP BY department_id WITH ROLLUP
ORDER BY department_id;
```

> MySQL does not support Oracle's `CUBE()` or `GROUPING_ID()` functions.
> `WITH ROLLUP` covers the common "subtotals + grand total" reporting
> need; for a full cross-tab of subtotals across every combination of
> columns, aggregate the data in the application layer instead.

To distinguish a genuine `NULL` in your data from the `NULL` that
`WITH ROLLUP` inserts for a subtotal row, use `GROUPING()`:

```sql
SELECT
    department_id,
    job_id,
    SUM(salary),
    GROUPING(department_id) AS is_dept_subtotal,
    GROUPING(job_id) AS is_job_subtotal
FROM employees
GROUP BY department_id, job_id WITH ROLLUP;
```

---
**Next:** [08 · Joins](08-joins.md)
