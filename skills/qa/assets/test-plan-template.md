# qa Test Plan — Phase {N}: {Phase Title}

| Field | Value |
|-------|-------|
| Phase | {N} |
| Phase Title | {title} |
| Date | {YYYY-MM-DD} |
| Total Tests | {count} |
| P0 (Must Pass) | {count} |
| P1 (Should Pass) | {count} |
| P2 (Nice to Pass) | {count} |
| P3 (Informational) | {count} |

---

## How This Differs From dev's Validation

| dev Gate | What dev Checked | What qa Adds |
|----------|-----------------|--------------|
| {gate from phases.md} | {what the gate verifies} | {qa's additional tests beyond this gate} |
| {gate from phases.md} | {what the gate verifies} | {qa's additional tests beyond this gate} |

---

## Category A: Regression Suite (P0)

All automated gates from all prior phases. Must ALL pass before any other tests run.

| Test ID | Phase | Gate Description | Command | Expected |
|---------|-------|-----------------|---------|----------|
| A-01 | 0 | {gate description} | `{command}` | {expected result} |
| A-02 | 0 | {gate description} | `{command}` | {expected result} |
| A-03 | 1 | {gate description} | `{command}` | {expected result} |

---

## Category B: Functional Correctness (P0)

Tests that dev's gates did NOT cover: edge cases, error paths, boundary values.

| Test ID | Priority | Description | Given | When | Then | Tool |
|---------|----------|-------------|-------|------|------|------|
| B-01 | P0 | {description} | {precondition} | {action} | {expected result} | {Bash/Playwright/Grep} |
| B-02 | P0 | {description} | {precondition} | {action} | {expected result} | {tool} |

---

## Category C: Full User Journeys (P0)

End-to-end flows simulating real user sessions. Each journey is 5-20 sequential actions.

### Journey C-01: {Journey Name}

**Persona**: {who is doing this}
**Goal**: {what they're trying to accomplish}

| Step | Action | Expected Result | Tool |
|------|--------|----------------|------|
| 1 | {action} | {expected} | {tool} |
| 2 | {action} | {expected} | {tool} |
| 3 | {action} | {expected} | {tool} |

**Verification**: {what to check after journey completes}

### Journey C-02: {Journey Name}

{same format}

---

## Category D: Security (P0)

Input validation, data exposure, dependency audit, auth checks.

| Test ID | Priority | Target | Attack Vector | Test Input | Expected Defense | Tool |
|---------|----------|--------|--------------|------------|-----------------|------|
| D-01 | P0 | {input field / endpoint} | XSS | `<script>alert(1)</script>` | {sanitized / escaped} | {tool} |
| D-02 | P0 | {source code} | Secret exposure | Grep for patterns | {no matches found} | Grep |
| D-03 | P0 | {dependencies} | Known vulns | `npm audit` | {no critical/high} | Bash |

---

## Category E: UI/UX Visual (P1)

Layout verification at 4 viewports for every page/route in the phase.

| Test ID | Priority | Page/Route | Viewport | Verification | Tool |
|---------|----------|-----------|----------|-------------|------|
| E-01 | P1 | {route} | 375x667 | {what to verify} | Playwright |
| E-02 | P1 | {route} | 768x1024 | {what to verify} | Playwright |
| E-03 | P1 | {route} | 1280x720 | {what to verify} | Playwright |
| E-04 | P1 | {route} | 1920x1080 | {what to verify} | Playwright |

---

## Category F: Accessibility (P1)

Keyboard navigation, screen reader compatibility, color contrast, focus management.

| Test ID | Priority | Element/Page | WCAG Criterion | Verification | Tool |
|---------|----------|-------------|----------------|-------------|------|
| F-01 | P1 | {element} | 2.1.1 Keyboard | Tab navigation reaches element | Playwright |
| F-02 | P1 | {element} | 4.1.2 Name, Role | Accessible name present | Playwright snapshot |
| F-03 | P1 | {page} | 1.4.3 Contrast | Text contrast >= 4.5:1 | Playwright evaluate |

---

## Category G: Performance (P2)

Bundle size, console errors, network requests, render performance.

| Test ID | Priority | Metric | Threshold | Verification | Tool |
|---------|----------|--------|-----------|-------------|------|
| G-01 | P2 | Bundle size | {threshold} | Check build output | Bash |
| G-02 | P2 | Console errors | 0 during normal flow | Monitor during journeys | Playwright |
| G-03 | P2 | Failed network requests | 0 during normal flow | Monitor during journeys | Playwright |

---

## Category H: Convention Compliance (P2)

Conventions from key-learnings and Consistency Rules from phases.md.

| Test ID | Priority | Convention | Source | Files to Check | Verification | Tool |
|---------|----------|-----------|--------|---------------|-------------|------|
| H-01 | P2 | {convention} | key-learnings-{NN} | {file glob} | Grep for pattern | Grep |
| H-02 | P2 | {convention} | Consistency Rules | {file glob} | Grep for pattern | Grep |
