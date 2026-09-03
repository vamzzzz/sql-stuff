# 09 · Subqueries & Set Operators

## Subqueries

- A subquery is a query nested inside another query.
- The **inner query** (subquery) runs first; its result is used by the
  **outer query**.
- Subqueries can appear in `WHERE`, `FROM`, `HAVING`, or `SELECT`.
- Write and test the inner query on its own first, then wrap it in the
  outer query.

```sql
SELECT columns FROM table WHERE column <operator> (SELECT column FROM table [WHERE ...]);
```

### Types of Subqueries

- Single-row subquery
- Multiple-row subquery
- Nested subquery
- Correlated subquery
- Inline view (subquery in `FROM`)
- Scalar subquery

## Single-Row Subquery

The inner query returns exactly zero or one row.

**Operators:** `=`, `>`, `<`, `>=`, `<=`, `<>`

```sql
-- the lowest-paid employee
SELECT employee_id, first_name, salary FROM employees
WHERE salary = (SELECT MIN(salary) FROM employees);

-- employees hired before employee 103
SELECT employee_id, first_name, hire_date FROM employees
WHERE hire_date < (SELECT hire_date FROM employees WHERE employee_id = 103)
ORDER BY hire_date;
```

## Nested Subquery

A subquery containing another subquery. MySQL allows deep nesting, but
more than a handful of levels quickly becomes hard to read and optimize —
a CTE (see below) or a join is usually clearer.

```sql
-- employee with the second-highest salary
SELECT employee_id, first_name, salary FROM employees
WHERE salary = (
    SELECT MAX(salary) FROM employees
    WHERE salary < (SELECT MAX(salary) FROM employees)
);
```

## Correlated Subquery

A correlated subquery references a column from the **outer** query,
which means the inner query must be re-evaluated once for every row the
outer query considers.

**Execution order**

1. Outer query proposes a row.
2. That row's values are passed into the inner query.
3. The inner query executes using those values.
4. Its result is used to test the outer row.
5. Repeat for the next outer row.

```sql
-- employees earning more than the average salary of their own department
SELECT e.employee_id, e.first_name, e.salary, e.department_id
FROM employees e
WHERE salary > (
    SELECT AVG(salary) FROM employees WHERE department_id = e.department_id
);
```

## Scalar Subquery

A scalar subquery returns exactly one column from exactly one row, so it
can be used anywhere a single value is expected — including directly in
the `SELECT` list.

```sql
SELECT
    first_name,
    salary,
    (SELECT MAX(salary) FROM employees) AS highest_salary_in_company
FROM employees;
```

```sql
UPDATE projects
SET budget = (SELECT AVG(budget) FROM projects)
WHERE budget IS NULL;
```

## Multiple-Row Subquery

The inner query returns one **or more** rows.

**Operators:** `IN`, `ANY`, `ALL`

```sql
-- salaries matching any employee named 'Anil'
SELECT first_name, salary FROM employees
WHERE salary IN (SELECT salary FROM employees WHERE first_name = 'Anil');

-- employees earning more than at least one Software Engineer (job_id = 1)
SELECT employee_id, salary FROM employees
WHERE salary > ANY (SELECT salary FROM employees WHERE job_id = 1);

-- employees earning more than every Software Engineer
SELECT employee_id, salary FROM employees
WHERE salary > ALL (SELECT salary FROM employees WHERE job_id = 1);
```

## Inline View (Subquery in FROM)

A subquery in the `FROM` clause acts like a temporary, unnamed table for
the outer query. This is useful because MySQL evaluates `FROM` before
`WHERE`/`SELECT` — so a `WHERE` clause can't reference a `SELECT`-list
alias directly, but an inline view lets you filter on a computed column
by "finishing" the calculation first.

```sql
SELECT columns FROM (subquery) AS alias_name;
```

```sql
-- ORA-00904 style error avoided: WHERE can't see the alias "ctc" directly
SELECT * FROM (
    SELECT employee_id, first_name, salary * 12 AS ctc FROM employees
) AS annualized
WHERE ctc > 600000
ORDER BY ctc;
```

## Top-N Queries

Unlike Oracle (which historically required a `ROWNUM` trick), MySQL's
`LIMIT` clause makes Top-N queries direct:

```sql
-- top 3 highest-paid employees
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3;
```

For **ranked** Top-N per group (e.g. the top earner in each department),
combine a window function with an inline view, since `LIMIT` alone can't
be scoped per group:

```sql
SELECT * FROM (
    SELECT
        employee_id, first_name, department_id, salary,
        DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rnk
    FROM employees
) AS ranked
WHERE rnk = 1;
```

## Guidelines for Subqueries

- Enclose every subquery in parentheses.
- Place the subquery on the right-hand side of a comparison.
- Add `ORDER BY` inside the subquery only when you need it for Top-N
  logic combined with `LIMIT` — otherwise `ORDER BY` in a subquery has no
  guaranteed effect on the outer query's row order.
- Use single-row operators (`=`, `>`, ...) with single-row subqueries.
- Use multi-row operators (`IN`, `ANY`, `ALL`) with multi-row subqueries.

---

## Set Operators

Set operators combine the results of two or more `SELECT` statements
into a single result. The component queries must have the same number of
columns, with compatible data types in the same order.

| Operator | Returns |
|---|---|
| `UNION` | Distinct rows from either query (duplicates removed) |
| `UNION ALL` | All rows from either query, duplicates included |
| `INTERSECT` | Distinct rows present in **both** queries (MySQL 8.0.31+) |
| `EXCEPT` | Distinct rows in the first query but **not** the second (MySQL 8.0.31+; Oracle's `MINUS`) |

```sql
SELECT job_id FROM employees WHERE department_id IN (10, 20, 30)
UNION
SELECT job_id FROM employees WHERE department_id IN (30, 40)
ORDER BY job_id;
```

**UNION**

```sql
SELECT employee_id, first_name, department_id FROM employees WHERE department_id IN (10, 20)
UNION
SELECT employee_id, first_name, department_id FROM employees WHERE department_id IN (20, 30);
```

**UNION ALL**

```sql
SELECT employee_id, first_name, department_id FROM employees WHERE department_id IN (10, 20)
UNION ALL
SELECT employee_id, first_name, department_id FROM employees WHERE department_id IN (20, 30);
```

**INTERSECT**

```sql
SELECT department_id FROM employees WHERE department_id IN (10, 20)
INTERSECT
SELECT department_id FROM employees WHERE department_id IN (20, 30);
```

**EXCEPT**

```sql
SELECT department_id FROM employees WHERE department_id IN (10, 20)
EXCEPT
SELECT department_id FROM employees WHERE department_id IN (20, 30);
```

> **Version note:** `INTERSECT` and `EXCEPT` require MySQL **8.0.31** or
> later. On an older 8.0.x server, emulate them with `IN`/`NOT IN` or
> `EXISTS`/`NOT EXISTS` subqueries instead:
> ```sql
> -- INTERSECT emulation
> SELECT DISTINCT department_id FROM employees a
> WHERE department_id IN (10, 20)
>   AND EXISTS (SELECT 1 FROM employees b WHERE b.department_id = a.department_id AND b.department_id IN (20, 30));
>
> -- EXCEPT emulation
> SELECT DISTINCT department_id FROM employees a
> WHERE department_id IN (10, 20)
>   AND NOT EXISTS (SELECT 1 FROM employees b WHERE b.department_id = a.department_id AND b.department_id IN (20, 30));
> ```

---
**Next:** [10 · Views, Indexes & Auto-Increment](10-views-indexes-and-auto-increment.md)
