---
name: qa
description: "Validate a completed development phase with independent, adversarial testing. Use this skill when the user says /qa, 'validate phase', 'run qa', 'test phase', or wants to verify a phase's implementation is genuinely production-ready. Generates its own test plan covering functionality, edge cases, user journeys, UI/UX, accessibility, security, performance, and regression. Updates key-learnings with qa findings."
argument-hint: <phase-number>
---

# qa — Independent Phase Validation Engine

> **EXECUTABLE WORKFLOW** — not reference material. Execute stages in order.
> Do not skip stages. Do not proceed without user confirmation at gates.

Independently validate a completed phase. qa is the final quality barrier — it generates its own tests, actively searches for defects, and produces a definitive pass/fail report.

---

## Available Tools

- **Playwright MCP**: All browser_* tools for interactive UI testing, viewport verification, accessibility snapshots, and evidence capture
- **Static Analysis**: Bash (builds, tests, audits), Glob/Grep/Read (code patterns, conventions, security anti-patterns)
- **Agent Delegation**: `feature-dev:code-reviewer` for adversarial code review with confidence-based filtering
- **Progress Tracking**: TaskCreate/TaskUpdate/TaskList for category-level progress

---

## Workflow

**Entry**: Follow the Skill Entry Protocol:
1. Read pipeline-state.md (verify clean state)
2. Verify prerequisites

### Stage 1: Initialization (Lightweight)

1. Parse `$ARGUMENTS` for the phase number. If not provided, use `AskUserQuestion`: "Which phase number should I validate?"

1a. Verify the target phase shows dev Status as COMPLETE in pipeline-state.md
    (if exists). If dev is still IN PROGRESS, stop: "Phase {N} dev is not
    complete. Run /dev {N} first."

1b. Read `pipeline-state.md` at project root. If it exists and "Last Skill" is "qa":
    - Present resume summary via `AskUserQuestion`: "Pipeline state shows qa was last active on Phase {N}. Resume or restart qa for Phase {N}?"
    - If user chooses Resume AND `qa-plan-phase-{NN}.md` exists at project root: use existing plan, skip to the last incomplete stage
    - If user chooses Resume BUT `qa-plan-phase-{NN}.md` does NOT exist: STOP with: "Cannot resume — plan file `qa-plan-phase-{NN}.md` not found. Run `/qa {N}` to restart."
    - If user chooses Restart: proceed normally
    If `pipeline-state.md` does not exist or "Last Skill" is not "qa", proceed normally.
    See `~/.claude/skills/_shared/references/pipeline-state-protocol.md` for full resume logic.

1c. **Plan file detection**: Check if `qa-plan-phase-{NN}.md` exists at the project root:
    - If exists AND not restarting (i.e., user did not choose "Restart" in step 1b): present via `AskUserQuestion`: "An existing qa plan file was found for Phase {N}. Use existing plan or regenerate?"
      - If user chooses "Use existing": skip to Stage 3 (User Approval) with the existing plan
      - If user chooses "Regenerate": proceed to Stage 2
    - If not exists: proceed to Stage 2

1d. **Complexity routing**: Determine validation depth:
    - Read key-learnings "Files Created/Modified" count
    - Check for UI files (`.tsx`, `.jsx`, `.vue`, `.svelte` components)
    - **Quick** (≤5 files AND no UI): Skip categories C/E/F in Stage 5. Minimum findings: 1.
    - **Full** (>5 files OR UI present): All categories, all stages. Minimum findings: 3.
    - Announce: "Mode: {Quick/Full} — {N} files, {UI/no UI}"

1e. **Project-type routing**: Detect project type from file extensions and structure, then adjust category weights:

    | Project Type | Detection | Category Adjustments |
    |-------------|-----------|---------------------|
    | Web app (UI) | `.tsx`/`.jsx`/`.vue`/`.svelte` in src/ | Full C/E/F, standard D |
    | API/backend | No UI files, has route handlers or server entry | Skip E/F, 2x B (endpoint contract tests, request/response shape validation), 2x D (auth/authz boundary tests) |
    | CLI tool | `bin/`, CLI entry point, no UI files | Skip C/E/F entirely, 2x B (arg parsing edge cases, error output formatting, exit code tests) |
    | Library/package | `exports` in package.json, no app entry | Skip C/E/F, 2x B (public API surface coverage, type export tests) |
    | Full-stack | Both UI files and API routes | All categories, add API-UI integration tests to C |

    If ambiguous, default to Web app (safest — includes all categories).
    Announce: "Project type: {type} — adjusting categories accordingly"

### Blocking Conditions
- Phase dev not COMPLETE → HALT
- Missing prerequisites → HALT

### Success: Phase number identified, dev completion verified, plan status determined.
### Failure: Phase incomplete or unresolvable resume state.

→ Present result. HALT. Wait for user before Stage 2.

### Stage 2: Planning via Subagent

Invoke the `qa-planner` subagent to perform heavy context loading, deep file analysis, and test plan generation in a fresh context window. This offloads ~1200-1700 lines of context from the main conversation.

1. **Pre-read system files** (subagents cannot read `~/.claude/` paths):
   - Read `~/.claude/agents/qa-planner.md` → `{planner_protocol}`
   - Read `~/.claude/skills/_shared/deep-knowledge.md` → `{patterns_content}` (use `"(not found)"` if absent)
   - Read `~/.claude/skills/qa/references/test-generation-protocol.md` → `{test_gen_content}`
   - Read `~/.claude/skills/qa/references/regression-and-coverage-strategy.md` → `{regression_content}`
   - Read `~/.claude/skills/qa/assets/test-plan-template.md` → `{plan_template}` (structural guide for plan output)

2. Invoke `qa-planner` subagent via the Task tool with:
   - `subagent_type`: `"general-purpose"`
   - `model`: `"opus"` (planning requires high reasoning)
   - Prompt: include the full planner protocol and all reference files inline (wrapped in XML tags: `<planner-protocol>`, `<deep-knowledge>`, `<test-generation-protocol>`, `<regression-strategy>`), provide the phase number and project root path, instruct the agent to skip reading these files from disk and use the provided content instead
   - The subagent reads phases.md, all key-learnings (target + prior), verifies dev completion, reads every phase file (project-local files it CAN access), performs code pattern analysis, and returns the plan content as text

3. After the subagent completes, write the returned content to `qa-plan-phase-{NN}.md` at the project root using the Write tool.
   - If the subagent returned no content or an error: STOP with: "Planning subagent failed to produce a plan. Retry `/qa {N}`."

4. Verify all required sections are present in the plan file. Check for these section headers:
   - `## Metadata`
   - `## Phase Scope`
   - `## Accumulated Context`
   - `## Phase File Analysis`
   - `## How This Differs From dev's Validation`
   - `## Category A: Regression Suite`
   - `## Category B: Functional Correctness`
   - `## Category C: Full User Journeys`
   - `## Category D: Security`
   - `## Category E: UI/UX Visual`
   - `## Category F: Accessibility`
   - `## Category G: Performance`
   - `## Category H: Convention Compliance`
   - `## Coverage Analysis`
   - `## Blockers`
   If any section is missing: STOP with: "qa plan file incomplete. Missing sections: {list}. Retry `/qa {N}`."

5. **Check Blockers section**: If the plan file contains any blockers (not "None"), STOP and present each blocker to the user. Do not proceed until all blockers are resolved.

6. Present a lightweight initialization summary from the plan file's Metadata section:
   ```
   qa Validation: Phase {N} — {Phase Title}
   Plan: qa-plan-phase-{NN}.md
   Total tests: {count} (P0: {count}, P1: {count}, P2: {count})
   Key-learnings loaded: {count} files
   ```

Present the complete test plan to the user.

### Blocking Conditions
- Subagent returns no content → HALT
- Plan file missing required sections → HALT

### Success: Plan file written with all sections, no blockers, plan presented.
### Failure: Subagent failure or incomplete plan.

→ Present plan. HALT. Wait for user approval before Stage 3.

### Stage 3: User Approval

This is a hard gate — no tests run until explicit approval.

1. Wait for the user to approve the test plan from the plan file.

2. If the user provides feedback, incorporate changes and re-present. Update the plan file if changes are significant.

3. Once approved:
   - **Load task tools first**: Use `ToolSearch` with query `"select:TaskCreate,TaskUpdate,TaskList"` to load deferred task tracking tools. This is MANDATORY — these tools are not available until discovered.
   - Create `TaskCreate` entries organized by category (A through H)
   - Set the Regression task (Category A) as blocking all others — regression runs first
   - Mark Category A as ready to begin
   - Verify tasks are visible by calling `TaskList` — if empty, the tools were not loaded correctly

### Success: User explicitly approves test plan.
### Failure: User rejects plan — return to Stage 2.

→ HALT. Wait for explicit approval before Stage 4.

### Stage 4: Automated Test Execution

Load `references/regression-and-coverage-strategy.md`.

1. `TaskUpdate` Category A → `in_progress`
2. **Regression first**: Run all automated gates from ALL prior phases.
   - If any P0 regression fails (build, tsc, tests), STOP immediately. Present diagnostic. Do NOT proceed to new tests.
   - If a P1/P2 regression fails (formatting, linting), record it as a finding with appropriate severity but CONTINUE testing. Note the regression in the report's Category A results.
   - `TaskUpdate` Category A → `completed`

3. `TaskUpdate` Category B → `in_progress`
4. **New automated tests**: Run all automated tests from the approved plan.
   - Unit tests, build checks, security scans, static analysis, dependency audit
   - If a test fails, record the failure but CONTINUE — qa wants ALL problems, not just the first
   - `TaskUpdate` Category B → `completed`

5. `TaskUpdate` Category D → `in_progress`
6. **Security audit** (Category D): Invoke `security-auditor` subagent scoped to this phase's files:
   - Pre-read `~/.claude/agents/security-auditor.md`
   - Invoke via Task tool with `subagent_type: "general-purpose"`, `model: "sonnet"`
   - Scope to files from this phase's key-learnings "Files Created/Modified"
   - CRITICAL/HIGH findings become P0 for the qa verdict
   - `TaskUpdate` Category D → `completed`

7. Present automated results table:
   ```
   | Test ID | Category | Priority | Result | Evidence |
   |---------|----------|----------|--------|----------|
   | A-01 | Regression | P0 | PASS | Exit code 0 |
   | B-03 | Functional | P0 | FAIL | TypeError at src/lib/auth.ts:42 |
   | D-01 | Security | P0 | PASS | No CRITICAL/HIGH findings |
   ```

### Blocking Conditions
- P0 regression failure → HALT immediately
- 3 consecutive infrastructure failures → HALT with diagnostic

### Success: All automated tests executed, results recorded.
### Failure: P0 regression failure blocks all further testing.

→ Present automated results. Continue to Stage 5.

### Stage 5: Interactive/Visual Testing (Category Isolation)

High-context categories (C, E, F) run in `category-executor` subagents to isolate Playwright context from the main conversation. Low-context categories run directly.

**Category isolation decision:**

| Category | Context Cost | Execution |
|----------|-------------|-----------|
| A: Regression | Low | Orchestrator direct (already done in Stage 4) |
| B: Functional | Medium | Direct if <10 tests, subagent if >10 |
| C: User Journeys | **High** | **category-executor subagent** |
| D: Security | Medium | Orchestrator direct (already done in Stage 4) |
| E: UI/UX Visual | **High** | **category-executor subagent** |
| F: Accessibility | **High** | **category-executor subagent** |
| G: Performance | Low | Orchestrator direct |
| H: Convention | Low | Orchestrator direct (Grep) |

**For subagent categories (C, E, F):**

1. Pre-read `~/.claude/agents/category-executor.md` (once, at stage start)
2. For each high-context category:
   - `TaskUpdate` this category → `in_progress`
   - Invoke category-executor via Task tool:
     - `subagent_type`: `"general-purpose"`
     - `model`: `"sonnet"`
     - Prompt: include category tests from qa plan, project context, conventions, dev server info
   - Collect results from subagent
   - `TaskUpdate` this category → `completed`
3. If a subagent fails/crashes: retry once, then mark category as INCOMPLETE in report

**For direct categories (B if <10 tests, G, H):**

Using Playwright MCP tools and static analysis:

1. `TaskUpdate` Category G → `in_progress`
2. **Performance** (G): Bundle size, console errors, network audit
3. `TaskUpdate` Category G → `completed`
4. `TaskUpdate` Category H → `in_progress`
5. **Convention compliance** (H): Grep for convention patterns from plan
6. `TaskUpdate` Category H → `completed`

5. **Console/network monitoring**: `browser_console_messages` and `browser_network_requests` during all testing. Flag errors (P0) and warnings (P2).

6. Capture evidence for every finding — screenshots with descriptive filenames.

### Success: All categories executed (direct or via subagent), results collected.
### Failure: Dev server unavailable or Playwright MCP not available — note limitations in report.

### Stage 6: Adversarial Code Review

Load `references/adversarial-review-protocol.md`.

Four-pass structure:

1. **Convention Audit**: For each convention/pattern from **the plan file's "Conventions to Verify" and "Patterns to Verify" tables** in the Accumulated Context section, Grep to verify compliance. Document every violation with file:line.

2. **Code Quality Review** (minimum 3 findings, target 5-10): Error handling, type safety, resource cleanup, race conditions, edge case handling, security, dead code, documentation accuracy.

3. **Key-Learnings Accuracy Verification**: For every claim in key-learnings, verify against actual codebase. Flag inaccuracies.

4. **Cross-Phase Integrity Check**: Verify files from prior phases weren't silently modified, imports resolve, shared types compatible.

5. **Steal compliance audit** (when phases.md tasks reference steal items): For each
   task with a `Steal:` block in phases.md:
   - Read the referenced steal-doc section
   - For each Preserve directive: verify the implementation matches exactly
     (constants, formulas, field names, API signatures)
   - For each Verify line: confirm the stated integration check holds
   - Classify deviations:
     - CRITICAL: Preserve directive violated (wrong constant, missing field, different algorithm)
     - MEDIUM: Verify line not satisfied (integration gap)
     - LOW: Implementation works but uses different naming than steal doc
   If no steal items referenced in this phase: skip this pass.

Classify findings: CRITICAL / MEDIUM / LOW.

### Success: All review passes completed (4 standard + steal compliance if applicable), minimum 3 findings documented.
### Failure: Unable to complete review passes.

### Stage 7: Results & Key-Learnings Update

0. Update `pipeline-state.md` (if it exists): set qa Status for this phase to the verdict (PASS/CONDITIONAL PASS/FAIL), set Active Task to "none", set Next Action based on verdict (PASS: "Run /dev {N+1} to begin next phase" or "Run /deploy to release" if last phase; CONDITIONAL PASS: "Review non-blocking issues, then /dev {N+1}" or "Review non-blocking issues, then /deploy" if last phase; FAIL: "Run /fix to address qa failures"), set Last Updated to current timestamp, set Last Skill to "qa".

1. Compile all results into qa report using `assets/qa-report-template.md`. The report MUST include ALL of these sections with EXACT headers:

   **CRITICAL**: The report header MUST use the EXACT metadata table format from
   the template (`assets/qa-report-template.md` lines 1-14). This means:
   - A markdown table with `| Field | Value |` columns
   - Field names EXACTLY as shown: "Phase", "Phase Title", "Date", "**qa Result**",
     "Total Tests", "Passed", "Failed", "Skipped", "Code Review Findings"
   - Do NOT use paragraph format, do NOT rename fields (e.g., "Verdict" instead
     of "qa Result", "Title" instead of "Phase Title", "qa Date" instead of "Date")
   - Do NOT skip the metadata table and jump directly to Executive Summary
   - `## Executive Summary` — 2-3 sentences summarizing result, key findings, verdict rationale
   - `## Test Results by Category` — Categories A through H with per-test tables
   - `## Code Review Findings` — Severity table with file:line references
   - `## Key-Learnings Corrections` — Table or "No inaccuracies found"
   - `## Blocking Issues` — "No blocking issues." for PASS, or P0 failures/CRITICAL findings for FAIL
   - `## Recommendations` — Three subsections: `### Must Fix`, `### Should Fix`, `### Consider`
   - `## Test Coverage Summary` — Per-category counts table

2. Calculate verdict:
   - **PASS**: All P0 pass, no CRITICAL findings, regression green
   - **CONDITIONAL PASS**: All P0 pass, but P1 failures or MEDIUM findings exist
   - **FAIL**: Any P0 fails, OR any CRITICAL finding, OR regression failure

3. Write qa report to `qa-reports/qa-report-phase-{NN}.md` (create directory if needed).

4. Update key-learnings by appending "qa Notes" section to `key-learnings/key-learnings-{NN}.md`:

   ```markdown
   ## qa Notes (added by qa)

   ### Validation Date
   {YYYY-MM-DD}

   ### qa Result
   {PASS / CONDITIONAL PASS / FAIL}

   ### Issues Found
   | Issue | Severity | Category | Evidence | Resolution |
   |-------|----------|----------|----------|------------|

   ### Test Coverage Summary
   | Category | Tests | Passed | Failed | Skipped |
   |----------|-------|--------|--------|---------|

   ### Key-Learnings Corrections
   | Section | Claimed | Actual | Corrected |
   |---------|---------|--------|-----------|

   ### Verified
   - [ ] All P0 tests pass
   - [ ] Regression suite green
   - [ ] Conventions from key-learnings followed
   - [ ] Security audit clean
   - [ ] Accessibility audit clean
   - [ ] Key-learnings file is accurate and complete
   ```

   **CRITICAL**: Use the EXACT header `## qa Notes (added by qa)` — do not vary this (e.g., do not use `## qa Notes (Phase N)` or `## qa Notes`). This header is how dev agents locate qa feedback in subsequent phases.

5. If qa found key-learnings inaccuracies, correct the relevant sections AND document corrections in the table above.

5a. **Update README.md**: If `README.md` exists at project root and post-qa fixes changed user-facing behavior or capabilities, update it to reflect those changes. If no user-facing changes occurred (only internal fixes or pipeline file updates), skip this step. No AI attribution in the README.

5b. **Git commit**: If any project files were modified during qa (post-qa code fixes, code-level key-learnings corrections), stage and commit them:
   - Stage all modified project files that are not gitignored (code fixes only — pipeline files like qa reports and key-learnings are globally gitignored)
   - Write a concise commit message describing the fixes (e.g., "fix qa phase 2 findings: ALS recovery, expression state priority"). No AI attribution — no `Co-Authored-By`, no "generated by", no AI emoji, no AI references.
   - Do NOT push to remote unless the user explicitly requests it
   - If no project files were modified (only gitignored pipeline files changed), skip the commit

6. **Knowledge capture** (lightweight):
   - Read `~/.claude/skills/_shared/deep-knowledge.md` (if exists)
   - Check: did anything in this session contradict or extend a deep-knowledge entry?
   - If yes: append 1-2 lines to `~/.claude/skills/_shared/working-memory.md` under `## Signals`
   - If no: skip silently

7. Present final result with evidence and next steps:
   - If PASS: "Phase {N} validated. Run `/dev {N+1}` for next phase."
   - If CONDITIONAL PASS: "Phase {N} conditionally passes. {count} non-blocking issues found. Fix recommended before proceeding."
   - If FAIL: "Phase {N} FAILS qa. {count} blocking issues. Run `/fix` to address failures, then re-run `/qa {N}`."

**Note**: The plan file (`qa-plan-phase-{NN}.md`) may be kept for reference or deleted at the user's discretion. It is not required by downstream skills.

---

## Important Rules

1. **Never skip regression.** All prior phase gates run first, every time. No shortcuts.

2. **Never pass with P0 failures.** A single P0 failure means FAIL, regardless of how many other tests pass.

3. **Always find something.** Minimum 3 findings across all severities for normal phases, minimum 1 for Phase 0. This is a forcing function to look harder, not permission to fabricate.

4. **Evidence for every finding.** Screenshot, error output, file:line, or command output. No unsupported claims.

5. **One phase per invocation.** Each `/qa {N}` validates exactly one phase. Do not cascade.

6. **Never fix code unprompted.** qa reports defects; it does not fix them. After presenting the qa report, if the user explicitly requests fixes, qa may apply them and document all changes in a `## Post-qa Fixes Applied` section appended to the report. Re-run affected validation gates after fixes to confirm no regressions.

7. **Never rubber-stamp.** Re-running dev's gates verbatim is not qa. Every test must add value beyond what dev already verified.

8. **Key-learnings corrections are mandatory.** If qa finds that key-learnings claims don't match reality, correct them. Accuracy is non-negotiable.

9. **Never suggest how to fix defects.** Report the problem with evidence (file:line, screenshot, error output). The fix is dev's domain. qa identifies *what* is broken, not *how* to repair it.

10. **Never soften findings to be diplomatic.** A bug is a bug. Report severity accurately. Downgrading a P0 to P1 to avoid confrontation undermines the entire qa process.

---

## When I Hit My Limits

1. Note the limitation in the report and work around it
2. For unknown vulnerability classes: invoke deep-researcher for current CVE/mitigation data
3. Mark affected findings as [UNVERIFIED] with the specific gap noted

---

## Reference Files

Load these files when the workflow reaches the relevant stage:

- `references/regression-and-coverage-strategy.md` — Regression execution order, coverage gap analysis, cross-phase testing. Load at **Stage 4**.
- `references/ui-ux-validation-protocol.md` — Visual, accessibility, behavioral, responsive testing via Playwright. Load at **Stage 5**.
- `references/adversarial-review-protocol.md` — Minimum findings policy, 8-dimension checklist, severity classification. Load at **Stage 6**.
- `references/blocking-conditions.md` — qa-specific STOP conditions. Load at **any stage** when a blocking condition is encountered.
- `~/.claude/skills/_shared/references/pipeline-state-protocol.md` — Pipeline state read/update rules and resume detection. Load at **Stage 1**.

**Subagents**:
- `qa-planner` (`~/.claude/agents/qa-planner.md`): Handles phase analysis and test plan generation at **Stage 2**. Model: opus.
- `category-executor` (`~/.claude/agents/category-executor.md`): Handles high-context test categories (C/E/F) at **Stage 5**. One invocation per category, fresh context each. Model: sonnet.
- `security-auditor` (`~/.claude/agents/security-auditor.md`): Handles security audit at **Stage 4** step 3. Scoped to phase files. Model: sonnet.

---

