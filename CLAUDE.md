# Computational Workflows for Engineers - Book Development

## Book Overview
I'm writing "Computational Workflows for Engineers" for IENG 331: Computer Applications in Industrial Engineering at West Virginia University. This is a 300-level course for non-CS engineering students (primarily industrial engineers, but open to all disciplines). The book transforms students from computational "passengers" to "drivers", moving them beyond consumer applications to building professional-grade data products.

The book is designed to be self-teachable: someone finding it online should be able to learn everything without taking the class. It's also used in a 15-week semester with 2 lectures per week. See `lecture-schedule.md` for the full schedule.

## Pedagogical Framework
- **North Star**: "Making Learning Whole" by David Perkins (notes uploaded as `_making-learning-whole-notes.md`)
- **Core principle**: Students "play the whole game" from the beginning rather than drilling isolated skills
- **Approach**: Business-question-first framing using realistic datasets (primarily Northwind)
- **Philosophy**: Build complete data products that serve customers, not one-off analyses
- **Tone**: Professional but accessible; challenging without being intimidating; prose over bullet points
- **Spiral curriculum**: Quarto is introduced as a writing tool in Unit 1, then revisited with computation in the capstone

## Book Structure (3 Units + Capstone)
1. **The Professional Toolkit** (Ch 01–06) - Computers, filesystems, Quarto authoring, CLI, Git, GitHub
2. **Data with SQL** (Ch 07–11) - DuckDB, querying, joins, analytics, data modeling
3. **Python** (Ch 12–17) - Fundamentals, collections, control flow, functions, file I/O, object model
4. **Building Data Products** (Ch 18–26) - Python-SQL, Polars, Altair, Excel, uv, code quality, computational documents, Arrow, Typer

### Assessment Structure
- **Test 1** after Unit 1: CLI, Git, filesystem concepts
- **Test 2** after Unit 2: SQL queries, schema design
- **Test 3** after Unit 3: Python language skills
- **Final Project** for capstone: Build a complete data product

### Chapter Listing
| Ch | File | Title |
|----|------|-------|
| 01 | 01-computers.qmd | How Computers Work |
| 02 | 02-filesystem.qmd | Files & Filesystems |
| 03 | 03-quarto.qmd | Writing with Quarto |
| 04 | 04-cli.qmd | The Command Line |
| 05 | 05-git.qmd | Version Control with Git |
| 06 | 06-github.qmd | Collaboration with GitHub |
| 07 | 07-databases.qmd | Databases & DuckDB |
| 08 | 08-querying.qmd | Querying Data |
| 09 | 09-joins.qmd | Joining Tables |
| 10 | 10-analytics.qmd | Analytical SQL |
| 11 | 11-modeling.qmd | Data Modeling |
| 12 | 12-python-fundamentals.qmd | Python Fundamentals |
| 13 | 13-collections.qmd | Collections |
| 14 | 14-control-flow.qmd | Control Flow |
| 15 | 15-functions.qmd | Functions |
| 16 | 16-file-io.qmd | File I/O |
| 17 | 17-objects.qmd | The Python Object Model |
| 18 | 18-python-sql.qmd | Python Meets SQL |
| 19 | 19-polars.qmd | DataFrames with Polars |
| 20 | 20-altair.qmd | Visualization with Altair |
| 21 | 21-excel.qmd | Working with Excel |
| 22 | 22-python-projects.qmd | Python Projects with uv |
| 23 | 23-code-quality.qmd | Code Quality |
| 24 | 24-computational-documents.qmd | Computational Documents |
| 25 | 25-arrow.qmd | Apache Arrow & the Columnar Revolution |
| 26 | 26-typer.qmd | Building CLI Tools with Typer |

## Technical Stack
- **Version control**: Git/GitHub
- **Database**: DuckDB (ANSI SQL before database-specific features)
- **Python**: 3.13 with type hints, modern tooling
- **Project management**: uv
- **Editor**: Zed
- **Documentation**: Quarto
- **Code quality**: Ruff, basedpyright
- **Dataset**: Northwind (used consistently throughout the book; course projects may use different datasets)
- **Interactive playground**: `marimo/playground.py` — a WASM-deployed marimo app with SQL editors (connected to Northwind via DuckDB) and standalone Python editors. Both are operational. Uses `mo.ui.code_editor()` for input and `exec()` with `redirect_stdout` for Python output capture.

## Writing Guidelines

### Quarto/Markdown Format
- Use Quarto-flavored Markdown: https://quarto.org/docs/authoring/markdown-basics.html
- Reference R for Data Science (2e) as formatting north star: https://r4ds.hadley.nz
- Code blocks MUST include filename attribute: `{.python filename="script.py"}` or `{.bash filename="terminal"}`
- REPL-style code blocks use: `{.python filename="Python REPL"}`
- Use proper cross-references, annotated code blocks, callout boxes
- Replace em dashes (`—`) with `, ` (comma-space)
- Never use backslash (`\`) for line continuation; use parentheses or method chaining

### Chapter Structure
- Start with authentic business problems
- Include inline exercises for immediate reinforcement (every 2-3 new concepts)
- End with comprehensive capstone problems
- Add chapter summary
- Add glossary of terms introduced

### Exercise Format
Inline exercises use this exact format:
```
### Exercises

1. Question text...

2. Question text...

::: {.callout-tip title="Solutions" collapse="true"}

**1.** Solution text...

**2.** Solution text...

:::
```

### Content Style
- **Prose over bullets**: Write in paragraphs, avoid excessive lists/headers unless explicitly needed
- **Complete examples**: Runnable code, not partial snippets
- **Technical accuracy**: Version-agnostic where possible; cross-platform (Windows/macOS/Linux)
- **Avoid generic verbiage**: No "In today's data-driven world" or similar filler
- **Show, don't tell**: Demonstrate concepts through working examples
- **print() in scripts**: All script-style code blocks must use `print()` for any output; only REPL blocks may use bare expressions

### Pedagogical Patterns
- Explain fundamental computer concepts that consumer apps hide (file systems, memory, disk vs. in-memory)
- Use prediction exercises to build metacognitive skills
- Include debug scenarios to strengthen troubleshooting
- Sequence carefully: Don't reference concepts before they're taught
- Balance conceptual understanding with hands-on application
- Add SQL analogies when introducing Python concepts (students know SQL before Python)

## Common Tasks

### When writing new chapter content:
1. Check if related SKILL.md exists and read it first
2. Verify chapter fits in overall unit progression
3. Use Northwind dataset for examples where applicable
4. Include both conceptual explanation and practical application
5. Add inline exercises (every 2-3 concepts) and end-of-chapter capstone
6. Write summary and glossary

### When reviewing/revising content:
1. Check for technical accuracy (especially version-specific references)
2. Verify cross-references work with current chapter numbering
3. Ensure exercises align with previously taught material
4. Confirm code examples are complete and runnable
5. Check for DuckDB-specific functions that undermine ANSI SQL goals
6. Verify print() usage in script-style code blocks

### When creating exercises:
1. Mix conceptual understanding with hands-on coding
2. Use realistic business questions
3. Build on previous exercises progressively
4. Include debug/troubleshooting scenarios
5. Vary difficulty levels

## TODO: Add Missing End-of-Chapter Exercise Solutions

Every `## Exercises` section needs a `::: {.callout-tip title="Solutions" collapse="true"}` block with worked solutions. Inline `### Exercises` (mid-chapter) already have solutions. The following end-of-chapter sections are missing them:

### Unit 1: The Professional Toolkit
- [ ] **Ch 04** `04-cli.qmd` — 10 multiple-choice questions, needs answer key
- [ ] **Ch 05** `05-git.qmd` — 10 multiple-choice questions, needs answer key
- [ ] **Ch 06** `06-github.qmd` — 10 multiple-choice questions, needs answer key

### Unit 3: Python
- [ ] **Ch 12** `12-python-fundamentals.qmd` — 4 hands-on exercises (Predict, Unit Conversion, REPL Exploration, Northwind Product Card)
- [ ] **Ch 14** `14-control-flow.qmd` — end-of-chapter exercises
- [ ] **Ch 15** `15-functions.qmd` — end-of-chapter exercises
- [ ] **Ch 16** `16-file-io.qmd` — end-of-chapter exercises
- [ ] **Ch 17** `17-objects.qmd` — end-of-chapter exercises

### Unit 4: Building Data Products
- [ ] **Ch 18** `18-python-sql.qmd` — end-of-chapter exercises
- [ ] **Ch 19** `19-polars.qmd` — end-of-chapter exercises
- [ ] **Ch 20** `20-altair.qmd` — end-of-chapter exercises
- [ ] **Ch 21** `21-excel.qmd` — end-of-chapter exercises
- [ ] **Ch 22** `22-python-projects.qmd` — 3 hands-on exercises (Peer Installation, Template Repository, Reproducibility Check, README Review)
- [ ] **Ch 23** `23-code-quality.qmd` — 3 hands-on exercises
- [ ] **Ch 25** `25-arrow.qmd` — 2 hands-on exercises
- [ ] **Ch 26** `26-typer.qmd` — 2 hands-on exercises + Final Project Assembly

Chapters 1-3 were completed. Chapters 7-11 (SQL) and 13 (Collections) already have complete solutions. Chapter 24 (Computational Documents) already has complete solutions.

Also check: some `solution.py` filename attributes on code blocks in exercise solutions may need standardization.

### Format reminder
Solutions go AFTER the numbered questions:
```
## Exercises {.unnumbered}

1. Question...
2. Question...

::: {.callout-tip title="Solutions" collapse="true"}

**1.** Answer...

**2.** Answer...

:::
```

## Reference Materials
- Making Learning Whole Notes: `_making-learning-whole-notes.md`
- Lecture Schedule: `lecture-schedule.md`
- Existing chapters available in project files
- O'Reilly resources (with proper attribution)

## Important Constraints
- The book must read as a **standalone, self-teachable resource** — never use "course", "semester", "class" (academic), "instructor", "classmate", or "student" in chapters or appendices. Use "this book", "colleague", "reader", etc. instead. (Slides are instructor-facing and exempt.)
- Don't explicitly say "for industrial engineers" (audience includes multiple disciplines)
- Maintain professional tone without being dry
- Challenge readers appropriately for 300-level
- Emphasize production-quality work over academic exercises
- Focus on tools that prepare readers for real data work
- Book uses Northwind for all examples; capstone patterns should transfer to any dataset
