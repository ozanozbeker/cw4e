# Joining Tables

So far, every query you've written has drawn from a single table. That's fine for questions like "what products are low on stock?" But most real business questions can't be answered from one table alone. "Which suppliers deliver the products we're running low on?" requires information from both the `products` table and the `suppliers` table. "What are our best-selling product categories?" needs `order_details`, `products`, *and* `categories`. The data you need is spread across multiple tables, and joining them is how you bring it together.

This chapter explains *why* data is split across tables in the first place, introduces the concept of keys that link tables together, and teaches you the SQL `JOIN` syntax to combine tables in your queries. By the end, you'll be writing multi-table queries that traverse the Northwind supply chain from supplier to customer.

## Why Data Lives in Multiple Tables

It might seem simpler to put everything in one giant table: every order, with the customer's full address, the product name and description, the supplier's phone number, the shipper's details, all in a single row. Some spreadsheet-based workflows do exactly this. But this approach creates serious problems as data grows.

Imagine an order that includes three products. In a single-table design, you'd repeat the customer's name, address, and phone number three times, once per line item. If that customer places 200 orders over the year, their information is duplicated hundreds of times. Now multiply that by thousands of customers and you've wasted enormous storage on redundant data. Worse, if the customer moves and you need to update their address, you have to find and update *every row* that mentions them. Miss one, and now your database disagrees with itself about where that customer lives.

Relational databases solve this by splitting data into separate tables organized around distinct entities. Customers live in the `customers` table, one row per customer. Orders live in the `orders` table, one row per order. Products, suppliers, shippers, each gets its own table. Instead of duplicating customer information in every order row, the `orders` table stores only a `customerID` that *references* the full customer record in the `customers` table. This reference system eliminates redundancy: the customer's address exists in exactly one place, and updating it there updates it everywhere.

The trade-off is that answering multi-entity questions requires combining tables, which is precisely what joins do.

## Keys: The Links Between Tables

Two concepts make the reference system work.

A **primary key** is a column (or combination of columns) that uniquely identifies each row in a table. In the `products` table, `productID` is the primary key: every product has a different ID, and that ID never changes. Primary keys guarantee that you can always point to exactly one row without ambiguity.

A **foreign key** is a column in one table that references the primary key of another table. In the `products` table, `supplierID` is a foreign key that references `supplierID` in the `suppliers` table. It says "this product is supplied by the company in row X of the suppliers table." Foreign keys are the links that connect your tables into a web of relationships.

Here's a concrete example. The `products` table might contain:

| productID | productName | supplierID | categoryID | unitPrice |
|---|---|---|---|---|
| 1 | Chai | 1 | 1 | 18.00 |
| 2 | Chang | 1 | 1 | 19.00 |
| 3 | Aniseed Syrup | 1 | 2 | 10.00 |

And the `suppliers` table:

| supplierID | companyName | country |
|---|---|---|
| 1 | Exotic Liquids | UK |
| 2 | New Orleans Cajun | USA |

The `supplierID` column in `products` connects to the `supplierID` column in `suppliers`. Products 1, 2, and 3 all have `supplierID = 1`, meaning they're all supplied by "Exotic Liquids" in the UK. Notice how the supplier's name and country appear once in the `suppliers` table rather than being repeated in every product row.

### Relationship Types

The connections between tables follow a few common patterns that are worth naming, because recognizing them helps you predict how joins will behave.

A **one-to-many** relationship is the most common. One supplier has many products. One customer has many orders. One order has many line items. The "one" side has the primary key, and the "many" side has the foreign key. When you join these tables, each row on the "one" side can match multiple rows on the "many" side.

A **one-to-one** relationship means each row in one table matches exactly one row in another. These are less common, but you see them when a table is split for organizational reasons (like separating sensitive employee data from general employee information).

A **many-to-many** relationship means entities on both sides can relate to multiple entities on the other. Consider students and courses: each student takes many courses, and each course has many students. You can't represent this with a single foreign key on either side. Instead, you need a **junction table** (also called a bridge table or associative table) that sits between them. The Northwind `order_details` table is exactly this: it connects `orders` to `products`, because one order can contain many products, and one product can appear in many orders. Each row in `order_details` represents one specific product within one specific order, with foreign keys to both tables.

```
orders ──┐
         ├── order_details ──┐
products ┘                   │
                             └── Each row: one product in one order
```

Understanding these patterns helps you predict how many rows a join will produce, which, as you'll see later in this chapter, is one of the most important things to get right.

::: {.callout-note title="Exercises"}
1. Look at the Northwind tables: `categories`, `products`, `suppliers`, `orders`, `order_details`, `customers`. For each pair listed below, identify which is the "one" side and which is the "many" side, and name the foreign key column that connects them. (a) `categories` and `products`. (b) `customers` and `orders`. (c) `orders` and `order_details`.

2. Why can't the relationship between `orders` and `products` be represented with a single foreign key on either table? What would go wrong if you added a `productID` column to the `orders` table?

3. Imagine Northwind adds an `employee_territories` table where each row links an employee to a territory they cover. An employee can cover many territories, and a territory can be covered by many employees. What kind of relationship is this, and what would the junction table's columns look like?
:::

## INNER JOIN: Matching Rows

The `INNER JOIN` is the most common join type and the one you'll use most often. It combines rows from two tables where the join condition is met. Rows that don't have a match in both tables are excluded from the result.

Let's answer the question: "What are the names and suppliers of our products?"

```{.sql filename="duckdb"}
SELECT
    p.productName,
    p.unitPrice,
    s.companyName AS supplier,
    s.country AS supplier_country
FROM products AS p
INNER JOIN suppliers AS s
    ON p.supplierID = s.supplierID;
```

Several things are happening here that deserve attention.

The `FROM products AS p` establishes `products` as the first table and gives it the alias `p`. The `INNER JOIN suppliers AS s` brings in the second table with alias `s`. Table aliases keep your queries readable when working with multiple tables, because writing `p.productName` is much cleaner than `products.productName`, especially as queries grow.

The `ON p.supplierID = s.supplierID` is the **join condition**: it tells the database which rows to match. For each product, the database finds the supplier row where the supplier IDs match and combines them into a single result row.

The `SELECT` clause uses the table aliases to specify which table each column comes from. This is necessary when two tables have columns with the same name (both tables have `supplierID`), but it's good practice even when names are unique, because it documents where each piece of data originates.

### How INNER JOIN Works

Think of an `INNER JOIN` as a handshake between two tables. Every row in the left table extends its hand (the join column value), and every row in the right table extends its hand. Only when two hands match (the values are equal) do those rows combine into a result row.

If a product has `supplierID = 99` but no supplier with that ID exists, that product is *excluded* from the results. Similarly, if a supplier exists but no products reference it, that supplier doesn't appear. An `INNER JOIN` only returns the intersection: rows that match on both sides.

```
Products Table          Suppliers Table
supplierID: 1  ───────► supplierID: 1  ✓ Match! Combined in result
supplierID: 1  ───────► supplierID: 1  ✓ Match! Combined in result
supplierID: 2  ───────► supplierID: 2  ✓ Match! Combined in result
supplierID: 99 ───────► (no match)     ✗ Product excluded
                        supplierID: 5  ✗ Supplier excluded (no products)
```

::: {.callout-note title="Exercises"}
1. Write a query that joins `products` to `categories` and returns the product name, unit price, and category name. Sort by category name, then by price descending within each category.

2. The `products` table has 77 rows. If you `INNER JOIN` products to suppliers, would you expect the result to have exactly 77 rows, fewer than 77, or more than 77? Explain your reasoning, then run the query and check. (Hint: think about whether every product has a valid supplier and whether any supplier maps to multiple products.)

3. Write a query that answers: "Which products does each supplier provide, and how much are they worth in total inventory?" Join `products` to `suppliers`, compute `unitPrice * unitsInStock` as `inventory_value`, and sort by supplier name.
:::

## LEFT JOIN: Keeping Everything from One Side

Sometimes you want to keep all rows from one table even if there's no match in the other. The `LEFT JOIN` (also written `LEFT OUTER JOIN`) returns all rows from the left table and matching rows from the right table. Where there's no match, the right table's columns are filled with `NULL`.

This is essential for questions like "show me all customers and their orders, including customers who haven't placed any orders yet":

```{.sql filename="duckdb"}
SELECT
    c.companyName,
    c.country,
    o.orderID,
    o.orderDate
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customerID = o.customerID
ORDER BY o.orderDate;
```

Customers with orders appear with their order information populated. Customers without orders still appear in the results, but `orderID` and `orderDate` are `NULL` for those rows.

This distinction between `INNER JOIN` and `LEFT JOIN` matters more than it might initially seem. Using `INNER JOIN` when you should have used `LEFT JOIN` silently drops rows from your results. If you're counting total customers and some have no orders, an `INNER JOIN` through the `orders` table will give you the wrong count. Building the habit of asking "do I want to keep unmatched rows?" before choosing your join type will prevent subtle data loss bugs.

### Finding Unmatched Rows

A practical pattern combines `LEFT JOIN` with a `NULL` check to find rows that *don't* have a match:

```{.sql filename="duckdb"}
-- Customers who have never placed an order
SELECT
    c.companyName,
    c.country
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customerID = o.customerID
WHERE o.orderID IS NULL;
```

This works because unmatched rows have `NULL` in all columns from the right table. Filtering for `NULL` in the right table's primary key gives you exactly the "orphaned" rows from the left table.

## Other Join Types

While `INNER JOIN` and `LEFT JOIN` cover the vast majority of analytical work, three other join types exist and are worth understanding.

**RIGHT JOIN** is the mirror of `LEFT JOIN`: it keeps all rows from the right table and matches from the left. In practice, you can always rewrite a `RIGHT JOIN` as a `LEFT JOIN` by swapping the table order, and most analysts prefer `LEFT JOIN` for consistency.

**FULL OUTER JOIN** keeps all rows from both tables, filling `NULL` where there's no match on either side. This is useful for reconciliation queries ("show me everything from both systems, highlighting what's only in one"), but it's rare in everyday analytical work.

**CROSS JOIN** produces every possible combination of rows from both tables. If one table has 10 rows and the other has 100, the result has 1,000 rows. This is occasionally useful (generating all possible product-store combinations, for example) but dangerous if done accidentally on large tables.

```{.sql filename="duckdb"}
-- CROSS JOIN example: every category paired with every shipper
-- Useful for building a "coverage matrix"
SELECT
    c.categoryName,
    s.companyName AS shipper
FROM categories AS c
CROSS JOIN shippers AS s;
```

::: {.callout-warning}
## Joins Are Not Set Operations
You'll see joins explained with Venn diagrams everywhere online. While they provide a quick visual, they're technically misleading, because joins are row-matching operations that create new combined rows, not set intersections. A single customer row can match many order rows, producing many combined rows, something a Venn diagram can't represent. A cross join between 4 rows and 4 rows produces 16 rows, which is clearly not a set overlap.

If you want to think in terms of Venn diagrams, save that mental model for actual set operations (`UNION`, `INTERSECT`, `EXCEPT`) from the previous chapter, where both sides represent complete rows of the same structure and the operations truly combine, intersect, or subtract those rows. For joins, think "row matching" instead.
:::

::: {.callout-note title="Exercises"}
1. Write a query that finds all customers who have never placed an order. Return the company name and country. How many are there?

2. This query is supposed to count how many orders each customer has placed, including customers with zero orders. Find the bug:

    ```{.sql filename="duckdb"}
    SELECT
        c.companyName,
        COUNT(*) AS order_count
    FROM customers AS c
    LEFT JOIN orders AS o
        ON c.customerID = o.customerID
    GROUP BY c.companyName
    ORDER BY order_count;
    ```

    (Hint: what does `COUNT(*)` count for customers with no orders? What should you count instead?)

3. What would a `CROSS JOIN` between `categories` (8 rows) and `shippers` (3 rows) produce? How many result rows? When would this "every combination" behavior be useful in a business context?

4. Explain in your own words why `INNER JOIN` and `LEFT JOIN` are not set operations, even though online tutorials often draw them as Venn diagrams. Use the one-to-many relationship between customers and orders as your example.
:::

## Multi-Table Queries

Real analytical questions often require more than two tables. The Northwind data model connects suppliers to products, products to order details, order details to orders, and orders to customers. Traversing this chain lets you answer questions that span the entire supply chain.

"What products did each customer order, and who supplies them?"

```{.sql filename="duckdb"}
SELECT
    c.companyName AS customer,
    p.productName AS product,
    s.companyName AS supplier,
    od.quantity,
    od.unitPrice * od.quantity AS line_total
FROM customers AS c
INNER JOIN orders AS o
    ON c.customerID = o.customerID
INNER JOIN order_details AS od
    ON o.orderID = od.orderID
INNER JOIN products AS p
    ON od.productID = p.productID
INNER JOIN suppliers AS s
    ON p.supplierID = s.supplierID
ORDER BY c.companyName, p.productName;
```

This query chains four joins to connect five tables. Read it from the `FROM` clause down: start with customers, join to their orders, join to the line items in those orders, join to the product details, join to the supplier. Each join adds one more piece of context to the result.

Notice that `order_details` is the junction table connecting orders to products. Without it, there would be no way to know which products are in which orders. The join path `orders → order_details → products` traverses a many-to-many relationship by going through the junction table one step at a time.

When writing multi-table queries, building incrementally is the key. Don't write all four joins at once. Start with two tables and verify the results make sense, then add the third, then the fourth. This approach catches mistakes early and builds your confidence in the data.

::: {.callout-tip}
## Building Queries Incrementally
Write multi-table queries like this:

1. Start with `FROM table1` and check the row count.
2. Add one join: `INNER JOIN table2 ON ...`. Check the row count. Did it increase? Decrease? Is that expected?
3. Add the next join. Check again.
4. Only add `WHERE`, `ORDER BY`, and the final `SELECT` columns after you've verified the joins produce the right foundation.

If your row count unexpectedly explodes, you likely have a many-to-many join (one row matching multiple rows on the other side). If it drops, you might need a `LEFT JOIN` instead of `INNER JOIN`.
:::

## Row Multiplication: A Common Trap

Understanding how joins affect row counts is one of the most important, and most overlooked, aspects of SQL.

An `INNER JOIN` between two tables with a one-to-many relationship (one customer, many orders) produces one result row for each match. If customer "ABC" has 15 orders, that customer appears in 15 result rows. This is correct and expected: each row represents a different order placed by the same customer.

But if you then aggregate without accounting for this multiplication, you get wrong answers. Consider this tempting but incorrect query:

```{.sql filename="duckdb"}
-- WRONG: customer info is repeated per order, inflating the count
SELECT
    c.companyName,
    c.country,
    COUNT(*) AS order_count
FROM customers AS c
INNER JOIN orders AS o
    ON c.customerID = o.customerID
INNER JOIN order_details AS od
    ON o.orderID = od.orderID
GROUP BY c.companyName, c.country;
```

This counts *order detail lines*, not orders, because each order can have many line items. If you wanted to count orders, you'd need `COUNT(DISTINCT o.orderID)` instead of `COUNT(*)`.

The lesson: whenever you join tables, think about the *grain* of your result set. Each join can change the level of detail each row represents. A join from orders to order details changes your grain from one-row-per-order to one-row-per-line-item.

## Self-Joins

A table can be joined to itself. This sounds odd, but it's useful when rows within the same table have relationships to each other. The `employees` table in Northwind includes a `reportsTo` column that references another employee's ID, representing the management hierarchy.

```{.sql filename="duckdb"}
-- Who reports to whom?
SELECT
    e.firstName || ' ' || e.lastName AS employee,
    e.title AS employee_title,
    m.firstName || ' ' || m.lastName AS manager,
    m.title AS manager_title
FROM employees AS e
LEFT JOIN employees AS m
    ON e.reportsTo = m.employeeID;
```

The trick is giving the same table two different aliases (`e` for employees, `m` for managers) so the database can distinguish between the two roles. The `LEFT JOIN` ensures the top-level manager (who reports to nobody) still appears, with `NULL` in the manager columns.

The `||` operator concatenates strings in SQL. It's how you combine text values, like building a full name from first and last name columns.

::: {.callout-note title="Exercises"}
1. Using the self-join on `employees`, find the top-level manager (the person whose `reportsTo` is `NULL`). Then write a query that counts how many direct reports each manager has.

2. Why does the self-join example use `LEFT JOIN` instead of `INNER JOIN`? What would change in the results if you switched to `INNER JOIN`?
:::

## Chapter Exercises

These exercises require you to combine join concepts to answer business questions that span the Northwind data model. Build each query incrementally, verifying row counts at each step.

1. **Supplier performance.** Write a query that shows each supplier's company name, country, the number of distinct products they supply, and the average unit price of those products. Sort by product count descending. Which supplier offers the most products?

2. **The full supply chain.** Write a query that traces the complete path from supplier to customer for orders placed in July 1997. Include the supplier name, product name, customer name, order date, quantity, and line total (`unitPrice * quantity` from `order_details`). This requires joining five tables. Build it one join at a time.

3. **Row count prediction.** Before running each query, predict how many rows the result will have, then verify. (a) `INNER JOIN` between `customers` (91 rows) and `orders` (830 rows). (b) `LEFT JOIN` between `customers` (91 rows) and `orders` (830 rows). (c) `CROSS JOIN` between `categories` (8 rows) and `suppliers` (29 rows). Explain any differences between (a) and (b).

4. **Finding orphans.** Write a query that identifies any products whose `supplierID` doesn't match any row in the `suppliers` table. Then write a second query that finds any suppliers who don't have any products listed. What do these "orphan" checks tell you about data quality?

5. **Grain awareness.** A colleague writes this query to compute total revenue per customer:

    ```{.sql filename="duckdb"}
    SELECT
        c.companyName,
        SUM(od.unitPrice * od.quantity) AS total_revenue
    FROM customers AS c
    INNER JOIN orders AS o ON c.customerID = o.customerID
    INNER JOIN order_details AS od ON o.orderID = od.orderID
    GROUP BY c.companyName
    ORDER BY total_revenue DESC;
    ```

    Is this query correct? Explain why or why not by tracing the grain at each join step. Then modify it to also show the number of distinct orders each customer placed (not the number of line items).

6. **Category revenue report.** Write a query that answers: "What is the total revenue for each product category?" You'll need to join `categories`, `products`, and `order_details`. Then extend it to show the percentage of total company revenue that each category represents. (Hint: you can compute the overall total using a subquery or a window function if you've read ahead.)

7. **Debug this join.** A colleague wrote this query to find "customers who have never placed an order," but it returns zero rows even though some customers have no orders. Find the bug and fix it.

    ```{.sql filename="duckdb"}
    SELECT c.companyName
    FROM customers AS c
    LEFT JOIN orders AS o ON c.customerID = o.customerID
    WHERE o.orderID != NULL;
    ```

    After fixing it, explain *two* different things that were wrong with the original query.

8. **Join type prediction.** Without running them, predict the row count for each query below. Then run them and explain any discrepancies between your prediction and the actual result.

    ```{.sql filename="duckdb"}
    -- Query A
    SELECT COUNT(*)
    FROM orders AS o
    INNER JOIN employees AS e ON o.employeeID = e.employeeID;

    -- Query B
    SELECT COUNT(*)
    FROM employees AS e
    LEFT JOIN orders AS o ON e.employeeID = o.employeeID;

    -- Query C
    SELECT COUNT(*)
    FROM employees AS e
    LEFT JOIN orders AS o ON e.employeeID = o.employeeID
    WHERE o.orderID IS NULL;
    ```

    Explain what business question Query C answers and why it's a useful pattern.

9. **Reconciliation with FULL OUTER JOIN.** You receive two CSV files: one listing product IDs that were shipped last month and one listing product IDs that were ordered last month. Write a query using `FULL OUTER JOIN` that categorizes each product as "Shipped Only" (shipped but not ordered, possibly a delayed shipment), "Ordered Only" (ordered but not shipped, possibly a fulfillment gap), or "Both" (ordered and shipped). Use the `orders`, `order_details`, and `shippers` tables to simulate this scenario for a date range you choose, joining on `productID`. Explain why `INNER JOIN` wouldn't work for this analysis.

## Summary

Data is split across tables to eliminate redundancy and ensure consistency: each entity (customers, products, suppliers) lives in exactly one table, connected to related entities through key references. Primary keys uniquely identify rows within a table, and foreign keys reference primary keys in other tables, creating the links that joins traverse. Relationships between tables follow patterns: one-to-many (one supplier, many products), one-to-one, and many-to-many (orders to products, connected through the `order_details` junction table). `INNER JOIN` combines rows where the join condition matches, excluding unmatched rows from both sides. `LEFT JOIN` keeps all rows from the left table and fills `NULL` for unmatched right-side columns, which is critical for preserving complete counts and detecting missing relationships. Multi-table queries chain joins to traverse relationships across the data model, and building these queries incrementally, one join at a time with row-count verification, prevents subtle errors. Joins are row-matching operations, not set operations, and Venn diagrams are misleading for understanding them. Row multiplication occurs naturally when joining one-to-many relationships, and understanding the resulting grain of your data is essential for correct aggregations.

## Glossary

**CROSS JOIN**
:   A join that produces the Cartesian product of two tables, combining every row from the left table with every row from the right table. No join condition is used.

**Foreign Key**
:   A column in one table that references the primary key of another table, establishing a link between the two entities and enabling joins.

**FULL OUTER JOIN**
:   A join that returns all rows from both tables, filling `NULL` where there is no match on either side. Used for reconciliation and completeness checks.

**Grain**
:   The level of detail that each row in a query result represents. A table at "order grain" has one row per order; joining to order details changes the grain to one row per line item.

**INNER JOIN**
:   A join that returns only the rows where the join condition is satisfied in both tables. Unmatched rows from either side are excluded.

**Join Condition**
:   The expression in the `ON` clause that specifies how rows from two tables should be matched, typically an equality comparison between a foreign key and a primary key.

**Junction Table**
:   A table that connects two other tables in a many-to-many relationship by holding foreign keys to both. Also called a bridge table or associative table. The `order_details` table is a junction table connecting orders and products.

**LEFT JOIN**
:   A join that returns all rows from the left table and matching rows from the right table. Where no match exists, right-side columns are filled with `NULL`.

**Many-to-Many Relationship**
:   A relationship where entities on both sides can relate to multiple entities on the other side. Requires a junction table to implement in a relational database.

**One-to-Many Relationship**
:   A relationship where one entity on one side corresponds to multiple entities on the other side. The "many" side holds the foreign key referencing the "one" side's primary key.

**Primary Key**
:   A column (or combination of columns) that uniquely identifies each row in a table. No two rows can have the same primary key value, and the value cannot be `NULL`.

**Self-Join**
:   A join where a table is joined to itself, using two different aliases. Useful for hierarchical data or comparing rows within the same table.

**Table Alias**
:   A short name assigned to a table in a query using the `AS` keyword, making multi-table queries more readable by replacing long table names with brief identifiers.
