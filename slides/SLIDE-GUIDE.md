# Slide Deck Design & Pedagogy Guide

Reference document for creating presenter slide decks (RevealJS via Quarto) for *Computational Workflows for Engineers*. This guide captures the design philosophy, structural patterns, and conventions used across all chapter decks.

## Design Philosophy

These slides are **presenter support for live-coding lectures**, not standalone reference material. Students have the book for that. The slides act as signposts: they tell the audience where they are, where they're going, and what to pay attention to, then get out of the way so the real teaching happens in the live demo.

### The Core Tension

The audience's attention is split three ways: slides, your editor/terminal, and your narration. A good slide deck for this context **minimizes competition** between these channels. Slides should never show the same code you're about to type live.

## Structural Pattern: Frame → Demo → Debrief

Each major concept follows a three-beat rhythm:

1. **Frame** — A slide that sets up the problem or question ("How do we track changes to files over time?"). This gives students a mental hook before the demo starts.
2. **Demo** — You switch to your editor/terminal and live-code. No slides visible (or a static "context" slide parked in the background).
3. **Debrief** — A slide that summarizes what they just watched: a diagram, a comparison table, a mental model, or a concise takeaway.

The slides never duplicate code that you'll type live. If it can be typed and run, it belongs in the demo, not on a slide.

## Slide Budget

Target **15–20 slides** per 75-minute session. That's roughly one slide every 4–5 minutes, with long stretches where slides are parked on a checkpoint while you're in the terminal.

## What Goes on Slides vs. What Stays in the Live Demo

### Slides are for:

- Architecture diagrams and visual mental models
- Comparison tables (e.g., RAM vs. disk, text editor vs. word processor)
- Prediction exercises and think-pair-share prompts
- Key vocabulary or definitions that anchor a concept
- Recap/summary slides
- Forward/backward references to other chapters

### Live demos are for:

- Any code that can be typed and executed
- Tool tours (Zed, terminal, DuckDB CLI, Git)
- Real-time exploration of output
- Debugging walkthroughs
- Anything where the process of building is the lesson

## Speaker Notes as Live-Coding Script

Every slide includes speaker notes (visible only in presenter view, press `S` in RevealJS). These serve as your **demo script** and include:

- What to demo and the specific commands/steps to follow
- Questions to ask students (cold call, think-pair-share, prediction)
- Connections forward to later chapters or backward to earlier ones
- Timing cues (e.g., "Don't belabor this — quick framing only")
- Transition prompts to move from slide to terminal and back

## Consistent Chapter Structure

Every slide deck follows this skeleton:

1. **Title slide** — Chapter name, subtitle with module context, dark background (`#2E3440`)
2. **"Where we are" slide** — Connects to previous chapter, frames today's driving question
3. **Frame/debrief cycles** — 10–15 slides covering major sections
4. **Prediction exercise(s)** — Dark background (`#3B4252`) to visually signal "stop and think"
5. **Recap slide** — Bulleted summary of key takeaways (`.smaller` class)
6. **"Next time" slide** — Teaser for next chapter, dark background

## RevealJS / Quarto Conventions

### YAML Front Matter (copy for every deck)

```yaml
format:
  revealjs:
    theme: default
    highlight-style: nord
    code-line-numbers: false
    slide-number: true
    progress: true
    hash-type: number
    footer: "IENG 331 · Computational Workflows for Engineers"
    transition: fade
    transition-speed: fast
    embed-resources: true
    title-slide-attributes:
      data-background-color: "#2E3440"
```

### Formatting Conventions

- **Incremental reveals** (`. . .`): Use sparingly for punchlines that should land after verbal setup. Don't use for every bullet.
- **`.smaller` class**: For slides with tables or more content that needs to fit.
- **`.r-fit-text`**: For big-impact single statements (e.g., "The Big Idea" slides).
- **Dark background slides** (`{background-color="#3B4252"}`): Reserved for prediction exercises and the "Next Time" teaser.
- **Two-column layouts** (`:::: {.columns}`): For side-by-side comparisons (RAM vs. disk, before vs. after, etc.).
- **Code blocks**: Use `{.sql filename="query.sql"}` or `{.bash filename="terminal"}` syntax, matching book conventions. Only show code on slides when it's a reference pattern, not when it will be live-coded.

### No Mermaid Diagrams

Mermaid rendering in Quarto RevealJS is unreliable (coloring issues, sometimes renders as raw code). Use native RevealJS content instead:

- **Column layouts** for side-by-side comparisons
- **Tables** for sequential processes (step-by-step flows)
- **Styled text with emoji** for simple diagrams (⚡, 💾, →, ⟷)
- **`.r-fit-text`** for big visual statements

## Pedagogical Patterns

### Prediction Exercises
Present a scenario and ask "What happens?" before revealing the answer. These build metacognitive skills. Always give students time to think (cold call, pair discussion, or silent reflection). Use dark background slides to visually signal the shift.

### Forward/Backward References
Explicitly connect concepts to earlier and later chapters. Students need to see how the pieces fit together. Use speaker notes to remind yourself of these connections.

### Business-Question Framing
Where possible, frame concepts through the lens of a realistic problem rather than abstract theory. "You need to find last quarter's top customers" is better than "Let's learn about SQL aggregation."

### Debug Scenarios
When a chapter involves common mistakes (e.g., forgetting to save, wrong working directory, SQL syntax errors), build a "what went wrong?" moment into the slides or speaker notes. Students learn as much from diagnosing problems as from building solutions.

## File Naming Convention

Slide files live in `slides/` and follow the chapter numbering:

```
slides/01-computers.qmd
slides/02-filesystem.qmd
slides/03-cli.qmd
...
slides/25-typer.qmd
```
