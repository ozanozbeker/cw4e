# Computational Workflows for Engineers - Book Development

## Book Overview
I'm writing "Computational Workflows for Engineers" for IENG 331: Computer Applications in Industrial Engineering at West Virginia University. This is a 300-level course for non-CS engineering students (primarily industrial engineers, but open to all disciplines). The book transforms students from computational "passengers" to "drivers", moving them beyond consumer applications to building professional-grade data products.

## Pedagogical Framework
- **North Star**: "Making Learning Whole" by David Perkins (notes uploaded as `_making-learning-whole-notes.md`)
- **Core principle**: Students "play the whole game" from the beginning rather than drilling isolated skills
- **Approach**: Business-question-first framing using realistic datasets (primarily Northwind)
- **Philosophy**: Build complete data products that serve customers, not one-off analyses
- **Tone**: Professional but accessible; challenging without being intimidating; prose over bullet points

## Book Structure (5 Modules)
1. **Computational Foundations** (WORKING DRAFT COMPLETE) - CLI, Git, file systems
2. **Databases & SQL** (WORKING DRAFT COMPLETE) - DuckDB, analytical workflows, ANSI SQL
3. **Programming** (WORKING DRAFT COMPLETE) - Python fundamentals through object model
4. **Integration** (WORKING DRAFT COMPLETE) - Python-SQL bridge, workflow tools, Excel delivery
5. **Production** (WORKING DRAFT COMPLETE) - uv, Quarto, code quality, Apache Arrow, CLI with Typer

## Technical Stack
- **Version control**: Git/GitHub
- **Database**: DuckDB (ANSI SQL before database-specific features)
- **Python**: 3.13 with type hints, modern tooling
- **Project management**: uv
- **Editor**: Zed
- **Documentation**: Quarto
- **Code quality**: Ruff, basedpyright
- **Dataset**: Northwind (used consistently throughout)

## Writing Guidelines

### Quarto/Markdown Format
- Use Quarto-flavored Markdown: https://quarto.org/docs/authoring/markdown-basics.html
- Reference R for Data Science (2e) as formatting north star: https://r4ds.hadley.nz
- Code blocks MUST include filename attribute: `{.python filename="script.py"}` or `{.bash filename="terminal"}`
- Use proper cross-references, annotated code blocks, callout boxes
- Replace em dashes (`—`) with `, ` (comma-space)

### Chapter Structure
- Start with authentic business problems
- Include inline exercises for immediate reinforcement
- End with comprehensive capstone problems
- Add chapter summary
- Add glossary of terms introduced

### Content Style
- **Prose over bullets**: Write in paragraphs, avoid excessive lists/headers unless explicitly needed
- **Complete examples**: Runnable code, not partial snippets
- **Technical accuracy**: Version-agnostic where possible; cross-platform (Windows/macOS/Linux)
- **Avoid generic verbiage**: No "In today's data-driven world" or similar filler
- **Show, don't tell**: Demonstrate concepts through working examples

### Pedagogical Patterns
- Explain fundamental computer concepts that consumer apps hide (file systems, memory, disk vs. in-memory)
- Use prediction exercises to build metacognitive skills
- Include debug scenarios to strengthen troubleshooting
- Sequence carefully: Don't reference concepts before they're taught
- Balance conceptual understanding with hands-on application

## Common Tasks

### When writing new chapter content:
1. Check if related SKILL.md exists and read it first
2. Verify chapter fits in overall module progression
3. Use Northwind dataset for examples where applicable
4. Include both conceptual explanation and practical application
5. Add inline exercises and end-of-chapter capstone
6. Write summary and glossary

### When reviewing/revising content:
1. Check for technical accuracy (especially version-specific references)
2. Verify cross-references work
3. Ensure exercises align with previously taught material
4. Confirm code examples are complete and runnable
5. Check for DuckDB-specific functions that undermine ANSI SQL goals

### When creating exercises:
1. Mix conceptual understanding with hands-on coding
2. Use realistic business questions
3. Build on previous exercises progressively
4. Include debug/troubleshooting scenarios
5. Vary difficulty levels

## Reference Materials
- Making Learning Whole Notes: `_making-learning-whole-notes.md`
- Existing chapters available in project files
- O'Reilly resources (with proper attribution)

## Important Constraints
- Don't explicitly say "for industrial engineers" (course attracts multiple disciplines)
- Maintain professional tone without being dry
- Challenge students appropriately for 300-level
- Emphasize production-quality work over academic exercises
- Focus on tools that prepare students for real data work
