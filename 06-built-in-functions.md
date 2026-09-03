# 06 · Built-in Functions

MySQL functions are built into the server and are used inside `SELECT`,
`WHERE`, `GROUP BY`, `HAVING`, and other clauses. They are distinct from
user-defined stored functions written in SQL/procedural extensions.

**Single-row functions** — return one result for every input row. Used in
`SELECT`, `WHERE`, `GROUP BY`, `HAVING`, and more.

**Multi-row (aggregate) functions** — operate on a group of rows and
return one result for the whole group. Covered separately in
[07-group-by-aggregate-and-window-functions](07-group-by-aggregate-and-window-functions.md).

```
Single input  → single-row function → single output   (e.g. UPPER(name))
Many inputs   → aggregate function   → single output   (e.g. AVG(salary))
```

## Numeric Functions

| Function | Description |
|---|---|
| `ROUND(number, precision)` | Rounds to the given number of decimal places |
| `TRUNCATE(number, precision)` | Truncates without rounding |
| `CEIL(number)` / `CEILING(number)` | Smallest integer ≥ the value |
| `FLOOR(number)` | Largest integer ≤ the value |
| `MOD(number1, number2)` | Remainder of `number1 / number2` (same as `%`) |
| `POWER(number1, number2)` | `number1` raised to the power `number2` |
| `SQRT(number)` | Square root |
| `ABS(number)` | Absolute value |

```sql
SELECT ROUND(12.65) FROM dual;                 -- 13
SELECT ROUND(12.65, 1) FROM dual;               -- 12.7
SELECT ROUND(918273.645, -2) FROM dual;         -- 918300 (round to hundreds)
SELECT TRUNCATE(12.656565, 2) FROM dual;        -- 12.65

SELECT
    salary / 1.245                    AS raw,
    TRUNCATE(salary / 1.245, 0)       AS trunc,
    CEIL(salary / 1.245)              AS ceil,
    ROUND(salary / 1.245)             AS round,
    FLOOR(salary / 1.245)             AS floor
FROM employees WHERE employee_id < 105;

SELECT salary, MOD(salary, 49) FROM employees WHERE employee_id < 105;
SELECT ABS(-salary) FROM employees WHERE employee_id = 101;
```

> **`dual`:** MySQL supports the pseudo-table `DUAL` for compatibility
> with code that expects it (`SELECT expr FROM DUAL;`), but it is
> entirely optional in MySQL — `SELECT expr;` works exactly the same way.

## Character (String) Functions

| Function | Description |
|---|---|
| `UPPER(str)` / `LOWER(str)` | Case conversion |
| `CONCAT(str1, str2, ...)` | Joins two or more strings |
| `SUBSTRING(str, start, length)` | Extracts part of a string |
| `LENGTH(str)` | Length of a string in bytes (`CHAR_LENGTH()` for characters) |
| `INSTR(str, substr)` | Position of the first occurrence of `substr` in `str` |
| `LPAD(str, len, pad)` / `RPAD(str, len, pad)` | Pads a string to a given length |
| `TRIM([BOTH \| LEADING \| TRAILING] [chars] FROM str)` | Removes leading/trailing characters (spaces by default) |
| `REPLACE(str, from_str, to_str)` | Replaces every occurrence of `from_str` with `to_str` |

**Case manipulation**

```sql
SELECT UPPER('hello india') FROM dual;      -- HELLO INDIA
SELECT LOWER('HELLO INDIA') FROM dual;      -- hello india

SELECT first_name, LOWER(first_name), UPPER(first_name) FROM employees;
```

MySQL has no `INITCAP()` built-in; capitalize the first letter of a
string by combining `UPPER`/`LOWER` and `CONCAT`:

```sql
SELECT CONCAT(UPPER(LEFT(first_name, 1)), LOWER(SUBSTRING(first_name, 2)))
    AS proper_case_name
FROM employees;
```

**Concatenation**

```sql
SELECT CONCAT(first_name, last_name) AS employee_name FROM employees;
SELECT CONCAT(first_name, ' ', last_name) AS employee_name FROM employees;
SELECT CONCAT(first_name, ' ', last_name, ' works for ', salary) FROM employees;
```

> Remember: MySQL does **not** use `||` for concatenation by default —
> always use `CONCAT()`.

**Substrings**

```sql
SELECT SUBSTRING(first_name, 1, 5) FROM employees;    -- first 5 characters
SELECT SUBSTRING(first_name, -5) FROM employees;      -- last 5 characters

-- employees whose first and last character of first_name match
SELECT first_name FROM employees
WHERE UPPER(SUBSTRING(first_name, 1, 1)) = UPPER(SUBSTRING(first_name, -1, 1));
```

**Position of a character**

```sql
SELECT INSTR('hello', 'e') FROM dual;                  -- 2
SELECT first_name, INSTR(first_name, 'e') FROM employees;
```

**Padding**

```sql
SELECT LPAD('hello', 10, '*') FROM dual;   -- *****hello
SELECT RPAD('hello', 10, '*') FROM dual;   -- hello*****

SELECT LPAD(first_name, 20, '*') FROM employees;
```

**Length**

```sql
SELECT first_name, LENGTH(first_name) FROM employees;

-- employees whose name is exactly five letters
SELECT first_name FROM employees WHERE LENGTH(first_name) = 5;
```

**Trimming characters**

```sql
SELECT '  Hello World  ', TRIM('  Hello World  ') FROM dual;   -- removes spaces
SELECT TRIM('h' FROM 'hello world') FROM dual;                  -- removes given character

SELECT TRIM(LEADING '@' FROM '@@@hello@@@') FROM dual;   -- hello@@@
SELECT TRIM(TRAILING '@' FROM '@@@hello@@@') FROM dual;  -- @@@hello
SELECT TRIM(BOTH '@' FROM '@@@hello@@@') FROM dual;      -- hello
SELECT TRIM('@' FROM '@@@hello@@@') FROM dual;           -- hello (BOTH is the default)
```

**Replace**

```sql
SELECT REPLACE('local', 'l', '') FROM dual;             -- oca (empty to_str removes chars)
SELECT REPLACE('peter', 'e', 'a') FROM dual;             -- patar

SELECT first_name, REPLACE(first_name, 's', '') AS name FROM employees;
```

## Date and Time Functions

MySQL's default date literal format is `'YYYY-MM-DD'`
(e.g. `'2017-12-10'`), unlike Oracle's `'DD-Mon-YYYY'`.

| Function | Description |
|---|---|
| `NOW()` | Current date and time |
| `CURDATE()` | Current date |
| `DATEDIFF(date1, date2)` | Number of days between two dates |
| `TIMESTAMPDIFF(unit, date1, date2)` | Difference in the given unit (`DAY`, `MONTH`, `YEAR`, ...) |
| `DATE_ADD(date, INTERVAL n unit)` / `DATE_SUB(...)` | Add/subtract an interval from a date |
| `DATE_FORMAT(date, format)` | Format a date as a string |
| `STR_TO_DATE(str, format)` | Parse a string into a date |

```sql
SELECT NOW(), CURDATE();
```

**Difference between two dates**

```sql
SELECT hire_date, ROUND(DATEDIFF(CURDATE(), hire_date) / 365) AS years_of_service
FROM employees;

SELECT DATEDIFF('2017-08-15', '2017-01-26') FROM dual;   -- 201
```

**Adding/subtracting an interval**

```sql
SELECT hire_date, DATE_ADD(hire_date, INTERVAL 65 DAY) FROM employees;

SELECT DATE_ADD('2014-06-10', INTERVAL 555 DAY) FROM dual;
SELECT DATE_ADD(CURDATE(), INTERVAL 6 MONTH) FROM dual;
SELECT DATE_ADD(CURDATE(), INTERVAL 1 YEAR) FROM dual;
```

**Months between two dates**

```sql
SELECT TIMESTAMPDIFF(MONTH, '2017-01-26', '2017-08-15') FROM dual;   -- 6

SELECT ROUND(TIMESTAMPDIFF(MONTH, hire_date, CURDATE())) FROM employees;
```

**Formatting a date for display**

`DATE_FORMAT()` is MySQL's equivalent of Oracle's `TO_CHAR(date, format)`.
Common format specifiers:

| Specifier | Meaning |
|---|---|
| `%Y` | 4-digit year |
| `%m` | 2-digit month |
| `%M` | Full month name |
| `%b` | Abbreviated month name |
| `%d` | 2-digit day of month |
| `%D` | Day of month with English suffix (1st, 2nd, 3rd) |
| `%W` | Full weekday name |
| `%a` | Abbreviated weekday name |
| `%H` | 24-hour |
| `%h` | 12-hour |
| `%i` | Minutes |
| `%s` | Seconds |
| `%p` | AM / PM |

```sql
SELECT DATE_FORMAT(CURDATE(), '%d/%M/%Y') FROM dual;
SELECT hire_date, DATE_FORMAT(hire_date, '%d/%M/%Y') FROM employees;
SELECT DATE_FORMAT(hire_date, '%W, %D %M %Y') FROM employees;

SELECT DATE_FORMAT('1947-08-15', '%D %M %Y') AS independence_day FROM dual;
```

**Parsing a string into a date**

`STR_TO_DATE()` is MySQL's equivalent of Oracle's `TO_DATE()`:

```sql
SELECT STR_TO_DATE('20160820', '%Y%m%d') FROM dual;
SELECT STR_TO_DATE('15-Aug-2017', '%d-%b-%Y') FROM dual;
```

**Formatting numbers**

MySQL's `FORMAT()` function adds thousands separators (Oracle's
`TO_CHAR(number, format)` equivalent):

```sql
SELECT FORMAT(1234567.891, 2) FROM dual;   -- 1,234,567.89
```

## Type Conversion

- **Implicit conversion** — MySQL converts data types automatically
  where it safely can (e.g. comparing a string `'105'` to an integer
  column).
- **Explicit conversion** — use `CAST()` or `CONVERT()`:

```sql
SELECT CAST('1024' AS SIGNED) FROM dual;          -- string to integer
SELECT CAST('20160820' AS DATE) FROM dual;         -- ISO string to date (only for YYYY-MM-DD)
SELECT CAST(salary AS CHAR) FROM employees;        -- number to string
SELECT CONVERT(salary, DECIMAL(10,2)) FROM employees;
```

## Functions for Handling NULLs

| Function | Behavior |
|---|---|
| `IFNULL(expr, replacement)` | Returns `replacement` if `expr` is `NULL`, else `expr` (Oracle's `NVL`) |
| `IF(condition, val_if_true, val_if_false)` | General-purpose conditional (Oracle's `NVL2` use case) |
| `NULLIF(expr1, expr2)` | Returns `NULL` if `expr1 = expr2`, else `expr1` |
| `COALESCE(expr1, expr2, ...)` | Returns the first non-`NULL` expression in the list |

```sql
-- treat a NULL commission as 0
SELECT employee_id, commission_pct, IFNULL(commission_pct, 0) AS commission
FROM employees;

-- NVL2-style: yes/no if the value is present
SELECT first_name, commission_pct,
       IF(commission_pct IS NOT NULL, 'yes', 'no') AS has_commission
FROM employees;

-- default a NULL job_id to a known job
UPDATE employees SET job_id = 1 WHERE job_id IS NULL;

SELECT NULLIF(commission_pct, salary) FROM employees;

SELECT employee_id, commission_pct,
       COALESCE(commission_pct, salary, 10) AS effective_value
FROM employees WHERE employee_id < 106;
```

## Conditional Expressions: CASE

`CASE` implements if-then-else logic inside a query.

**Simple CASE** — compares one expression against a list of exact values.

```sql
SELECT employee_id, first_name, department_id, salary,
    CASE department_id
        WHEN 10 THEN salary + 3000
        WHEN 20 THEN salary + 2000
        WHEN 30 THEN salary + 5000
        ELSE salary
    END AS increased_salary
FROM employees
ORDER BY department_id;
```

**Searched CASE** — each `WHEN` holds a full boolean condition.

```sql
SELECT employee_id, first_name, salary,
    CASE
        WHEN salary > 100000 THEN 'High Salary'
        WHEN salary > 60000  THEN 'Medium Salary'
        WHEN salary > 40000  THEN 'Low Salary'
        ELSE 'Entry Salary'
    END AS salary_range
FROM employees;
```

MySQL has no direct equivalent of Oracle's `DECODE()`; a searched `CASE`
covers the same use cases and is standard SQL.

---
**Next:** [07 · GROUP BY, Aggregates & Window Functions](07-group-by-aggregate-and-window-functions.md)
