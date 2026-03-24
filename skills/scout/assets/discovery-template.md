# Discovery Report: {Topic}

**Date:** {YYYY-MM-DD}
**Investigation Type:** {Greenfield / Brownfield / Migration / Evaluation}
**Project:** {project name or "N/A" for greenfield}

---

## Executive Summary

{2-3 sentences: what was investigated, key finding, recommended approach}

---

## Research Sources

| Source | Type | Key Finding |
|--------|------|-------------|
| {URL or doc name} | {Tier 1/2/3} | {what was learned} |

---

## Raw Evidence Summary

{Benchmark numbers, doc excerpts, community signals — raw data before interpretation.
This section exists so the reader sees evidence before recommendations.}

### Benchmarks & Metrics
| Metric | {Candidate A} | {Candidate B} | Source |
|--------|--------------|--------------|--------|

### Key Findings from Documentation
- {finding — [T1] source}

### Community Signals
- {signal — [T2/T3] source}

---

## Constraint Map

{For Brownfield/Migration only. Omit for Greenfield/Evaluation.}

### Hard Constraints (cannot change)
- {constraint — source}

### Soft Constraints (expensive to change)
- {constraint — source}

### Compatibility Constraints
- {constraint — source}

---

## Options Analyzed

### Cell Notation

`{value} {tags}` where tags use: `!` Active, `?` Unresolved, `H/M/L` confidence,
`v` VOLATILE. Omit tags for Collapsed+MODERATE/STABLE (baseline). Row prefixed
`[WEAK]` if >50% cells are LOW or Unresolved.

### Core Criteria

| Criterion | Fill rule | {Approach A} | {Approach B} | {Approach C} |
|-----------|-----------|-------------|-------------|-------------|
| Complexity | file/component/API count (Low 1-5, Med 6-15, High 16+) | | | |
| Risk | count of Active+LOW or Unresolved findings per approach | | | |
| Ecosystem Maturity | npm downloads/month + last release date + maintainer count | | | |
| Estimated Phases | integer | | | |

### {Investigation Type} Criteria

<!--
  Include 2 criteria based on investigation type:
  - Greenfield: Learning Curve (time-to-first-feature estimate), Community Support (SO answers + Discord/GitHub activity)
  - Brownfield: Integration Points (count of touch points with existing code), Breaking Changes (count of API/schema changes required)
  - Migration: Migration Path Clarity (official guide exists? community reports?), Rollback Cost (reversible/partial/irreversible)
  - Evaluation: Performance (benchmark numbers with source), Maintainability (code complexity metrics or proxy measures)
-->

| Criterion | Fill rule | {Approach A} | {Approach B} | {Approach C} |
|-----------|-----------|-------------|-------------|-------------|
| {criterion 1} | {mechanical rule} | | | |
| {criterion 2} | {mechanical rule} | | | |

---

## Selected Approach: {Name}

**Rationale:** {Why this approach was selected, citing specific evidence}

### Architecture Sketch

{Component diagram, data flow, integration points — described in text or Mermaid}

### Technology Stack

| Technology | Version | Purpose | Justification |
|-----------|---------|---------|---------------|
| {library} | {version} | {what it does} | {why this choice} |

### Integration Points

{For brownfield: how the new work connects to existing systems}

### Counter-Arguments

**Strongest argument against this approach:** {real objection}
**Runner-up advocate's position:** {what they'd say}
**When this recommendation is wrong:** {condition}

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation | Fallback |
|------|-----------|--------|------------|----------|
| {risk description} | {Low/Med/High} | {description} | {mitigation strategy} | {what to do if risk materializes} |

---

## Pre-Mortem Summary

**Full report:** discovery/premortem-{slug}.md

| Classification | Count | Top Concerns |
|----------------|-------|--------------|
| Tiger | {N} | {top 3 Tiger titles} |
| Paper Tiger | {N} | — |
| Elephant | {N} | {top Elephant titles} |

**Key mitigations that affect feat phase design:**
- {mitigation 1 → affects Phase X}
- {mitigation 2 → affects Phase Y}

---

## Phase Estimation

| Phase | Scope | Complexity |
|-------|-------|------------|
| Phase 0 | Setup and scaffolding | {Low/Med} |
| Phase 1 | {capability} | {Low/Med/High} |
| Phase N | {capability} | {Low/Med/High} |

**Total estimated phases:** {N}

---

## Open Questions

- {Question that feat should resolve during phase design}
- {Unresolved decision that needs user input}
