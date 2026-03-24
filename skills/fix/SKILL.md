---
name: fix
description: "Medium-path implementation for bug fixes, qa findings, and targeted changes. Use this skill when the user says /fix, 'fix this', 'fix bug', 'patch this', 'fix qa findings', or wants to make a change scoped to ~15 files or fewer without full plan/dev/qa pipeline overhead. Provides triage with scope assessment, optional plan review, implementation with 3-strike rule, verification, and documentation."
argument-hint: <description-of-fix-or-qa-finding-reference>
---

# fix — Targeted Fix Engine

> **EXECUTABLE WORKFLOW** — not reference material. Execute stages in order.
> Do not skip stages. Do not proceed without user confirmation at gates.

Handle bug fixes, qa findings, config changes, and targeted improvements with appropriate ceremony based on scope. Replaces /hotfix with broader scope and adaptive workflow.

---

## How I Think

I think like a field surgeon: scope fast, root-cause precisely, fix with minimal
collateral, verify the fix didn't break adjacent tissue, document what happened.
My default is suspicion — if a fix "feels done" without verification, it isn't.
I respect scope boundaries absolutely because a fix that grows into a rewrite
causes more damage than the original bug.

---

## Workflow

**Entry**: Follow the Skill Entry Protocol:
1. Read pipeline-state.md (verify clean state)
2. Verify prerequisites (none required — /fix is always available)

### Stage 1: Triage

1. Parse `$ARGUMENTS` for the change description. If not provided, use `AskUserQuestion`: "What do you need to fix?"

2. Assess the scope:
   - Use `Glob` and `Grep` to identify files likely affected
   - Count the files that will need modification
   - Estimate complexity

3. **qa-fix context detection**:
   - If `$ARGUMENTS` references a qa report, qa findings, or finding IDs (e.g., "B-03", "fix qa phase 2 issues"):
     - Use `Glob` to find `qa-reports/qa-report-phase-*.md` files
     - Read the referenced qa report(s)
     - Map fix description to specific documented findings
   - Read relevant key-learnings files to understand established conventions

4. **Root Cause Hypothesis**:
   Read the code path that produces the bug (not just the file list). In 1-2 sentences:
   - What specific condition causes the observed behavior?
   - Is this a local issue (wrong logic in one function) or systemic (pattern used across codebase)?
   If the cause is unclear after reading the code path, flag as "Root cause unclear —
   investigation needed" and expand triage to trace the execution path.
   For Quick mode (1-3 files): 1 sentence is sufficient.
   For Standard mode (4-15 files): trace the full code path before planning.
   Load `references/root-cause-catalogs.md` and match the observed symptom to refine
   the hypothesis using the diagnostic procedures.

5. **Baseline Capture** (behavioral bugs only):
   If the bug is behavioral (wrong output, wrong UI state, wrong response):
   - Run the specific failing command/test and capture the current (broken) output
   - This baseline is used in Stage 4 to confirm the symptom is gone, not just that tests pass
   Skip for build errors, type errors, or crashes (the error message itself is the baseline).

6. **Scope assessment** — Classify the fix:

   | Size | Files | Mode | Process |
   |------|-------|------|---------|
   | Tiny | 1-3 | Quick | Triage → implement → verify (no plan review) |
   | Small-Medium | 4-15 | Standard | Triage → plan review → implement → verify → document |
   | Large | 15+ or architectural | Redirect | → `/plan` + `/dev` |

   For detailed file count edge cases, complexity classification, and qa-fix detection rules,
   load `references/triage-criteria.md`.

   Redirect conditions:
   - More than ~15 files need modification
   - A new dependency must be installed
   - The change requires architectural decisions (new patterns, new components, new API endpoints)
   - The change conflicts with an in-progress phase's scope in a way that can't be reconciled

   If redirecting:
   ```
   REDIRECT: This change exceeds /fix scope.

   Reason: {reason}

   Recommendation:
   - If this is rework of an existing phase: /dev {N} directly
   - Otherwise: /plan first, then /dev
   ```

5. Check for an active pipeline:
   - Look for `phases.md` at project root
   - If found, identify overlap with in-progress or future phases
   - If overlap exists, note it in the triage presentation

6. Present triage result:
   ```
   fix Triage: {brief description}

   Mode: {Quick (1-3 files) / Standard (4-15 files)}
   Affected files: {count} ({file list})
   Pipeline status: {Active — Phase N in progress / No active pipeline}
   {If qa-fix: "Addresses qa findings: {finding IDs}"}

   Proceed?
   ```

   Use `AskUserQuestion` with options: "Proceed", "Modify scope", "Cancel".

### Blocking Conditions
- Scope exceeds ~15 files → REDIRECT to /plan + /dev
- New dependency required → REDIRECT
- Architectural decisions needed → REDIRECT
- 3 consecutive verification failures → HALT with diagnostic

### Success: Scope classified, user confirms.
### Failure: User cancels or scope redirected.

→ HALT. Wait for user confirmation before Stage 2.

### Stage 2: Plan (Standard mode only)

Skip this stage for Quick mode (1-3 files).

1. Read every affected file completely. Understand the code before changing it.

2. Identify the exact changes needed:
   - Which lines in which files
   - What the current behavior is
   - What the desired behavior is
   - Which tests cover this code

3. Present implementation plan:
   ```
   Plan:

   1. In `{file}`: {change description}
   2. In `{file}`: {change description}

   Verification:
   - {commands to run}

   Expected result: {what success looks like}
   ```

4. Use `AskUserQuestion` for approval. Options: "Approve plan", "Modify plan", "Cancel".

### Success: Plan approved by user.
### Failure: User cancels or plan needs rework beyond 2 iterations.

→ HALT. Wait for user approval before Stage 3.

### Stage 3: Implement

1. Make the code changes. For Quick mode, read affected files first, then implement.

   **Quick mode proportionality**: Fix the SPECIFIC reported symptom with the MINIMUM
   code change. Do not add input validation, type guards, error handling, or defensive
   checks beyond what's needed to prevent the exact crash/bug described. If the surrounding
   code has other issues (code smells, missing types, unused imports), leave them alone —
   those are separate fixes.

2. Run verification in order:
   a. **Build**: Run the project's build command
   b. **Typecheck**: Run typecheck if applicable (e.g., `npx tsc --noEmit`)
   c. **Tests**: Run affected tests (specific files if identifiable, full suite if unsure)
   d. **Visual check** (if UI-facing and Playwright MCP available): Quick browser verification

3. **Three-strike rule**: If any verification step fails:
   - Attempt 1: Analyze the failure, fix, re-run
   - Attempt 2: Different approach, re-run
   - Attempt 3: STOP and present the issue:
     ```
     BLOCKED: Verification failed 3 times

     Change: {what was changed}
     Failing check: {which verification step}
     Error: {error output}

     Attempts:
     1. {what was tried} → {result}
     2. {what was tried} → {result}
     3. {what was tried} → {result}

     Requesting guidance.
     ```

4. **Scope creep detection**: If file count grows >50% beyond the triage assessment, re-present triage:
   ```
   Scope creep detected: triage estimated {N} files, now at {M} files.
   Continue with /fix or redirect to /plan + /dev?
   ```

5. After all verifications pass, confirm:
   ```
   Verification:
   - Build: PASS
   - Typecheck: PASS
   - Tests: PASS ({N} tests, {N} passed)
   ```

### Success: All verifications pass.
### Failure: 3-strike rule triggered or scope creep redirected.

→ Present result. HALT. Wait for user before Stage 4.

### Stage 4: Verify

If an active pipeline was detected in Stage 1, load `references/pipeline-integration.md`
for the key-learnings update protocol.

Adversarial verification scaled by mode:

**Quick mode (1-3 files)**: Symptom verification only:
- Re-test the specific bug. For behavioral bugs: compare output against the Stage 1 baseline.
- For crashes/errors: confirm the specific error no longer occurs.
- If the symptom persists → return to Stage 3.

**Standard mode (4-15 files)**: Full three-part adversarial verification:

1. **Symptom verification**: Same as Quick mode above.

2. **Regression scope**: Identify what else the changed files affect.
   - For each modified file: what other modules import/call it?
   - Run tests for those adjacent modules, not just the directly-affected tests.
   - If the changed file is a shared utility, middleware, or type definition: run the full test suite.

3. **Root cause confirmation**: Does the fix address the root cause from Stage 1, not just the symptom?
   - Re-read the root cause hypothesis. Does the code change directly address it?
   - If the fix patches around the root cause (workaround), note this in the fix-log entry.

### Success: Symptom gone + no regressions + root cause addressed (or workaround documented).
### Failure: Symptom persists, regression found, or root cause unaddressed without documentation.

→ Present result. HALT. Wait for user before Stage 5.

### Stage 5: Document

1. Append to `fix-log.md` at the project root (create if not exists):

   ```markdown
   ### {YYYY-MM-DD} — {brief description}

   **Mode:** {Quick / Standard}
   **Files changed:**
   - `{file path}`: {what changed}

   **Verification:** Build PASS | Typecheck PASS | Tests PASS ({N}/{N})

   **Context:** {Why this change was needed. One sentence.}
   {If qa-fix: "**Addresses:** {finding IDs from qa report}"}
   ```

2. Update `pipeline-state.md` (if it exists):
   - Append to the Hotfixes Since Last Deploy table with date, description, files changed
   - Update Last Updated timestamp
   - Set Last Skill to "fix"

3. **Working-memory signal**: If `~/.claude/skills/_shared/working-memory.md` exists, append under `## Signals`:
   ```markdown
   ### {YYYY-MM-DD} fix: {1-line summary}
   {mode}, {file count} files, {area}. {Root cause if notable.}
   ```

4. If an active pipeline exists and the fix touches files relevant to a phase:
   - Read the relevant `key-learnings/key-learnings-{NN}.md`
   - Append a `## Fix Notes` section:
     ```markdown
     ## Fix Notes

     ### {YYYY-MM-DD}: {brief description}
     - Changed `{file}`: {what changed and why}
     - Impact on this phase: {what the phase implementor needs to know}
     ```

5. **Knowledge capture** (lightweight):
   - Read `~/.claude/skills/_shared/deep-knowledge.md` (if exists)
   - If the fix revealed a pattern or anti-pattern worth tracking, append 1-2 lines to `working-memory.md` under `## Signals`
   - If nothing novel: skip silently

6. Present completion summary:
   ```
   fix Complete: {brief description}

   Files changed: {count}
   Verification: All checks pass
   Logged: fix-log.md
   Pipeline notes: {Updated key-learnings-{NN}.md / No active pipeline}

   Next steps:
   - /qa {N} to re-validate (if qa findings were fixed)
   - Continue development
   ```

### Success: fix-log.md updated, pipeline state current, completion summary presented.
### Failure: Unable to write documentation files.

---

## Important Rules

1. **Never exceed ~15 files.** If the fix grows beyond scope during implementation, STOP and offer redirect. Do not expand silently.

2. **Never skip verification.** Every fix runs build + typecheck + tests. No exceptions.

3. **Never skip documentation.** Every fix gets a `fix-log.md` entry. The log is the audit trail.

4. **Never modify phases.md directly.** If a fix affects phased work, document in key-learnings, not phases.md. Phases.md is owned by /plan.

5. **Never install new dependencies.** If the fix requires a new package, redirect to `/plan`.

6. **One fix per invocation.** Each `/fix` handles one change. For multiple fixes, invoke separately.

---

## Reference Files

- `references/triage-criteria.md` — File count edge cases, complexity classification, qa-fix detection. Load at **Stage 1**.
- `references/root-cause-catalogs.md` — Symptom-organized diagnostic procedures. Load at **Stage 1** step 4.
- `references/pipeline-integration.md` — Key-learnings update protocol for active pipelines. Load at **Stage 4**.
