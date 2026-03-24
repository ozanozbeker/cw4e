# Student Pacing Review: Computational Workflows for Engineers

**Date:** 2026-03-24
**Lens:** 300-level engineering student encountering these topics for the first time
**Focus:** Pacing, conceptual leaps, exercise placement, cognitive load

---

## Tier 1: Structural Pacing Issues

These are places where a chapter tries to cover too much ground and risks losing students. They don't necessarily require splitting chapters, but they need either more inline exercises, optional/deferred sections, or better scaffolding.

### Ch 12 (Collections & Control Flow) — Overloaded

The chapter covers four collection types (lists, tuples, dicts, sets), three control flow structures (if/elif/else, for, while), five loop utilities (range, enumerate, zip, break, continue), and comprehensions, all in ~930 lines.

The biggest pain points:

- **Dict section (roughly lines 215–355) has no inline exercises.** Students learn accessing, modifying, nesting, iterating, and dict comprehensions with no chance to practice until the exercises arrive all at once. A student confused by nested dicts (`order["items"][0]["product"]`) has no checkpoint before the chapter moves on.

- **Comprehensions arrive at the end of an already-dense chapter.** By the time students reach comprehensions, they've absorbed 4 collection types and control flow. Their cognitive budget is spent.

- **Lambda appears in the "Putting It Together" example** (in the `sorted(key=lambda ...)` call) but isn't formally introduced until Ch 13. Students see unfamiliar syntax with no explanation.

*Fixes:* Add 3–4 inline exercises in the dict section (after accessing values, after nested dicts). Consider adding a brief parenthetical when lambda first appears: "The `lambda` keyword creates a small anonymous function, which we'll cover properly in @sec-functions." Alternatively, use a named function in the Ch 12 example and save lambda for Ch 13.

### Ch 10 (Data Modeling) — Too Many Topics

The chapter covers: entities/relationships, ER diagrams, DBML syntax, Crow's foot notation, CREATE TABLE, data types (10+), constraints (5+), normalization (1NF/2NF/3NF), dimensional modeling (fact/dimension tables, star/snowflake schemas), views, data catalogs, and DML operations. That's 14–15 major topics.

- **Dimensional modeling (fact tables, star schemas) is graduate-level material** that most 300-level students won't use immediately. It's powerful but could be an optional advanced section or appendix.

- **30+ technical terms** are introduced, many in quick succession.

*Fixes:* Mark dimensional modeling as optional ("Deep Dive" callout). Consolidate ER diagram tools (conceptual + DBML + Crow's foot) into a single section rather than separate treatments. Add a data type exercise (choose appropriate types for given columns).

### Ch 04 (Git) — Undo Section Too Fast

Four undo scenarios (discard unsaved, unstage, amend commit, revert commit) are presented in quick succession with no exercises between them. Each involves a different mental model.

*Fix:* Teach discard and unstage as the core skills. Defer amend and revert to an "Advanced Git" callout or end-of-chapter section, with a note: "You'll rarely need these in your first projects."

### Module 4 (Ch 16–20) — Five New Libraries in Five Chapters

Each chapter introduces a completely new tool: DuckDB Python API, Marimo notebooks, Polars DataFrames, Altair visualization, Excel automation (3 libraries). Students must absorb a new mental model every week.

- **Ch 17 exercises assume Polars knowledge** from Ch 18 (e.g., `.filter()` on a DataFrame), creating a forward-dependency.
- **Ch 18 groups 4–5 DataFrame operations** (select, filter, sort, modify, expressions) before exercises arrive.
- **Ch 19 teaches grammar of graphics abstractly** before showing a concrete chart, which reverses the natural learning order.

*Fixes:* In Ch 17, ensure all exercises can be completed with Python dicts/lists or raw SQL results, not Polars. In Ch 18, add an exercise after each new operation rather than batching them. In Ch 19, show a complete chart first, then decompose it into grammar components.

---

## Tier 2: Missing Exercises at Critical Junctures

These are specific spots where the text introduces a hard concept and moves on without letting students practice. Adding 2–4 inline exercises at each location would significantly improve retention.

| Chapter | Section | Gap | Suggested Exercise |
|---------|---------|-----|--------------------|
| 02 | Common Data File Formats | 7 file formats in ~100 lines with no exercise | After CSV + JSON, ask students to identify which format fits a scenario (tabular data vs. config file vs. API response) |
| 04 | git diff | Shown and explained but never practiced | "You changed line 1 from 'Sales' to 'Quarterly Sales' and added 2 lines at the end. What does the diff output look like?" |
| 07 | NULL handling | 5 concepts (IS NULL, propagation, three-value logic, COALESCE, sentinels) in one section | Split into "NULL in Filters" and "NULL in Calculations" with an exercise between them |
| 08 | Multi-table joins | Jumps from 2-table to 5-table joins | Add a 3-table example (customers → orders → order_details) before the 5-table query |
| 09 | GROUP BY | The "all non-aggregated columns must be in GROUP BY" rule isn't stated before the first query | Add a "this query fails — why?" exercise showing a SELECT with an ungrouped column |
| 15 | Dunder methods + iteration | Dense section with no early practice | Add a prediction exercise after the operator table: "What dunder method does Python call for `'hello' * 3`?" |
| 18 | Polars fundamentals | 4 operations taught before exercises | Add one exercise after `.select()`, one after `.filter()` |
| 20 | Excel reading | Two libraries (fastexcel, openpyxl) introduced quickly | Add an exercise after fastexcel before introducing openpyxl |

---

## Tier 3: Conceptual Bridges That Would Help

These are places where a sentence or paragraph connecting to what students already know would ease the transition. None require restructuring, just a bridging addition.

### SQL → Python bridges (Module 3)

The book does this well in spots (None ↔ NULL, sets ↔ UNION/INTERSECT) but inconsistently. Opportunities:

- **Ch 12 dicts:** "Each dictionary is like a single row from a SQL table — keys are column names, values are the data."
- **Ch 12 conditionals:** "Python's `if`/`elif`/`else` is the procedural equivalent of SQL's `CASE WHEN`."
- **Ch 14 csv.DictReader:** "Each row comes back as a dictionary, exactly like a SQL row with column names mapped to values."
- **Ch 15 classes:** "A class is like a table schema — it defines what attributes (columns) each instance (row) will have."

### Tool motivation (Module 4)

- **Ch 16:** Before showing multiple fetch methods, explain *when* you'd want tuples vs. dicts vs. DataFrames. Currently the chapter shows how, not when.
- **Ch 19:** Before the grammar of graphics theory, show a finished chart and ask students to identify its parts. Then teach the grammar as the framework for building that chart.

### Concept grounding (Module 1)

- **Ch 03:** Before the first command, define what a command is: "a text instruction you type that tells the shell to run a specific program."
- **Ch 04:** Before the three-state model, add a concrete analogy: "The staging area is like a shopping cart — you pick up items (changes) from the store (working directory), put some in your cart (stage), and only pay for what's in the cart (commit)."

---

## Tier 4: Sections That Could Be Deferred

Content that's valuable but not essential at the point where it appears. Moving these to optional callouts or later chapters would reduce cognitive load.

| Chapter | Section | Reason to Defer |
|---------|---------|----------------|
| 02 | YAML, TOML, Parquet in "Common Data Formats" | Students encounter these later when they're actually used. Focus on CSV + JSON for now. |
| 03 | Types of Commands (4 categories) | Binary executables and builtins are enough. Aliases and scripts aren't needed yet. |
| 04 | Amend and Revert in "Undoing Mistakes" | Discard and unstage cover 90% of beginner needs. |
| 10 | Dimensional modeling (star/snowflake schemas) | Graduate-level material that most students won't use in this course. |
| 12 | `match`/`case` pattern matching | Useful but rarely needed when `if`/`elif` works. Optional callout. |
| 13 | `*args` and `**kwargs` | The chapter itself says "you'll encounter these reading library code, not writing." Optional callout. |
| 14 | httpx/API section | Valuable but not core to file I/O. Could move to Integration module. |
| 24 | ODBC history + SQLAlchemy | Historical context that dilutes Arrow's core message. Condense to 2–3 sentences. |

---

## What's Working Well

The reviews consistently praised several patterns that should NOT change:

- **The "Whole Game" approach** — students build real things from Day 1
- **Northwind consistency** — the same dataset across all modules creates familiarity
- **Prose over bullets** — the writing style is engaging and professional
- **Inline exercises with collapsed solutions** — the format works, students just need more of them
- **SQL analogies in Module 3** — where they appear, they're excellent
- **The Production module capstone** — Ch 25's final project ties everything together in a portfolio-ready way
- **Ch 11 truthiness section** — exemplary teaching of a hard concept
- **Ch 23 "Triple Reveal"** — brilliant before/after pedagogy
- **Ch 15 exploration workflow** (type → dir → help) — the most transferable skill in the book

---

## Summary: The Core Pattern

The book's pacing issues follow a consistent pattern: **sections that introduce 4+ concepts before giving students a chance to practice.** The fix is almost always the same: add an inline exercise after every 2–3 new concepts. The chapter structure and sequencing are sound. The writing is clear. Students just need more frequent checkpoints to confirm they're following along before the next concept arrives.

The inline exercises added to Ch 11–20 were a strong step. The next improvement is filling the remaining gaps identified in Tier 2, especially in Ch 02, 07, 08, 09, 12, 15, and 18.
