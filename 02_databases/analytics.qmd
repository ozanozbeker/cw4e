# Analytical SQL

Up to this point, you've been asking pointed questions: "Which products cost less than $20?" "Which supplier provides Chai?" These are retrieval questions, and they're important. But the questions that drive business decisions are usually about *patterns*: How are sales trending over time? Which product categories generate the most revenue? Who are our top customers, and are they buying more or less than last quarter? Answering these questions requires aggregating, grouping, ranking, and comparing data, and that's the territory this chapter covers.

This chapter introduces `GROUP BY` for categorized summaries, `HAVING` for filtering those summaries, subqueries and Common Table Expressions (CTEs) for building complex logic in stages, and window functions for computations that need both individual row detail and aggregate context. These are the tools that separate someone who can look things up in a database from someone who can analyze it.

## GROUP BY: Summarizing by Category

You've already used aggregate functions like `COUNT` and `AVG` to compute a single summary across an entire table. `GROUP BY` lets you compute those same summaries *within categories*. Instead of "what's the average product price?", you can ask "what's the average product price *per category*?"

```{.sql filename="duckdb"}
-- [STANDARD SQL]
SELECT
    categoryID,
    COUNT(*) AS product_count,
    ROUND(AVG(unitPrice), 2) AS avg_price,
    SUM(unitsInStock) AS total_stock
FROM products
GROUP BY categoryID;
```

This query divides the `products` table into groups (one group per `categoryID`), then computes the aggregates independently within each group. The result has one row per category, not one row per product.

The rule is strict: **every column in `SELECT` must either appear in `GROUP BY` or be inside an aggregate function**. You can't ask for `productName` here because there are many product names within each category, and the database doesn't know which one to show. This is the single most common `GROUP BY` error, and the error message you'll see (something like "column must appear in GROUP BY clause or be used in an aggregate function") will become familiar fast.

### Grouping by Multiple Columns

You can group by multiple columns to create finer-grained summaries:

```{.sql filename="duckdb"}
-- [STANDARD SQL]
SELECT
    s.country,
    c.categoryName,
    COUNT(*) AS product_count,
    ROUND(AVG(p.unitPrice), 2) AS avg_price
FROM products AS p
INNER JOIN suppliers AS s ON p.supplierID = s.supplierID
INNER JOIN categories AS c ON p.categoryID = c.categoryID
GROUP BY s.country, c.categoryName
ORDER BY s.country, c.categoryName;
```

Each unique combination of `country` and `categoryName` gets its own row and its own aggregate values. This is how you build the kind of cross-tabulated summaries that populate business reports.

::: {.callout-tip}
## DuckDB's GROUP BY ALL
When every non-aggregate column in your `SELECT` should be in the `GROUP BY` (which is almost always the case), DuckDB lets you write:

```{.sql filename="duckdb"}
-- [DUCKDB EXTENSION] GROUP BY ALL infers grouping columns
SELECT
    s.country,
    c.categoryName,
    COUNT(*) AS product_count
FROM products AS p
INNER JOIN suppliers AS s ON p.supplierID = s.supplierID
INNER JOIN categories AS c ON p.categoryID = c.categoryID
GROUP BY ALL;
```

`GROUP BY ALL` automatically groups by every non-aggregate column in `SELECT`. This is a DuckDB convenience, not standard SQL. The portable equivalent is to list every non-aggregate column explicitly in `GROUP BY`, as shown above.
:::

## HAVING: Filtering Groups

`WHERE` filters individual rows *before* grouping. `HAVING` filters groups *after* aggregation. The distinction maps directly to the execution order: `WHERE` runs before `GROUP BY`, so it operates on individual rows. `HAVING` runs after, so it operates on the aggregated results.

"Which countries have more than 3 suppliers?"

```{.sql filename="duckdb"}
-- [STANDARD SQL]
SELECT
    country,
    COUNT(*) AS supplier_count
FROM suppliers
GROUP BY country
HAVING COUNT(*) > 3
ORDER BY supplier_count DESC;
```

You cannot use `HAVING` without `GROUP BY`, and you cannot use a column alias in `HAVING` in standard SQL (because `HAVING` is processed before `SELECT` assigns the alias). DuckDB is lenient and allows aliases in `HAVING`, but writing the full aggregate expression makes your code portable.

Here's the complete logical execution order with all clauses you've learned so far:

```
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

This means `WHERE` can't reference aggregate results (they don't exist yet), and `HAVING` can't reference column aliases from `SELECT` in standard SQL. When something doesn't work, trace through this execution order to find out why.

::: {.callout-note title="Exercises"}
1. Write a query that counts how many products are in each category and computes the average unit price per category. Join to `categories` to show the category name rather than the ID. Which category has the most products? Which has the highest average price?

2. Write a query that finds all countries with more than 5 customers. Show the country and customer count, sorted by count descending.

3. This query is supposed to find categories where the average product price exceeds $25, but it has a bug. Find it and fix it:

    ```{.sql filename="duckdb"}
    SELECT
        categoryID,
        AVG(unitPrice) AS avg_price
    FROM products
    WHERE AVG(unitPrice) > 25
    GROUP BY categoryID;
    ```

4. Explain the difference between `WHERE` and `HAVING` using the execution order diagram. Why can't `WHERE` filter on aggregate results?
:::

## Subqueries: Queries Inside Queries

Sometimes you need the result of one query to drive another. A **subquery** is a complete SQL query nested inside another query. They come in two main forms.

### Scalar Subqueries

A scalar subquery returns a single value and can be used anywhere you'd use a constant:

```{.sql filename="duckdb"}
-- [STANDARD SQL] Products priced above the overall average
SELECT
    productName,
    unitPrice
FROM products
WHERE unitPrice > (
    SELECT AVG(unitPrice) FROM products
)
ORDER BY unitPrice;
```

The inner query computes the average price (a single number), and the outer query uses that number as the threshold. The database executes the inner query first, gets the result, and then uses it in the outer query.

### Correlated Subqueries

A correlated subquery references columns from the outer query, making it run once per outer row:

```{.sql filename="duckdb"}
-- [STANDARD SQL] Each product with its category's average price
SELECT
    p.productName,
    p.unitPrice,
    (
        SELECT ROUND(AVG(p2.unitPrice), 2)
        FROM products AS p2
        WHERE p2.categoryID = p.categoryID
    ) AS category_avg_price
FROM products AS p
ORDER BY p.categoryID, p.unitPrice DESC;
```

For each product in the outer query, the subquery calculates the average price of all products in that same category. This is powerful but can be slow on large datasets because the subquery runs for every row. Window functions (covered later in this chapter) often provide a more efficient way to achieve the same result.

### Subqueries in FROM

You can use a subquery as a virtual table in the `FROM` clause:

```{.sql filename="duckdb"}
-- [STANDARD SQL] Customers with more than 10 orders, showing their total spend
SELECT
    customer_orders.companyName,
    customer_orders.order_count,
    customer_orders.total_spent
FROM (
    SELECT
        c.companyName,
        COUNT(DISTINCT o.orderID) AS order_count,
        ROUND(SUM(od.unitPrice * od.quantity), 2) AS total_spent
    FROM customers AS c
    INNER JOIN orders AS o ON c.customerID = o.customerID
    INNER JOIN order_details AS od ON o.orderID = od.orderID
    GROUP BY c.companyName
) AS customer_orders
WHERE customer_orders.order_count > 10
ORDER BY customer_orders.total_spent DESC;
```

This pattern works, but nesting subqueries quickly becomes hard to read. When your logic has multiple stages, Common Table Expressions are a better approach.

## CTEs: Building Queries in Stages

A **Common Table Expression** (CTE) is a named, temporary result set defined at the beginning of a query using the `WITH` keyword. Think of it as creating a named variable that holds a table, then using that variable in your main query. CTEs make complex queries readable by breaking them into named, logical steps.

```{.sql filename="duckdb"}
-- [STANDARD SQL] Same query as above, but readable
WITH customer_orders AS (
    SELECT
        c.companyName,
        c.customerID,
        COUNT(DISTINCT o.orderID) AS order_count,
        ROUND(SUM(od.unitPrice * od.quantity), 2) AS total_spent
    FROM customers AS c
    INNER JOIN orders AS o ON c.customerID = o.customerID
    INNER JOIN order_details AS od ON o.orderID = od.orderID
    GROUP BY c.companyName, c.customerID
)

SELECT
    companyName,
    order_count,
    total_spent
FROM customer_orders
WHERE order_count > 10
ORDER BY total_spent DESC;
```

The CTE `customer_orders` computes the aggregated customer data, and the main query filters and sorts it. The logic is identical to the nested subquery version, but the structure communicates your thinking: "first, I calculate each customer's orders and spend; then, I filter to active customers."

CTEs were introduced in the SQL:1999 standard and are supported by every major database. They're one of the most universally useful features in SQL.

### Chaining Multiple CTEs

CTEs shine when you need multiple preparation steps:

```{.sql filename="duckdb"}
-- [STANDARD SQL] Which product categories are most popular with our top customers?
WITH customer_spend AS (
    -- Step 1: Total spend per customer
    SELECT
        o.customerID,
        SUM(od.unitPrice * od.quantity) AS total_spent
    FROM orders AS o
    INNER JOIN order_details AS od ON o.orderID = od.orderID
    GROUP BY o.customerID
),

top_customers AS (
    -- Step 2: Identify top 20% by spend
    SELECT customerID
    FROM customer_spend
    WHERE total_spent > (SELECT PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY total_spent) FROM customer_spend)
),

top_customer_categories AS (
    -- Step 3: What categories do top customers buy?
    SELECT
        cat.categoryName,
        COUNT(DISTINCT o.orderID) AS order_count,
        ROUND(SUM(od.unitPrice * od.quantity), 2) AS category_revenue
    FROM top_customers AS tc
    INNER JOIN orders AS o ON tc.customerID = o.customerID
    INNER JOIN order_details AS od ON o.orderID = od.orderID
    INNER JOIN products AS p ON od.productID = p.productID
    INNER JOIN categories AS cat ON p.categoryID = cat.categoryID
    GROUP BY cat.categoryName
)

-- Final: Display the results
SELECT
    categoryName,
    order_count,
    category_revenue
FROM top_customer_categories
ORDER BY category_revenue DESC;
```

Each CTE is a clearly named step in the analysis. Anyone reading this query can trace the logic: calculate spend, identify top customers, analyze their category preferences, display results. Try flattening this into nested subqueries and you'll appreciate why CTEs exist.

::: {.callout-note}
## A New Function: PERCENTILE_CONT
The `top_customers` CTE introduces `PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY total_spent)`, which computes the 80th percentile of customer spending. This is a [STANDARD SQL] ordered-set aggregate function (from SQL:2003). The `WITHIN GROUP (ORDER BY ...)` clause tells the function how to sort the values before computing the percentile. `PERCENTILE_CONT(0.5)` gives the median. The syntax looks unusual compared to regular aggregate functions, but it appears frequently in analytical work when you need to identify thresholds based on data distribution rather than fixed cutoff values.
:::

::: {.callout-tip}
## CTEs vs. Subqueries
Use **subqueries** when the nested logic is simple and fits naturally in one place (like a scalar comparison in `WHERE`). Use **CTEs** when the logic has multiple stages, when you need to reference the same intermediate result more than once, or when readability matters, which is almost always. In professional work, CTEs are strongly preferred because they make query intent visible and make debugging easier (you can run each CTE independently to check its output).
:::

::: {.callout-note title="Exercises"}
1. Write a query using a scalar subquery that finds all products priced more than twice the average product price. Return the product name, price, and how much above the average it is.

2. Rewrite the following nested subquery as a CTE. Which version is easier to read?

    ```{.sql filename="duckdb"}
    SELECT supplier_summary.companyName, supplier_summary.product_count
    FROM (
        SELECT
            s.companyName,
            COUNT(*) AS product_count
        FROM suppliers AS s
        INNER JOIN products AS p ON s.supplierID = p.supplierID
        GROUP BY s.companyName
    ) AS supplier_summary
    WHERE supplier_summary.product_count >= 5
    ORDER BY supplier_summary.product_count DESC;
    ```

3. Write a CTE-based query with two stages: (a) compute total revenue per product (`SUM(unitPrice * quantity)` from `order_details`), then (b) find the top 10 products by revenue. Show the product name and total revenue.

4. A colleague argues, "CTEs are just subqueries with extra syntax, so why bother?" Write a brief response explaining when CTEs provide real value over subqueries. Give a concrete example.
:::

## Window Functions: Analysis Without Collapse

Window functions are not an advanced topic you can skip. They are a core analytical tool that you'll use constantly in professional work. Ranking, running totals, period-over-period comparisons, and moving averages are all standard analytical requirements, and window functions are how SQL handles them. They were added to the SQL standard in 2003, and every major database supports them.

The fundamental tension they solve: `GROUP BY` gives you summaries but destroys individual row detail. Window functions give you summaries *alongside* detail, keeping every row intact while adding computed context.

### The Core Concept

Compare these two queries:

```{.sql filename="duckdb"}
-- [STANDARD SQL] GROUP BY: collapses to one row per category
SELECT
    categoryID,
    AVG(unitPrice) AS avg_price
FROM products
GROUP BY categoryID;

-- [STANDARD SQL] Window function: keeps every product, adds category average alongside
SELECT
    productName,
    categoryID,
    unitPrice,
    AVG(unitPrice) OVER (PARTITION BY categoryID) AS category_avg_price
FROM products;
```

The `GROUP BY` query returns one row per category. The window function query returns every product row, with the category's average price added as a new column. Both compute the same averages, but the window function preserves the individual product context.

The `OVER` clause is what makes a function a window function. Inside `OVER`, `PARTITION BY` defines the groups (like `GROUP BY` but without collapsing), and `ORDER BY` defines the sequence within each group.

### Ranking Functions

Window functions are the standard way to rank, number, and order rows within groups.

```{.sql filename="duckdb"}
-- [STANDARD SQL] Rank products by price within each category
SELECT
    categoryID,
    productName,
    unitPrice,
    ROW_NUMBER() OVER (PARTITION BY categoryID ORDER BY unitPrice DESC) AS price_rank,
    RANK() OVER (PARTITION BY categoryID ORDER BY unitPrice DESC) AS price_rank_with_ties
FROM products;
```

`ROW_NUMBER` assigns a unique sequential number within each partition. `RANK` does the same, but ties get the same rank (with gaps: 1, 2, 2, 4). `DENSE_RANK` is like `RANK` but without gaps (1, 2, 2, 3).

A practical application: finding the top 3 most expensive products in each category:

```{.sql filename="duckdb"}
-- [STANDARD SQL] Top 3 products per category (portable approach)
SELECT *
FROM (
    SELECT
        c.categoryName,
        p.productName,
        p.unitPrice,
        ROW_NUMBER() OVER (PARTITION BY p.categoryID ORDER BY p.unitPrice DESC) AS rn
    FROM products AS p
    INNER JOIN categories AS c ON p.categoryID = c.categoryID
) AS ranked
WHERE rn <= 3
ORDER BY categoryName, rn;
```

::: {.callout-tip}
## DuckDB's QUALIFY Clause
The subquery pattern above is necessary in most databases because you can't filter on window function results in `WHERE` (the window function hasn't been computed yet at the `WHERE` stage). DuckDB provides `QUALIFY`, a clause that filters on window function results directly:

```{.sql filename="duckdb"}
-- [DUCKDB EXTENSION] QUALIFY filters window function results
SELECT
    c.categoryName,
    p.productName,
    p.unitPrice
FROM products AS p
INNER JOIN categories AS c ON p.categoryID = c.categoryID
QUALIFY ROW_NUMBER() OVER (PARTITION BY p.categoryID ORDER BY p.unitPrice DESC) <= 3
ORDER BY c.categoryName, p.unitPrice DESC;
```

`QUALIFY` is to window functions what `HAVING` is to `GROUP BY`: a filter that runs after the computation. This is a DuckDB extension, not part of the SQL standard. The portable alternative is the subquery approach shown above.
:::

### LEAD and LAG: Looking at Adjacent Rows

`LAG` looks at the previous row, and `LEAD` looks at the next row within a partition. These are indispensable for time-series analysis.

```{.sql filename="duckdb"}
-- [STANDARD SQL] Monthly order analysis: compare each month to the previous
WITH monthly_orders AS (
    SELECT
        DATE_TRUNC('month', orderDate) AS order_month,
        COUNT(*) AS order_count,
        ROUND(SUM(freight), 2) AS total_freight
    FROM orders
    GROUP BY DATE_TRUNC('month', orderDate)
)

SELECT
    order_month,
    order_count,
    LAG(order_count) OVER (ORDER BY order_month) AS prev_month_orders,
    order_count - LAG(order_count) OVER (ORDER BY order_month) AS month_over_month_change,
    total_freight
FROM monthly_orders
ORDER BY order_month;
```

`LAG(order_count) OVER (ORDER BY order_month)` says "give me the `order_count` from the previous row, where 'previous' is defined by chronological order." The first month has `NULL` for the previous value because there is no earlier row.

### Running Totals and Moving Averages

Window functions with frame specifications compute running calculations:

```{.sql filename="duckdb"}
-- [STANDARD SQL] Running total of freight costs over time
WITH monthly_freight AS (
    SELECT
        DATE_TRUNC('month', orderDate) AS order_month,
        ROUND(SUM(freight), 2) AS monthly_freight
    FROM orders
    GROUP BY DATE_TRUNC('month', orderDate)
)

SELECT
    order_month,
    monthly_freight,
    SUM(monthly_freight) OVER (ORDER BY order_month) AS cumulative_freight,
    ROUND(
        AVG(monthly_freight) OVER (
            ORDER BY order_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS three_month_moving_avg
FROM monthly_freight
ORDER BY order_month;
```

The `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` clause defines the **window frame**: the subset of rows within the partition that the aggregate considers. For a running total, the frame implicitly stretches from the start of the partition to the current row. For the moving average, we explicitly set a 3-month window (current row plus the two preceding rows).

::: {.callout-note title="Exercises"}
1. Write a query that ranks all products by unit price (highest first) using `ROW_NUMBER`, `RANK`, and `DENSE_RANK`. Find a price where at least two products are tied and explain how the three functions differ for those rows.

2. Write a query that shows each product alongside its category's average price and the difference between the product's price and its category average. Use a window function, not a correlated subquery. Which products are priced furthest above their category average?

3. Using `LAG`, write a query that shows each order for customer `'ALFKI'` alongside the number of days since their previous order. Which gap between orders is the longest?

4. Write a query that computes a running total of order count by month (using `DATE_TRUNC` to group orders by month, then a window function for the cumulative count). At what month did Northwind surpass 400 total orders?

5. Predict what happens if you use `PARTITION BY categoryID` inside a `ROW_NUMBER` window function but forget the `ORDER BY` inside `OVER()`. Is the result deterministic? Why or why not?
:::

## Date Functions

Working with time-based data is unavoidable in analytical SQL. DuckDB provides a rich set of date and time functions.

```{.sql filename="duckdb"}
SELECT
    orderDate,
    YEAR(orderDate) AS order_year,
    MONTH(orderDate) AS order_month,
    DAYNAME(orderDate) AS day_of_week,
    DATE_TRUNC('quarter', orderDate) AS order_quarter,
    orderDate - LAG(orderDate) OVER (
        PARTITION BY customerID ORDER BY orderDate
    ) AS days_since_last_order
FROM orders
WHERE customerID = 'ALFKI'
ORDER BY orderDate;
```

`YEAR`, `MONTH`, and `DAYNAME` extract components from dates. `DATE_TRUNC` rounds dates down to a specified precision (year, quarter, month, week, day), which is essential for grouping time-series data into periods. The combination of `DATE_TRUNC` with `GROUP BY` is one of the most common patterns in analytical SQL.

::: {.callout-note}
## Date Function Portability
`YEAR()`, `MONTH()`, and `DATE_TRUNC()` are widely supported but have syntax variations across databases. PostgreSQL uses `EXTRACT(YEAR FROM date)` as the standard equivalent. SQL Server uses `DATEPART(year, date)`. The concepts are identical; only the function names change. `DAYNAME()` is DuckDB-specific, and the standard equivalent varies by database.
:::

## A Complete Analysis: ABC Inventory Classification

Let's bring everything together with a professional supply chain technique. **ABC analysis** classifies inventory items by their contribution to total value, following the Pareto principle: a small percentage of products (the "A" items) typically account for a large percentage of total inventory value.

The method ranks products by their total sales value, then classifies them into three tiers: "A" items (top 80% of cumulative value), "B" items (next 15%), and "C" items (remaining 5%).

```{.sql filename="duckdb"}
-- [STANDARD SQL] ABC Inventory Classification
WITH product_revenue AS (
    -- Step 1: Calculate total revenue per product
    SELECT
        p.productID,
        p.productName,
        c.categoryName,
        ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2) AS total_revenue
    FROM order_details AS od
    INNER JOIN products AS p ON od.productID = p.productID
    INNER JOIN categories AS c ON p.categoryID = c.categoryID
    GROUP BY p.productID, p.productName, c.categoryName
),

ranked_products AS (
    -- Step 2: Rank by revenue and compute cumulative percentage
    SELECT
        productID,
        productName,
        categoryName,
        total_revenue,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS cumulative_revenue,
        SUM(total_revenue) OVER () AS grand_total
    FROM product_revenue
)

-- Step 3: Classify into ABC tiers
SELECT
    productName,
    categoryName,
    total_revenue,
    ROUND(100.0 * cumulative_revenue / grand_total, 1) AS cumulative_pct,
    CASE
        WHEN 100.0 * cumulative_revenue / grand_total <= 80 THEN 'A'
        WHEN 100.0 * cumulative_revenue / grand_total <= 95 THEN 'B'
        ELSE 'C'
    END AS abc_class
FROM ranked_products
ORDER BY total_revenue DESC;
```

This query combines CTEs, joins across three tables, aggregate functions, window functions for running totals, and a `CASE` expression for classification. It's a genuine analytical deliverable: the output tells a supply chain manager which products deserve the most attention. The "A" items need careful forecasting and tight inventory control. The "C" items might be candidates for simplification or discontinuation.

This is the kind of analysis that SQL enables: complex business logic expressed in a readable, reproducible query that anyone can verify and re-run. No copy-pasting between spreadsheets. No manual sorting. The answer updates automatically when new data arrives.

Notice something about this query: every SQL feature it uses, CTEs, window functions, joins, CASE, aggregates, is standard SQL that works in PostgreSQL, SQL Server, Oracle, and every other major database. The techniques you've learned are portable. The analytical thinking behind them is even more so.

## Chapter Exercises

These exercises require combining GROUP BY, CTEs, window functions, and joins to answer multi-step analytical questions. Approach each as a real business request.

1. **Quarterly revenue trend.** Write a query that computes total revenue by quarter (use `DATE_TRUNC('quarter', orderDate)` on the `orders` table, joined to `order_details` for revenue). Then use `LAG` to compute the quarter-over-quarter change. Which quarter had the largest growth over the preceding quarter?

2. **Customer lifetime analysis.** Using CTEs, compute each customer's total lifetime spend, their number of orders, and their average order value. Then rank customers by total spend using `DENSE_RANK`. Show the top 10 customers with their rank, company name, total spend, order count, and average order value.

3. **Category share analysis.** For each product category, compute the total revenue and the percentage of total company revenue it represents. Use a window function with `SUM() OVER ()` (empty `OVER` clause) to calculate the grand total. Sort by revenue share descending. Which category generates the largest share?

4. **Employee performance.** Write a query that shows each employee's total order count and total revenue generated (through orders they handled). Rank employees by revenue. Then use a self-join through `reportsTo` to add each employee's manager name. Who is the top-performing employee, and who is their manager?

5. **Reorder the clauses.** The following query contains valid SQL syntax but the clauses are scrambled. Rewrite it in the correct clause order and explain what the query does:

    ```{.sql filename="duckdb"}
    HAVING COUNT(*) >= 3
    FROM products
    ORDER BY avg_price DESC
    SELECT categoryID, ROUND(AVG(unitPrice), 2) AS avg_price, COUNT(*) AS cnt
    GROUP BY categoryID
    LIMIT 5;
    ```

6. **Moving average report.** Build a monthly freight cost report using CTEs and window functions. Step 1: Aggregate total freight per month. Step 2: Compute a 3-month moving average. Step 3: Flag months where actual freight exceeds the moving average by more than 20% (use `CASE`). Present the month, actual freight, moving average, and the flag. This is a pattern commonly used in operations monitoring.

7. **Portable vs. convenient.** Rewrite the following DuckDB-specific query using only standard SQL (no `GROUP BY ALL`, no `QUALIFY`):

    ```{.sql filename="duckdb"}
    SELECT
        c.categoryName,
        p.productName,
        p.unitPrice
    FROM products AS p
    INNER JOIN categories AS c ON p.categoryID = c.categoryID
    GROUP BY ALL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY c.categoryName ORDER BY p.unitPrice DESC) = 1;
    ```

    Which version is more readable? Which would you use in a report that needs to run on PostgreSQL?

8. **Customer geography.** Write a query that counts how many customers are in each country, sorted by count descending. Only include countries with more than 5 customers using `HAVING`. Then extend it: for each of those countries, also compute the average number of orders per customer. (Hint: you'll need a subquery or CTE that first counts orders per customer, then groups by country.)

9. **Supply chain overlap.** Write a query that answers: "For each country where Northwind has both suppliers and customers, how many of each are there?" Start by finding the overlapping countries with `INTERSECT`, then use that result (as a CTE or subquery) to count suppliers and customers for those countries. Present the country, supplier count, and customer count side by side.

10. **Debug this analysis.** A colleague wrote the following query to find "the most expensive product in each category," but it returns incorrect results. Find the bug and explain why it produces wrong output.

    ```{.sql filename="duckdb"}
    SELECT
        c.categoryName,
        p.productName,
        MAX(p.unitPrice) AS max_price
    FROM products AS p
    INNER JOIN categories AS c ON p.categoryID = c.categoryID
    GROUP BY c.categoryName, p.productName
    ORDER BY max_price DESC;
    ```

    Write a corrected version using a window function, and explain why `GROUP BY` alone can't solve this problem cleanly.

11. **Window function prediction.** Before running this query, predict the values of `running_total` and `row_num` for the first 5 rows. Then run it and verify.

    ```{.sql filename="duckdb"}
    SELECT
        orderDate,
        freight,
        SUM(freight) OVER (ORDER BY orderDate) AS running_total,
        ROW_NUMBER() OVER (ORDER BY orderDate) AS row_num
    FROM orders
    WHERE customerID = 'QUICK'
    ORDER BY orderDate;
    ```

    What would change if you replaced `ROW_NUMBER()` with `RANK()`? Under what condition would `RANK()` and `ROW_NUMBER()` produce different results here?

## Summary

`GROUP BY` partitions data into categories and computes aggregate summaries within each group, with the strict requirement that all non-aggregate columns in `SELECT` must appear in the `GROUP BY` clause. `HAVING` filters groups after aggregation, operating on aggregate values rather than individual rows. Subqueries embed one query inside another for scalar comparisons or as virtual tables in `FROM`, while CTEs (Common Table Expressions) with `WITH` provide a more readable alternative by naming intermediate results as logical steps. CTEs are part of the SQL standard since SQL:1999 and are supported everywhere. Window functions are a core analytical tool, not an advanced topic, and they compute aggregates alongside individual rows using `OVER`, with `PARTITION BY` defining groups and `ORDER BY` defining sequence. Ranking functions (`ROW_NUMBER`, `RANK`, `DENSE_RANK`) number rows within partitions, `LAG` and `LEAD` access adjacent rows for period-over-period comparisons, and frame specifications (`ROWS BETWEEN`) enable running totals and moving averages. DuckDB extends standard SQL with `GROUP BY ALL` for automatic grouping and the `QUALIFY` clause for filtering window function results directly; the portable alternatives are explicit column listing and subquery wrapping, respectively. These tools combine to enable professional analytical techniques like ABC inventory classification, where CTEs, joins, aggregates, window functions, and CASE expressions work together to produce business-ready deliverables.

## Glossary

**ABC Analysis**
:   A supply chain technique that classifies inventory items into three tiers (A, B, C) based on their contribution to total value, applying the Pareto principle to focus management attention on the highest-value items.

**Common Table Expression (CTE)**
:   A named, temporary result set defined with the `WITH` keyword at the beginning of a query. CTEs make complex queries readable by breaking logic into named, sequential steps. Part of the SQL standard since SQL:1999.

**Cumulative Sum (Running Total)**
:   A window function pattern that computes the sum of a column from the beginning of the partition through the current row, using `SUM(column) OVER (ORDER BY ...)`.

**GROUP BY**
:   A SQL clause that partitions rows into groups based on one or more columns, after which aggregate functions compute summaries independently within each group.

**GROUP BY ALL**
:   A DuckDB extension that automatically infers grouping columns from the non-aggregate columns in `SELECT`. Not part of the SQL standard.

**HAVING**
:   A SQL clause that filters groups after `GROUP BY` aggregation, analogous to `WHERE` but operating on aggregate values rather than individual rows.

**LAG / LEAD**
:   Window functions that access the value of a column from a previous (`LAG`) or subsequent (`LEAD`) row within the partition, as defined by the `ORDER BY` in the `OVER` clause.

**PARTITION BY**
:   A clause within a window function's `OVER` specification that divides rows into groups for the window computation, analogous to `GROUP BY` but without collapsing rows.

**QUALIFY**
:   A DuckDB extension that filters rows based on window function results, functioning for window functions as `HAVING` does for `GROUP BY` aggregates. The portable alternative is wrapping the window function in a subquery and filtering with `WHERE`.

**Scalar Subquery**
:   A subquery that returns exactly one value (one row, one column), which can be used wherever a single value is expected, such as in a `WHERE` comparison.

**Window Frame**
:   The subset of rows within a partition over which a window function operates, specified with `ROWS BETWEEN` or `RANGE BETWEEN` in the `OVER` clause.

**Window Function**
:   A function that computes a value for each row using a "window" of related rows defined by `PARTITION BY` and `ORDER BY`, without collapsing the result set the way `GROUP BY` does. Part of the SQL standard since SQL:2003.
