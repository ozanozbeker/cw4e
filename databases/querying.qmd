# Querying Data

Your manager at Northwind Traders has a simple request: "Tell me about our product catalog. What do we sell, what does it cost, and what's running low in the warehouse?" This is the kind of question that drives real analytical work, and answering it requires you to be precise about what data you want, how to filter it, and how to organize the results.

This chapter teaches the core SQL statements that make that precision possible. You'll learn to select specific columns, filter rows by condition, sort results, handle missing values, compute summaries like totals and averages, and combine results from multiple queries using set operations. By the end, you'll be able to take a business question, translate it into SQL, and deliver a clean answer, all working within a single table.

## The Structure of a SQL Query

SQL is a **declarative** language. Unlike Python or Java, where you write step-by-step instructions telling the computer *how* to do something, SQL describes *what* you want and lets the database figure out how to get it. You say "give me all products under $20, sorted by price," and the database decides whether to use an index, scan the table, or employ some other optimization. This is a fundamentally different way of thinking about computation, and it takes some adjustment if you're coming from procedural programming.

The most common SQL statement is `SELECT`, which retrieves data from one or more tables. A basic query has this structure:

```{.sql filename="duckdb"}
SELECT columns
FROM table
WHERE conditions
ORDER BY columns
LIMIT count;
```

Each of these clauses plays a specific role, and you'll learn them one at a time. But here's something crucial to understand from the start: **the order you write SQL is not the order the database executes it**.

You write `SELECT` first, but the database processes `FROM` first (to know which table to look at), then `WHERE` (to filter rows), then `SELECT` (to choose columns), then `ORDER BY` (to sort), then `LIMIT` (to cap the output). This execution order explains many otherwise-confusing SQL behaviors, and we'll return to it throughout this chapter.

```
Written Order:     SELECT → FROM → WHERE → ORDER BY → LIMIT
Execution Order:   FROM → WHERE → SELECT → ORDER BY → LIMIT
```

Keep this mental model handy. When a query doesn't behave the way you expect, the execution order is often the explanation.

## SELECT and FROM: Choosing What to See

The simplest useful query asks for specific columns from a table:

```{.sql filename="duckdb"}
SELECT
    productName,
    unitPrice,
    unitsInStock
FROM products;
```

This returns three columns from every row in the `products` table. Notice that we're choosing *which* information to see, not loading the entire table. In a column-oriented database like DuckDB, this distinction matters for performance: the engine only reads the columns you asked for.

To see everything, you can use `SELECT *`:

```{.sql filename="duckdb"}
SELECT * FROM products;
```

The `*` means "all columns." This is useful for exploration, but in production queries and scripts, you should always name your columns explicitly. When someone reads your SQL six months from now (including future you), `SELECT *` doesn't communicate what data actually matters to the analysis.

::: {.callout-tip}
## DuckDB's FROM-First Shorthand
DuckDB allows you to write `FROM` without `SELECT`, which is convenient during exploration:

```{.sql filename="duckdb"}
-- [DUCKDB EXTENSION] FROM-first syntax
FROM products;
```

This is equivalent to `SELECT * FROM products`. It's useful when you're poking around a new table and want to see what's there. Throughout this book, we'll use the full `SELECT ... FROM` syntax for clarity in teaching, and the shorthand when we're just exploring. This is a DuckDB convenience, not standard SQL, so it won't work in PostgreSQL or MySQL.
:::

### Column Aliases

Sometimes column names are cryptic or you want to label computed results. The `AS` keyword creates an **alias**:

```{.sql filename="duckdb"}
SELECT
    productName AS product,
    unitPrice AS price_usd,
    unitsInStock AS inventory
FROM products;
```

The alias changes the column name in the output without changing anything in the underlying table. This is purely cosmetic, but it makes results much easier to read, especially when you start computing new columns.

### Computing New Columns

SQL lets you create new columns from expressions:

```{.sql filename="duckdb"}
SELECT
    productName,
    unitPrice,
    unitsInStock,
    unitPrice * unitsInStock AS inventory_value
FROM products;
```

The `inventory_value` column doesn't exist in the table. It's computed on the fly for each row by multiplying price and stock. This is one of SQL's strengths: you can derive new information without modifying the original data.

### DISTINCT: Removing Duplicates

When you want to see the unique values in a column, `DISTINCT` eliminates duplicate rows:

```{.sql filename="duckdb"}
SELECT DISTINCT country
FROM suppliers;
```

This returns each country exactly once, regardless of how many suppliers are in each country. `DISTINCT` applies to the entire row, so `SELECT DISTINCT country, city FROM suppliers` returns unique country-city combinations.

::: {.callout-note title="Exercises"}
1. Write a query that returns the `companyName`, `contactName`, and `country` columns from the `customers` table.

2. Write a query that computes an `inventory_value` for each product (price times units in stock) and also a `potential_revenue` column that adds in units currently on order. Use appropriate aliases. What happens to `potential_revenue` for products where `unitsOnOrder` is `NULL`?

3. How many distinct countries do Northwind's customers come from? Write the query, then adjust it to find how many distinct *city-country* combinations there are. Why is the second number larger?

4. Predict the output of this query without running it. Then run it to check.

    ```{.sql filename="duckdb"}
    SELECT DISTINCT categoryID
    FROM products
    ORDER BY categoryID;
    ```
:::

## WHERE: Filtering Rows

`SELECT` chooses columns. `WHERE` chooses rows. It evaluates a condition for every row and only keeps the rows where the condition is true.

```{.sql filename="duckdb"}
SELECT
    productName,
    unitPrice
FROM products
WHERE unitPrice < 20;
```

This returns only the products that cost less than $20. The comparison operators work as you'd expect: `=` (equal), `!=` or `<>` (not equal), `<`, `>`, `<=`, `>=`.

::: {.callout-warning}
## Equality Uses Single Equals
SQL uses `=` for equality comparisons, not `==`. If you're coming from Python, this will trip you up at first. In SQL, `WHERE country = 'USA'` is correct. `WHERE country == 'USA'` is a syntax error in most databases (though DuckDB is forgiving and accepts both).
:::

### Combining Conditions

Use `AND` and `OR` to combine multiple conditions:

```{.sql filename="duckdb"}
-- Products under $20 with low stock
SELECT
    productName,
    unitPrice,
    unitsInStock
FROM products
WHERE unitPrice < 20
  AND unitsInStock < 30;
```

```{.sql filename="duckdb"}
-- Products from supplier 1 or supplier 2
SELECT
    productName,
    supplierID
FROM products
WHERE supplierID = 1
   OR supplierID = 2;
```

When mixing `AND` and `OR`, use parentheses to be explicit about grouping. SQL evaluates `AND` before `OR` (like multiplication before addition in math), which can produce unexpected results:

```{.sql filename="duckdb"}
-- Without parentheses: AND binds tighter, which may surprise you
SELECT productName, unitPrice, supplierID
FROM products
WHERE supplierID = 1 OR supplierID = 2 AND unitPrice < 20;

-- With parentheses: your intent is clear
SELECT productName, unitPrice, supplierID
FROM products
WHERE (supplierID = 1 OR supplierID = 2) AND unitPrice < 20;
```

Always use parentheses when combining `AND` and `OR`. Future readers of your code (and the database engine) will thank you.

### Useful Filtering Patterns

**IN** checks membership in a list, replacing multiple `OR` conditions:

```{.sql filename="duckdb"}
-- Instead of: WHERE country = 'USA' OR country = 'UK' OR country = 'Germany'
SELECT companyName, country
FROM suppliers
WHERE country IN ('USA', 'UK', 'Germany');
```

**BETWEEN** checks a range (inclusive on both ends):

```{.sql filename="duckdb"}
SELECT productName, unitPrice
FROM products
WHERE unitPrice BETWEEN 10 AND 30;
```

**LIKE** matches text patterns, where `%` represents any sequence of characters and `_` represents a single character:

```{.sql filename="duckdb"}
-- Products whose names start with "Ch"
SELECT productName
FROM products
WHERE productName LIKE 'Ch%';
```

**IS NULL** and **IS NOT NULL** check for missing values, which deserve their own section.

## NULL: The Absence of Data

`NULL` is one of SQL's most important and most misunderstood concepts. A `NULL` value means "unknown" or "missing", not zero, not empty string, not false. It means the data simply doesn't exist.

In the Northwind database, the `region` column in the `customers` table contains `NULL` for customers where the region wasn't recorded. This isn't the same as the region being blank. It means we don't know the region.

The critical rule is: **NULL is not equal to anything, including itself**. This means ordinary comparisons don't work:

```{.sql filename="duckdb"}
-- This does NOT find customers with missing regions
SELECT companyName, region
FROM customers
WHERE region = NULL;  -- Returns nothing! NULL = NULL is not TRUE, it's NULL

-- This is correct
SELECT companyName, region
FROM customers
WHERE region IS NULL;
```

Any arithmetic or comparison involving `NULL` produces `NULL`. If `unitsOnOrder` is `NULL` for some product, then `unitsInStock + unitsOnOrder` is also `NULL` for that product, not just `unitsInStock`. This propagation of unknowns is logically sound (you can't add a number to an unknown and get a known result), but it catches people off guard constantly.

::: {.callout-important}
## The Three-Value Logic of SQL
Most programming languages have two-value boolean logic: `TRUE` and `FALSE`. SQL has three: `TRUE`, `FALSE`, and `NULL` (unknown). The `WHERE` clause only keeps rows where the condition evaluates to `TRUE`, meaning rows where the condition is `NULL` are filtered out just like rows where it's `FALSE`. This is why `WHERE region = NULL` returns nothing: the comparison yields `NULL`, not `TRUE`.
:::

The `COALESCE` function provides a fallback value when data might be `NULL`:

```{.sql filename="duckdb"}
SELECT
    productName,
    COALESCE(unitsOnOrder, 0) AS units_on_order
FROM products;
```

`COALESCE` takes any number of arguments and returns the first non-`NULL` value. It's your primary tool for handling missing data in queries.

::: {.callout-note title="Exercises"}
1. Write a query that finds all products with a unit price between $15 and $25 that are not discontinued. Return the product name, unit price, and units in stock.

2. Find all customers in either Germany, France, or Brazil whose contact title contains the word "Manager" (use `LIKE`). How many are there?

3. This query has a bug. What's wrong, and what does it actually return?

    ```{.sql filename="duckdb"}
    SELECT companyName, region
    FROM customers
    WHERE region != NULL;
    ```

4. Write a query that returns all products, replacing any `NULL` values in `unitsOnOrder` with `0`, and then computes a `total_units` column that adds `unitsInStock` and the cleaned `unitsOnOrder`. Why would the results be different without `COALESCE`?

5. Explain, in one sentence each, the difference between these three expressions: `WHERE region = 'WA'`, `WHERE region IS NULL`, and `WHERE region != 'WA'`. Which customers does the third expression exclude that might surprise you?
:::

## ORDER BY: Sorting Results

Results from a SQL query have no guaranteed order unless you specify one. The `ORDER BY` clause sorts the output:

```{.sql filename="duckdb"}
SELECT
    productName,
    unitPrice
FROM products
ORDER BY unitPrice;
```

By default, `ORDER BY` sorts in ascending order (smallest to largest, A to Z). Add `DESC` for descending order:

```{.sql filename="duckdb"}
-- Most expensive products first
SELECT
    productName,
    unitPrice
FROM products
ORDER BY unitPrice DESC;
```

You can sort by multiple columns. The first column is the primary sort, the second breaks ties:

```{.sql filename="duckdb"}
-- Sort by category, then by price within each category
SELECT
    categoryID,
    productName,
    unitPrice
FROM products
ORDER BY categoryID, unitPrice DESC;
```

`NULL` values sort last in ascending order and first in descending order by default. You can control this with `NULLS FIRST` or `NULLS LAST` if needed.

## LIMIT: Capping the Output

`LIMIT` restricts how many rows are returned. This is essential for exploration (you rarely want to scroll through 100,000 rows) and for answering "top N" questions:

```{.sql filename="duckdb"}
-- The 10 most expensive products
SELECT
    productName,
    unitPrice
FROM products
ORDER BY unitPrice DESC
LIMIT 10;
```

Always pair `LIMIT` with `ORDER BY`. Without `ORDER BY`, `LIMIT 10` gives you 10 arbitrary rows, which is meaningless for analysis.

## Aggregate Functions: Summarizing Data

Individual rows tell you about specific products. Aggregate functions tell you about the *collection*. They collapse many rows into a single summary value.

The five fundamental aggregates are:

```{.sql filename="duckdb"}
SELECT
    COUNT(*) AS total_products,
    AVG(unitPrice) AS avg_price,
    SUM(unitsInStock) AS total_inventory,
    MIN(unitPrice) AS cheapest,
    MAX(unitPrice) AS most_expensive
FROM products;
```

`COUNT(*)` counts rows. `AVG`, `SUM`, `MIN`, and `MAX` operate on a specific column. All aggregate functions except `COUNT(*)` ignore `NULL` values, which is important: `AVG(unitPrice)` computes the average over only the rows where `unitPrice` is not `NULL`.

`COUNT` has a subtle distinction worth knowing:

```{.sql filename="duckdb"}
-- COUNT(*) counts all rows, regardless of NULLs
SELECT COUNT(*) FROM customers;

-- COUNT(column) counts only non-NULL values in that column
SELECT COUNT(region) FROM customers;

-- COUNT(DISTINCT column) counts unique non-NULL values
SELECT COUNT(DISTINCT country) FROM customers;
```

## CASE: Conditional Logic

The `CASE` expression brings if-then logic into SQL. It evaluates conditions in order and returns the value for the first matching condition:

```{.sql filename="duckdb"}
SELECT
    productName,
    unitPrice,
    CASE
        WHEN unitPrice >= 50 THEN 'Premium'
        WHEN unitPrice >= 20 THEN 'Standard'
        ELSE 'Budget'
    END AS price_tier
FROM products
ORDER BY unitPrice DESC;
```

`CASE` is remarkably useful. You'll use it to categorize data, create flag columns, handle conditional calculations, and build readable output. Notice the `END` keyword that closes the expression, and the optional `ELSE` that provides a default when no conditions match (without `ELSE`, unmatched rows get `NULL`).

You can use `CASE` inside aggregate functions to count or sum conditionally:

```{.sql filename="duckdb"}
SELECT
    COUNT(*) AS total_products,
    COUNT(CASE WHEN discontinued = 1 THEN 1 END) AS discontinued_count,
    COUNT(CASE WHEN unitsInStock = 0 THEN 1 END) AS out_of_stock_count
FROM products;
```

::: {.callout-note title="Exercises"}
1. Write a query that returns the 5 cheapest products that are not discontinued. Include the product name and price.

2. Using aggregate functions, answer these questions in a single query: How many products does Northwind carry? What is the average unit price? What is the total value of all inventory (sum of price × stock for all products)?

3. Using `CASE`, write a query that classifies each product's stock status: "Out of Stock" if `unitsInStock` is 0, "Critical" if stock is at or below the reorder level, "Adequate" otherwise. Return the product name, units in stock, reorder level, and stock status. Sort the results so that out-of-stock and critical products appear first. (We'll learn to *count* how many products fall into each category in the Analytical SQL chapter.)

4. What is wrong with this query? Predict what error you'll get, then run it to confirm.

    ```{.sql filename="duckdb"}
    SELECT
        productName,
        AVG(unitPrice)
    FROM products;
    ```

5. Using aggregate functions and `CASE` together, write a single query that computes: the total number of products, the number of discontinued products, the number of products currently out of stock (not discontinued but `unitsInStock = 0`), and the average price of active (not discontinued) products. (Hint: use `CASE` expressions inside `COUNT` and `AVG` to compute conditional aggregates without grouping.)
:::

## Set Operations: Combining Query Results

Sometimes you need to combine the results of two separate queries into one result set. SQL provides **set operations** for this, and if you've taken a statistics course, the concepts will feel familiar: they map directly to the set theory operations of union, intersection, and difference.

Unlike joins, which combine columns from different tables side by side, set operations stack rows from multiple queries on top of each other. The key requirement is that both queries must return the same number of columns with compatible data types.

### UNION and UNION ALL

`UNION` combines the results of two queries and removes duplicate rows. `UNION ALL` does the same but keeps all rows, including duplicates.

```{.sql filename="duckdb"}
-- [STANDARD SQL] All unique cities where we have either a supplier or a customer
SELECT city, country, 'Supplier' AS entity_type
FROM suppliers
UNION
SELECT city, country, 'Customer' AS entity_type
FROM customers
ORDER BY country, city;
```

This query answers: "In which cities do we have a business presence, either through a supplier or a customer?" The `UNION` removes any city that appears in both tables, giving you the unique set. If a city like London appears as both a supplier location and a customer location, you'd see it once (with whichever `entity_type` the database kept).

If you want to preserve both rows, use `UNION ALL`:

```{.sql filename="duckdb"}
-- [STANDARD SQL] All cities, keeping supplier and customer entries separate
SELECT city, country, 'Supplier' AS entity_type
FROM suppliers
UNION ALL
SELECT city, country, 'Customer' AS entity_type
FROM customers
ORDER BY country, city;
```

`UNION ALL` is significantly faster than `UNION` (often 3 to 4x) because it skips the duplicate detection and removal step. Use `UNION ALL` when duplicates are acceptable or when you know they don't exist. In practice, `UNION ALL` is far more common in analytical work because you usually want to preserve all records.

### INTERSECT

`INTERSECT` returns only the rows that appear in both queries:

```{.sql filename="duckdb"}
-- [STANDARD SQL] Countries where we have BOTH a supplier and a customer
SELECT country FROM suppliers
INTERSECT
SELECT country FROM customers
ORDER BY country;
```

This answers: "Which countries represent both sides of our supply chain?" These are countries where Northwind both sources products and sells to customers, potentially interesting for logistics optimization.

### EXCEPT

`EXCEPT` returns rows from the first query that don't appear in the second:

```{.sql filename="duckdb"}
-- [STANDARD SQL] Countries where we have customers but no suppliers
SELECT country FROM customers
EXCEPT
SELECT country FROM suppliers
ORDER BY country;
```

This identifies countries where Northwind has customers but no local supplier. The order matters: `A EXCEPT B` gives you rows in A that aren't in B, which is different from `B EXCEPT A`.

A particularly useful application of `EXCEPT` is data validation, verifying that two queries produce identical results:

```{.sql filename="duckdb"}
-- [STANDARD SQL] Check if two queries return the same results
-- An empty result means the queries match
(SELECT productID, productName FROM products WHERE unitPrice > 20)
EXCEPT
(SELECT productID, productName FROM products WHERE NOT unitPrice <= 20);
```

### Set Operations and Venn Diagrams

You'll often see joins explained with Venn diagrams online, but as we'll discuss in the next chapter, that analogy is misleading for joins. Set operations, however, are exactly where Venn diagrams apply correctly. `UNION` is A ∪ B (everything in either circle), `INTERSECT` is A ∩ B (the overlap), and `EXCEPT` is A − B (in A but not in B). Both sides represent complete rows of the same structure, and the operations combine, overlap, or subtract those rows, which is precisely what Venn diagrams model.

### Compatibility Rules

All set operations require the same number of columns in both queries, compatible data types in corresponding positions (you can't union an integer column with a text column), and column names come from the first query only. `ORDER BY` applies to the entire combined result and appears once at the end, not within individual queries.

::: {.callout-note title="Exercises"}
1. Write a query using `INTERSECT` to find cities that appear in both the `suppliers` and `customers` tables. How many shared cities are there?

2. Write a query using `EXCEPT` to find countries where Northwind has suppliers but no customers. What does this suggest about Northwind's supply chain?

3. A colleague writes this query and gets an error. What's wrong?

    ```{.sql filename="duckdb"}
    SELECT companyName, city FROM suppliers
    UNION
    SELECT city, country FROM customers;
    ```

4. Write a query using `UNION ALL` that creates a combined directory of all supplier and customer contacts, with columns for `companyName`, `contactName`, `phone`, and a label column (`'Supplier'` or `'Customer'`). Why is `UNION ALL` more appropriate than `UNION` here?
:::

## Putting It All Together

Let's return to the manager's original question: "What do we sell, what does it cost, and what's running low?" Now you have the vocabulary to answer precisely:

```{.sql filename="duckdb"}
SELECT
    productName AS product,
    unitPrice AS price,
    unitsInStock AS stock,
    reorderLevel AS reorder_point,
    unitsInStock - reorderLevel AS stock_above_reorder,
    CASE
        WHEN discontinued = 1 THEN 'Discontinued'
        WHEN unitsInStock = 0 THEN 'OUT OF STOCK'
        WHEN unitsInStock <= reorderLevel THEN 'Reorder Now'
        WHEN unitsInStock <= reorderLevel * 1.5 THEN 'Running Low'
        ELSE 'Adequate'
    END AS stock_status
FROM products
WHERE discontinued = 0
ORDER BY stock_above_reorder;
```

This single query retrieves product information, computes how far above (or below) the reorder point each product is, categorizes the stock status, excludes discontinued products, and sorts so the most urgent items appear first. That's a complete analytical deliverable in 15 lines of SQL.

To build your intuition, pick a specific product from the result set and trace through the `CASE` expression by hand. What are the values of `discontinued`, `unitsInStock`, and `reorderLevel` for that product? Which `WHEN` branch does it match? What would happen if you reordered the `WHEN` clauses? Since `CASE` evaluates top-to-bottom and stops at the first match, clause order matters, and tracing through specific rows is the best way to verify that your logic handles every scenario correctly.

Read this query carefully, because it demonstrates something important about the whole game: the value isn't in knowing that `WHERE` filters rows or `ORDER BY` sorts results. The value is in translating a business question into a precise, readable query that someone else can understand, verify, and build on. That translation, from human question to structured query, is the skill that matters.

## Chapter Exercises

These exercises require combining multiple concepts from the chapter. Approach each one by identifying the business question first, then building the SQL step by step.

1. **Inventory risk report.** Write a single query that identifies all active (not discontinued) products where the current stock is below the reorder level AND there are no units on order (treating `NULL` as zero using `COALESCE`). Return the product name, current stock, reorder level, units on order (with `NULL` replaced by 0), and the deficit (reorder level minus stock). Sort by the deficit so the most urgent items appear first. This is a query a warehouse manager would actually run.

2. **Price tier classification.** Your manager asks: "Show me our product catalog organized by price tier." Write a query that uses `CASE` to classify each product into price tiers: "Budget" (under $10), "Standard" ($10 to $25), "Premium" ($25 to $50), and "Luxury" (over $50). Return the product name, unit price, and price tier. Sort by unit price descending. Then write a *second* query that uses conditional aggregation (CASE inside COUNT and AVG) to compute, in a single row, how many products fall into each tier and the overall average price of active products. This second query should not use `GROUP BY`.

3. **Execution order detective.** Explain why this query produces an error, referencing the SQL execution order:

    ```{.sql filename="duckdb"}
    SELECT
        productName,
        unitPrice * unitsInStock AS inventory_value
    FROM products
    WHERE inventory_value > 1000;
    ```

    Then rewrite it so it works correctly.

4. **NULL audit.** Write a query that counts, for each column in the `customers` table that might contain NULLs (`region`, `fax`), how many rows have `NULL` values and what percentage of the total that represents. This is a common data quality check. (Hint: you can compute everything in a single query using `COUNT(*)` and `COUNT(column)` together.)

5. **Complete business directory.** The Northwind CEO wants a single report listing every company Northwind does business with, including suppliers, customers, and shippers. For each company, show the company name, the type of relationship (`'Supplier'`, `'Customer'`, or `'Shipper'`), and the country (shippers don't have a country in the data, so use `'N/A'`). Sort alphabetically by company name. Which set operation is the right choice here, and why?

6. **NULL propagation challenge.** Predict the result of each expression *before* running it, then verify. For any that surprise you, explain why SQL produces that result.

    ```{.sql filename="duckdb"}
    SELECT
        NULL = NULL AS test_1,
        NULL != NULL AS test_2,
        NULL AND TRUE AS test_3,
        NULL OR TRUE AS test_4,
        NULL OR FALSE AS test_5,
        COALESCE(NULL, NULL, 'fallback') AS test_6,
        5 + NULL AS test_7,
        5 > NULL AS test_8;
    ```

    Then explain in your own words why `WHERE region != 'WA'` does *not* return customers whose region is `NULL`.

7. **Debug this report.** A colleague wrote the following query to produce an inventory summary, but the results don't look right. There are at least three problems. Find them all and write a corrected version.

    ```{.sql filename="duckdb"}
    SELECT
        productName,
        unitPrice AS price,
        unitsInStock + unitsOnOrder AS total_units,
        CASE
            WHEN total_units = 0 THEN 'Out of Stock'
            WHEN unitsInStock <= reorderLevel THEN 'Reorder'
            ELSE 'OK'
        END AS status
    FROM products
    WHERE discontinued = 0
    ORDER BY total_units;
    ```

    (Hints: think about NULLs, execution order, and the CASE logic for a product with 0 in stock but 50 on order.)

## Summary

SQL queries follow a `SELECT ... FROM ... WHERE ... ORDER BY ... LIMIT` structure, but the database executes them in a different order: `FROM` first (find the table), then `WHERE` (filter rows), then `SELECT` (choose columns), then `ORDER BY` (sort), then `LIMIT` (cap output). Understanding this execution order prevents common errors. `SELECT` retrieves specific columns, and the `AS` keyword creates aliases for readability. `WHERE` filters rows using comparison operators, `AND`/`OR` logic, `IN` for lists, `BETWEEN` for ranges, and `LIKE` for text patterns. `NULL` represents missing data and behaves differently from any concrete value: it is not equal to anything, propagates through operations, and requires `IS NULL` / `IS NOT NULL` for testing. SQL uses three-value logic (`TRUE`, `FALSE`, `NULL`), and `WHERE` only keeps rows where the condition is `TRUE`. `ORDER BY` sorts results (defaulting to ascending), and `LIMIT` caps the number of rows returned. Aggregate functions (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) collapse many rows into summary statistics. `CASE` expressions add conditional logic, enabling categorization and conditional aggregation within a single query. Set operations (`UNION`, `UNION ALL`, `INTERSECT`, `EXCEPT`) combine results from multiple queries vertically, stacking rows rather than joining columns, with `UNION ALL` being the most common in analytical work because it preserves all rows and runs faster than `UNION`.

## Glossary

**Aggregate Function**
:   A function that takes multiple rows as input and returns a single summary value. `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX` are the five fundamental aggregates.

**Alias**
:   An alternative name assigned to a column or table in a query using the `AS` keyword, improving readability without modifying the underlying data.

**CASE Expression**
:   A SQL construct that evaluates conditions in order and returns the value associated with the first matching condition, providing if-then logic within queries.

**Clause**
:   A component of a SQL statement that performs a specific function. `SELECT`, `FROM`, `WHERE`, `ORDER BY`, and `LIMIT` are clauses.

**COALESCE**
:   A function that returns the first non-`NULL` value from a list of arguments, commonly used to provide fallback values for missing data.

**Declarative Language**
:   A programming paradigm where you describe *what* result you want rather than *how* to compute it. SQL is declarative: you specify the desired output, and the database determines the execution strategy.

**DISTINCT**
:   A keyword that eliminates duplicate rows from query results, returning only unique combinations of the selected columns.

**EXCEPT**
:   A set operation that returns rows from the first query that do not appear in the second query's results. Equivalent to the set difference (A − B) in set theory.

**Execution Order**
:   The sequence in which the database processes the clauses of a SQL statement, which differs from the order in which they are written. The logical execution order is `FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT`.

**INTERSECT**
:   A set operation that returns only the rows that appear in both queries' results. Equivalent to the intersection (A ∩ B) in set theory.

**NULL**
:   A special marker in SQL representing the absence of a value, meaning "unknown" or "missing." `NULL` is not equal to anything, including itself, and requires special handling with `IS NULL` and `IS NOT NULL`.

**Predicate**
:   A condition in a `WHERE` clause that evaluates to `TRUE`, `FALSE`, or `NULL` for each row, determining which rows are included in the result.

**Set Operation**
:   A SQL operation that combines the results of two queries vertically (stacking rows). `UNION`, `UNION ALL`, `INTERSECT`, and `EXCEPT` are the four set operations, and they require compatible column structures in both queries.

**UNION / UNION ALL**
:   Set operations that combine rows from two queries. `UNION` removes duplicate rows from the combined result, while `UNION ALL` preserves all rows including duplicates and is significantly faster.
