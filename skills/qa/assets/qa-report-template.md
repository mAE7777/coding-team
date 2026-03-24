# qa Report — Phase {N}: {Phase Title}

| Field | Value |
|-------|-------|
| Phase | {N} |
| Phase Title | {title} |
| Date | {YYYY-MM-DD} |
| **qa Result** | **{PASS / CONDITIONAL PASS / FAIL}** |
| Total Tests | {count} |
| Passed | {count} |
| Failed | {count} |
| Skipped | {count} |
| Code Review Findings | {CRITICAL count} / {MEDIUM count} / {LOW count} |

---

## Executive Summary

{2-3 sentences summarizing the qa result: what was tested, key findings, and the verdict with rationale.}

---

## Test Results by Category

### Category A: Regression Suite

| Test ID | Phase | Gate | Command | Result | Evidence |
|---------|-------|------|---------|--------|----------|
| A-01 | {M} | {description} | `{command}` | {PASS/FAIL} | {output or reference} |

**Regression Result**: {ALL PASS / FAILURE — details}

### Category B: Functional Correctness

| Test ID | Priority | Description | Result | Evidence |
|---------|----------|-------------|--------|----------|
| B-01 | P0 | {description} | {PASS/FAIL} | {error output, file:line} |

### Category C: Full User Journeys

| Journey ID | Journey Name | Steps | Result | Failed At | Evidence |
|-----------|-------------|-------|--------|-----------|----------|
| C-01 | {name} | {total steps} | {PASS/FAIL} | {step # or N/A} | {screenshot, error} |

### Category D: Security

| Test ID | Priority | Target | Attack Vector | Result | Evidence |
|---------|----------|--------|--------------|--------|----------|
| D-01 | P0 | {target} | {vector} | {PASS/FAIL} | {output} |

### Category E: UI/UX Visual

| Test ID | Priority | Page | Viewport | Result | Evidence |
|---------|----------|------|----------|--------|----------|
| E-01 | P1 | {page} | {viewport} | {PASS/FAIL} | {screenshot path} |

### Category F: Accessibility

| Test ID | Priority | Element | Criterion | Result | Evidence |
|---------|----------|---------|-----------|--------|----------|
| F-01 | P1 | {element} | {criterion} | {PASS/FAIL} | {snapshot excerpt} |

### Category G: Performance

| Test ID | Priority | Metric | Threshold | Actual | Result |
|---------|----------|--------|-----------|--------|--------|
| G-01 | P2 | {metric} | {threshold} | {measured value} | {PASS/FAIL} |

### Category H: Convention Compliance

| Test ID | Priority | Convention | Files Checked | Violations | Result |
|---------|----------|-----------|---------------|------------|--------|
| H-01 | P2 | {convention} | {count} | {count, with file:line list} | {PASS/FAIL} |

---

## Code Review Findings

| # | Severity | Category | File:Line | Finding | Recommendation |
|---|----------|----------|-----------|---------|---------------|
| 1 | {CRITICAL/MEDIUM/LOW} | {dimension from 8-dimension checklist} | {file:line} | {what was found} | {how to fix it} |
| 2 | {severity} | {category} | {file:line} | {finding} | {recommendation} |

**Total**: {CRITICAL count} CRITICAL, {MEDIUM count} MEDIUM, {LOW count} LOW

---

## Key-Learnings Corrections

{If no corrections needed: "No inaccuracies found in key-learnings."}

| Section | What Key-Learnings Claimed | What Actually Exists | Correction Applied |
|---------|---------------------------|---------------------|--------------------|
| {section name} | {original claim} | {actual state} | {correction made} |

---

## Blocking Issues

{If PASS: "No blocking issues."}

{If CONDITIONAL PASS: "No P0 blocking issues. Non-blocking items listed in recommendations."}

{If FAIL:}

### P0 Failures

| Test ID | Category | Description | Evidence |
|---------|----------|-------------|----------|
| {test ID} | {category} | {what failed} | {evidence} |

### CRITICAL Findings

| # | File:Line | Finding | Impact |
|---|-----------|---------|--------|
| {number} | {file:line} | {finding} | {what could go wrong} |

---

## Recommendations

### Must Fix (before proceeding to next phase)

{List items that MUST be fixed — P0 failures and CRITICAL findings}

1. **{short title}**: {description} — {file:line}

### Should Fix (recommended before next phase)

{List items that SHOULD be fixed — P1 failures and MEDIUM findings}

1. **{short title}**: {description} — {file:line}

### Consider (can be deferred)

{List items worth considering — P2 failures and LOW findings}

1. **{short title}**: {description} — {file:line}

---

## Test Coverage Summary

| Category | Tests | Passed | Failed | Skipped | Pass Rate |
|----------|-------|--------|--------|---------|-----------|
| A: Regression | {count} | {count} | {count} | {count} | {%} |
| B: Functional | {count} | {count} | {count} | {count} | {%} |
| C: Journeys | {count} | {count} | {count} | {count} | {%} |
| D: Security | {count} | {count} | {count} | {count} | {%} |
| E: UI/UX | {count} | {count} | {count} | {count} | {%} |
| F: Accessibility | {count} | {count} | {count} | {count} | {%} |
| G: Performance | {count} | {count} | {count} | {count} | {%} |
| H: Conventions | {count} | {count} | {count} | {count} | {%} |
| **Total** | **{count}** | **{count}** | **{count}** | **{count}** | **{%}** |
