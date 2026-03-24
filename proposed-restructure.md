# Proposed Book Restructure: Computational Workflows for Engineers

## Guiding Principles

1. **Quarto first** — Students start with something familiar (writing) and learn tools (IDE, CLI, Git) in that context
2. **3 tests + final project** — Aligned to testable skill domains, not arbitrary module boundaries
3. **Split old Ch 12** — Collections and Control Flow become separate chapters
4. **Spiral curriculum for Quarto** — Introduced as a writing tool in Unit 1, revisited with code cells in the capstone
5. **Python stays pure** — Unit 3 teaches the language only, culminating with the object model. SQL integration and libraries belong in the capstone.
6. **Tools you can't test become project tools** — Marimo, Altair, Excel, uv, code quality, Python-SQL, and Polars are assessed through the final project, not exams
7. **Arrow and Typer stay as chapters** at the end of the book, rounding out the full picture

---

## Revised Table of Contents

### Unit 1: The Professional Toolkit

Students learn professional tools through a familiar activity: writing a report. No programming yet.

| Ch | Title | Key Concepts | What Students Build |
|----|-------|-------------|-------------------|
| 01 | How Computers Work | Hardware model (CPU, RAM, disk), processes, save model | Mental model for everything that follows |
| 02 | Files & Filesystems | File types (text vs. binary), paths, project organization | Organized project folder |
| 03 | Writing with Quarto | Markdown, YAML front matter, `quarto render`, callouts, cross-references | A rendered professional document |
| 04 | The Command Line | Navigation, file management, command structure, tab completion | CLI fluency from Quarto workflow |
| 05 | Version Control with Git | Three-state model, staging, committing, branching, .gitignore | Version-controlled Quarto document |
| 06 | Collaboration with GitHub | Remotes, push/pull, pull requests, code review, issues | Shared project on GitHub |

**Test 1:** CLI navigation, Git workflows, reading diffs, filesystem concepts

**Notes on changes:**
- Old Ch 01 + 02 merged into cleaner split: "How Computers Work" keeps hardware/memory/save model; "Files & Filesystems" keeps paths/formats/organization.
- Quarto is new to this position. The chapter covers ONLY markdown authoring and document rendering — no Python code cells, no computation. YAML front matter teaches configuration syntax naturally. `quarto render` and `quarto preview` give students real CLI commands with visible results.
- Git examples use the Quarto document, not code. "I want to revert to yesterday's draft" is more relatable than "I want to undo my code changes." Branching is "I want to try a different structure for section 3 without losing what I have."
- File formats section in Ch 02 is trimmed to CSV, JSON, and Markdown (formats they'll actually use soon). YAML is introduced in Ch 03 through Quarto front matter. TOML appears in Ch 22 through `pyproject.toml`. Parquet appears in Ch 21 through Polars. Each format arrives when students need it.

---

### Unit 2: Data with SQL

Students learn to ask questions of data using SQL. The Northwind dataset becomes their constant companion.

| Ch | Title | Key Concepts | What Students Build |
|----|-------|-------------|-------------------|
| 07 | Databases & DuckDB | What is a database, relational model, DuckDB setup, first queries | Working database connection |
| 08 | Querying Data | SELECT, WHERE, ORDER BY, LIMIT, NULL handling, aggregates | Business questions answered with SQL |
| 09 | Joining Tables | INNER/LEFT/RIGHT/FULL/CROSS JOIN, grain, multi-table queries | Complex cross-table analysis |
| 10 | Analytical SQL | GROUP BY, HAVING, subqueries, CTEs, window functions | Analytical reports in SQL |
| 11 | Data Modeling | ER diagrams, CREATE TABLE, data types, constraints, normalization | Northwind schema understanding |

**Test 2:** Write queries, predict results, debug broken SQL, basic schema design

**Notes on changes:**
- Chapter numbering shifted by 1 due to Quarto insertion.
- Ch 11 (old Ch 10) has dimensional modeling moved to an optional "Deep Dive" callout. Core content: ER diagrams, DDL, normalization. That's enough for one lecture.

---

### Unit 3: Python

Students learn Python as a language. No libraries, no databases, just the language itself. The unit builds from values to objects, culminating with the object model that explains *why Python works the way it does.*

| Ch | Title | Key Concepts | What Students Build |
|----|-------|-------------|-------------------|
| 12 | Python Fundamentals | Types, variables, operators, strings, f-strings, booleans, None | First Python scripts |
| 13 | Collections | Lists, tuples, dictionaries, sets | Data structures for real problems |
| 14 | Control Flow | if/elif/else, for/while loops, enumerate, zip, comprehensions | Logic and iteration |
| 15 | Functions | Defining, parameters, scope, generators, modules, imports | Reusable, organized code |
| 16 | File I/O | pathlib, context managers, CSV, JSON, error handling | Reading/writing real data files |
| 17 | The Python Object Model | Everything is an object, dunders, classes, type hints | Understanding Python's design |

**Test 3:** Write Python functions, work with collections, process files, predict object behavior, add type hints

**Notes on changes:**
- Old Ch 12 (Collections & Control Flow) is now two chapters: Ch 13 (Collections) and Ch 14 (Control Flow). This is the highest-impact structural change. Each chapter has room for inline exercises and students can absorb collections before tackling loops and comprehensions.
- Lambda is introduced in Ch 15 (Functions) where it belongs, not used in Ch 13/14 before it's taught.
- The Python Object Model (old Ch 15) is the capstone. After 5 chapters of *using* Python, students learn *how Python works under the hood*. This is the right ending: you've been calling methods, using operators, iterating over collections — now you understand the machinery. Type hints bridge naturally into code quality in the capstone.
- Python-SQL and Polars moved out of this unit. The Python test assesses pure language skills. Integration is assessed through the project.

---

### Building Data Products (No Test — Final Project)

Students combine everything they've learned into a professional data product. Python-SQL and Polars are taught here with dedicated lectures because they're foundational to the project; the remaining chapters are introduced through demos and workshops.

| Ch | Title | Key Concepts | Role in Project |
|----|-------|-------------|----------------|
| 18 | Python Meets SQL | DuckDB Python API, fetch methods, parameterized queries, querying files | Connecting Python to their SQL knowledge |
| 19 | DataFrames with Polars | DataFrame concepts, expressions, filtering, grouping, Polars + DuckDB | Data transformation engine |
| 20 | Visualization with Altair | Grammar of graphics, common chart types, layering, interactivity | Charts and dashboards |
| 21 | Working with Excel | Reading (fastexcel, openpyxl), writing (XlsxWriter), formatting | Deliverable for stakeholders |
| 22 | Python Projects with uv | pyproject.toml, dependencies, virtual environments, project structure | Project scaffolding |
| 23 | Code Quality | Ruff, basedpyright, language servers, configuration | Professional code standards |
| 24 | Computational Documents | Quarto with code cells, Marimo notebooks, interactive reports | Final deliverable format |
| 25 | Apache Arrow & the Columnar Revolution | Zero-copy, IPC, why DuckDB + Polars are fast, the Arrow ecosystem | Understanding the "why" behind the stack |
| 26 | Building CLI Tools with Typer | Arguments, options, commands, building a Northwind CLI | Packaging scripts as professional tools |

**Final Project:** Build a complete Northwind data product: SQL queries, Python transformation, Polars analysis, Altair visualization, delivered as a Quarto report or Excel workbook, managed with uv, passing Ruff + basedpyright checks.

**Notes on changes:**
- Python-SQL (Ch 18) and Polars (Ch 19) get full lectures. They're the bridge between "I know Python" and "I can build things with data." Students need to absorb these before the project.
- Ch 24 is a "Quarto Part 2" that brings back Quarto (from Ch 03) but now with executable Python code cells and Marimo notebooks. Students already know Quarto markdown from Unit 1 — now they add computation. This is the spiral curriculum payoff.
- Arrow (Ch 25) and Typer (Ch 26) close the book as full chapters. Arrow gives students the conceptual understanding of *why* the tools they've been using are fast. Typer shows how to package everything into a professional CLI tool. Neither is tested, but both round out the picture. They also serve as reference material students will revisit after the course.
- Chapters 20–24 don't each need a full lecture. The capstone phase mixes brief tool demos with guided project work time.

---

## Semester Schedule (15 Weeks, 2 Lectures/Week)

| Week | Lecture 1 | Lecture 2 |
|------|-----------|-----------|
| 1 | Ch 01: How Computers Work | Ch 02: Files & Filesystems |
| 2 | Ch 03: Writing with Quarto | Ch 04: The Command Line |
| 3 | Ch 05: Git | Ch 06: GitHub |
| 4 | Unit 1 Review | **Test 1** |
| 5 | Ch 07: Databases & DuckDB | Ch 08: Querying Data |
| 6 | Ch 09: Joining Tables | Ch 10: Analytical SQL |
| 7 | Ch 11: Data Modeling | Unit 2 Review |
| 8 | **Test 2** | Ch 12: Python Fundamentals |
| 9 | Ch 13: Collections | Ch 14: Control Flow |
| 10 | Ch 15: Functions | Ch 16: File I/O |
| 11 | Ch 17: The Python Object Model | Unit 3 Review |
| 12 | **Test 3** | Ch 18: Python Meets SQL |
| 13 | Ch 19: Polars | Ch 20–21: Altair + Excel (demo) |
| 14 | Ch 22–23: uv + Code Quality (setup) | Ch 24: Computational Documents |
| 15 | Ch 25–26: Arrow + Typer | Project presentations / Final project due |

**30 lecture slots:** 17 chapter lectures + 4 combo lectures + 3 tests + 3 review days + 3 capstone/project days

---

## What Changes in the Actual Files

| Action | Details |
|--------|---------|
| **Keep separate** | Ch 01 + 02 stay as two chapters but with cleaner scope boundaries |
| **Move + rewrite** | Current Ch 22 (Quarto) → new Ch 03 position, rewritten to remove all Python code cells |
| **Split** | Current Ch 12 → new Ch 13 (Collections) + new Ch 14 (Control Flow & Comprehensions) |
| **Move** | Current Ch 16 (Python-SQL) → new Ch 18, first chapter of capstone |
| **Move** | Current Ch 17 (Marimo) → combined into new Ch 24 with advanced Quarto |
| **Move** | Current Ch 18 (Polars) → new Ch 19, second chapter of capstone |
| **Trim** | Current Ch 10 dimensional modeling → optional "Deep Dive" callout |
| **Keep** | Arrow and Typer stay as full chapters (Ch 25–26) at end of book |
| **New** | Ch 24 "Computational Documents" combines Quarto code cells + Marimo |
| **Renumber** | All chapters renumbered to reflect new order |

---

## Old → New Chapter Mapping

| Old # | Old Title | New # | New Title | Change |
|-------|-----------|-------|-----------|--------|
| 01 | Computers | 01 | How Computers Work | Scope refined |
| 02 | Filesystem | 02 | Files & Filesystems | Scope refined, formats trimmed |
| 03 | CLI | 04 | The Command Line | Moved after Quarto |
| 04 | Git | 05 | Version Control with Git | Renumbered |
| 05 | GitHub | 06 | Collaboration with GitHub | Renumbered |
| 06 | Databases | 07 | Databases & DuckDB | Renumbered |
| 07 | Querying | 08 | Querying Data | Renumbered |
| 08 | Joins | 09 | Joining Tables | Renumbered |
| 09 | Analytics | 10 | Analytical SQL | Renumbered |
| 10 | Modeling | 11 | Data Modeling | Trimmed (dimensional → optional) |
| 11 | Python Fundamentals | 12 | Python Fundamentals | Renumbered |
| 12 | Collections | 13 + 14 | Collections / Control Flow | **Split into two chapters** |
| 13 | Functions | 15 | Functions | Renumbered |
| 14 | File I/O | 16 | File I/O | Renumbered |
| 15 | Objects | 17 | The Python Object Model | Renumbered, now unit capstone |
| 16 | Python-SQL | 18 | Python Meets SQL | **Moved to Building Data Products** |
| 17 | Marimo | 24 | Computational Documents (part) | **Merged with Quarto Part 2** |
| 18 | Polars | 19 | DataFrames with Polars | **Moved to Building Data Products** |
| 19 | Altair | 20 | Visualization with Altair | Renumbered |
| 20 | Excel | 21 | Working with Excel | Renumbered |
| 21 | Python Projects | 22 | Python Projects with uv | Renumbered |
| 22 | Quarto | 03 + 24 | Writing with Quarto / Computational Documents | **Split: markdown → Ch 03, code cells → Ch 24** |
| 23 | Code Quality | 23 | Code Quality | Same position |
| 24 | Arrow | 25 | Apache Arrow & the Columnar Revolution | Renumbered |
| 25 | Typer | 26 | Building CLI Tools with Typer | Renumbered |

## Chapter Count

- 26 chapters (vs. current 25)
- Net: +1 from splitting Collections/Control Flow, +1 from splitting Quarto, -1 from merging Marimo into Computational Documents
