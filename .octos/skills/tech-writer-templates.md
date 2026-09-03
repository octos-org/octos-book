# Article Templates Reference

## Incident Analysis Template

```
# Title: [Thesis], not [Topic]

> Introduction (1 sentence)

## 1. Factual Reconstruction
  Per incident: when, version, behavior, impact, architectural layer

## 2. Technical Background (if needed)
  Architecture diagram, only essential context

## 3. Per-Incident Analysis
  Per incident:
    1. Bug essence (1 sentence)
    2. Current implementation problem (with code)
    3. What CAN be done (with code)
    4. What CANNOT be done (label limitations)
    5. Defense rating: High/Medium/Low + rationale

## 4. Complementary Mechanisms
  What's needed beyond the primary defense

## 5. Summary
  Table: Incident x Bug Type x Defense x Complement
```

## Source Code Analysis Template

```
# Title

> Source and methodology

## 1. Discovery Process
  Tools, approach, what was found

## 2. Architecture Overview
  Mermaid diagram, layer descriptions

## 3. Per-Module Analysis
  Per module:
    1. Purpose and location
    2. Key code snippets (with file:line)
    3. Design patterns found
    4. Reusable insights

## 4. Patterns Summary
  Table: Module x Pattern x Applicable To
```

## Technology Comparison Template

```
# Title: [A vs B for C]

> Comparison scope and criteria

## 1. Technology Introductions
  Objective descriptions, no judgment

## 2. Evaluation Dimensions
  Per dimension:
    - Technology A: capability + evidence
    - Technology B: capability + evidence
    - Verdict: which is stronger and why

## 3. Summary
  Table: Dimension x A Score x B Score x Winner
```

## Book Chapter Template

```
# Chapter N: Title

> **Positioning**: This chapter analyzes [core topic in one sentence].
> Prerequisites: [Chapter M]. Use when: [applicable scenario].

## Why This Matters
  2-3 paragraphs motivation

## Source Code Analysis
  Core analysis with file:line references
  Mermaid diagrams for flows

## Pattern Extraction
  Per pattern: name, problem, code template, preconditions

## What Users Can Do
  Actionable advice (if applicable)

---

### Version Evolution Note (for actively-maintained software)
> Core analysis based on v{baseline}. As of v{latest},
> [{subsystem}] has [no major changes | the following changes: ...].
```

## Book Preface Template (10+ chapters)

```
# Preface

[Project motivation]

## Reading Preparation

### Prerequisites
- [Domain 1]: [requirement]
- Not needed: [exclusions]

### Recommended Reading Paths
Path A: [Role] ([Goal])
> ch01 → ch03 → ch05 → ...

Path B: [Role] ([Goal])
> ch02 → ch07 → ...

### Book Knowledge Map
[Mermaid diagram: part dependencies + anchor chapter]

### Notation Guide
[Source reference format, evidence tiers, diagram types]
```

## E2E Trace Template (Cross-Chapter Synthesis)

```
## Case N: [Scenario Title]
> Chapters linked: ch03 → ch05 → ch16 → ...

### Scenario
[What the user does and what systems are involved]

[Mermaid sequence diagram]

### Stage 1: [Stage] (chNN)
[What happens, with file:line references]

### Stage 2: ...

### What this trace reveals
[Design principle this flow demonstrates]
```

## Budget Presets Detail

### Single Thesis (3-5K words)
- 1 core case analyzed in 3 layers
- 2 supporting cases mentioned briefly (1 paragraph each)
- Best for: blog posts, quick analyses

### Multi-Case Analysis (8-12K words)
- 3 cases, each 3-4 layers deep
- Shared background section
- Cross-case comparison table
- Best for: conference talks, detailed writeups

### Series Long-Form (12-20K words)
- 3-5 cases, each 4 layers deep
- Each section has independent reading value
- Best for: technical reports, series articles

### Book Chapter (5-8K words)
- Depth follows outline spec
- Every claim backed by source reference
- Cross-chapter references only, no repetition
- Best for: technical books

## Anti-Pattern Quick Reference

| Do | Don't |
|----|-------|
| Hyperlink issue numbers | Leave bare numbers |
| State simplified what | Simplify without noting |
| Describe both sides | Only criticize one side |
| "High + requires X" rating | "Somewhat helps" |
| End with facts/table | End with "security matters" |
| Reference prior parts | Assume reader read everything |

## Depth Layer Examples

### 2-Layer Analysis (Quick)
> Source map was in production build (L1).
> Bun's bundler didn't propagate the production flag (L2).
> → Defense: Use enum to separate modes.

### 3-Layer Analysis (Practitioner)
> Source map was in production build (L1).
> Bun's bundler didn't propagate the production flag (L2).
> Rust enum can make production+sourcemap illegal (L3).
> → Stop here. Note "production Sentry needs handled separately."

### 4-Layer Analysis (Deep Dive)
> Source map was in production build (L1).
> Bun's bundler didn't propagate the production flag (L2).
> Rust enum can make production+sourcemap illegal (L3).
> But production builds need source maps for Sentry → model ExternalSourceMap as separate type that can't be inlined (L4).
> → Full analysis with trade-offs.
