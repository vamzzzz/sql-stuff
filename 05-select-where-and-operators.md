# 05 · SELECT, WHERE & Operators

**DQL / DRL — Data Query / Retrieval Language:** `SELECT`.

- `SELECT` fetches data from tables and views.
- It does **not** affect stored data or the schema.

## Basic SELECT Syntax

```sql
SELECT * FROM table_name;
SELECT column1, column2, ... FROM table_name;
```

```sql
SELECT * FROM departments;

SELECT employee_id, first_name, salary, department_id FROM employees;
```

## DISTINCT

Removes duplicate rows from the result.

```sql
SELECT DISTINCT department_id FROM employees;
```

## The WHERE Clause

`WHERE` filters rows based on a condition, before grouping or sorting
happens.

```sql
SELECT columns FROM table_name WHERE condition;
```

**General condition shape**

```
search_column <comparison_operator> search_value
```

```sql
-- Display information of the employee 'Reddy'.
SELECT employee_id, first_name, salary FROM employees WHERE last_name = 'Reddy';

-- Display employees earning more than 60000.
SELECT employee_id, first_name, salary FROM employees WHERE salary > 60000;
```

## Operators Used in WHERE

- Arithmetic: `+` `-` `*` `/` `%`
- Comparison: `=` `!=` / `<>` `<` `>` `<=` `>=`
- Logical: `AND` `OR` `NOT`
- Special: `BETWEEN`, `IN`, `LIKE`, `IS NULL`, `IS NOT NULL`, `EXISTS`, `%`, `_`

### Arithmetic Operators in a Query

```sql
SELECT salary + 2000 FROM employees;   -- addition
SELECT salary - 1000 FROM employees;   -- subtraction
SELECT salary * 2    FROM employees;   -- multiplication
SELECT salary / 2    FROM employees;   -- division
SELECT MOD(salary, 3) FROM employees;  -- remainder
```

### Logical Operators: AND, BETWEEN, IN

```sql
SELECT employee_id, first_name, salary FROM employees
WHERE salary > 40000 AND salary < 90000;

SELECT employee_id, first_name, salary FROM employees
WHERE salary BETWEEN 40000 AND 90000;

SELECT employee_id, first_name, salary FROM employees
WHERE salary IN (48000, 52000, 62000, 95000);
```

**Compound conditions:** multiple conditions combined with `AND` / `OR`.

| Condition A | Condition B | `A AND B` | `A OR B` |
|---|---|---|---|
| TRUE | TRUE | TRUE | TRUE |
| TRUE | FALSE | FALSE | TRUE |
| FALSE | TRUE | FALSE | TRUE |
| FALSE | FALSE | FALSE | FALSE |

```sql
-- Employees earning more than 40000 who work in department 10.
SELECT employee_id, first_name, salary FROM employees
WHERE salary > 40000 AND department_id = 10;
```

### Pattern Matching: LIKE

`%` matches any sequence of characters (including none); `_` matches
exactly one character.

```sql
-- names starting with 'S'
SELECT first_name FROM employees WHERE first_name LIKE 'S%';

-- names with 'a' as the second letter
SELECT first_name FROM employees WHERE first_name LIKE '_a%';
```

### NULL Comparisons: IS NULL / IS NOT NULL

`NULL` represents "unknown," so it can never be compared with `=`. Always
use `IS NULL` / `IS NOT NULL`:

```sql
SELECT first_name, commission_pct FROM employees WHERE commission_pct IS NULL;

SELECT first_name, commission_pct FROM employees WHERE commission_pct IS NOT NULL;
```

## Column Alias

- A column alias (or label) is a display-only name for a column or
  expression.
- It doesn't change the underlying column name.
- The `AS` keyword is optional but recommended for clarity.

```sql
SELECT column1 AS alias_name FROM table_name;
```

```sql
SELECT
    employee_id AS emp_id,
    first_name  AS emp_name,
    hire_date   AS "date of joining"
FROM employees;
```

Double-quoted or backtick-quoted aliases are needed only when the alias
itself contains spaces or special characters.

## ORDER BY

Sorts the result set by one or more columns.

```sql
SELECT employee_id, first_name, last_name, salary
FROM employees
ORDER BY last_name;             -- ascending by default

SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC;           -- descending

SELECT employee_id, first_name, department_id, salary
FROM employees
ORDER BY department_id ASC, salary DESC;   -- multiple sort keys
```

## Limiting Rows: LIMIT / OFFSET

MySQL uses `LIMIT` (with an optional `OFFSET`) to cap or page through
results — there is no `ROWNUM` pseudocolumn in MySQL.

```sql
-- top 5 highest-paid employees
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC
LIMIT 5;

-- pagination: skip the first 10 rows, then take the next 10
SELECT employee_id, first_name, salary
FROM employees
ORDER BY employee_id
LIMIT 10 OFFSET 10;
```

---
**Next:** [06 · Built-in Functions](06-built-in-functions.md)
