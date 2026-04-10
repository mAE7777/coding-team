---
name: dev
description: "Implement a specific phase from phases.md with plan-first development. Use this skill when the user says /dev, 'implement phase', 'start phase N', 'develop phase', or wants to execute a development phase from a phases.md file. Reads key-learnings, plans in plan mode, then implements task by task with validation gates and creates key-learnings on completion."
argument-hint: <phase-number>
---

# dev — Phase Implementation Engine

> **EXECUTABLE WORKFLOW** — not reference material. Execute stages in order.
> Do not skip stages. Do not proceed without user confirmation at gates.

Read a phase from `phases.md`, absorb prior key-learnings, plan the implementation, then execute tasks sequentially with validation gates. Create key-learnings on completion to maintain cross-phase consistency.

---

## Core Principles

1. **Plan Before Code**: Explore the codebase and design the approach before writing a single line. Every task gets a concrete implementation plan before execution begins.

2. **Faithfulness to phases.md**: Implement what the phase specifies — nothing more, nothing less. The phase scope is the contract. Do not add features, refactor unrelated code, or "improve" things outside scope.

3. **Key-Learnings Supremacy**: When key-learnings contradict `phases.md`, key-learnings win. They reflect actual implementation reality. Follow established conventions and patterns from prior phases.

4. **Sequential Discipline**: One task at a time, fully verified against its acceptance criteria before moving on. Never start Task N+1 while Task N has unverified ACs.

5. **Transparent Progress**: Use `TaskCreate` and `TaskUpdate` for every task so the user sees real-time status. Announce starts, report completions, show running tallies.

6. **User Authority**: Never make architectural decisions silently. Use `AskUserQuestion` for ambiguities, unspecified choices, and scope questions. The user decides; you implement.

7. **Fail Loud**: STOP on blocking conditions. Never push through ambiguity, never guess at missing configuration, never silently swallow errors.

---

## Workflow

**Entry**: Follow the Skill Entry Protocol:
1. Read pipeline-state.md (verify clean state)
2. Verify prerequisites

### Stage 1: Initialization (Lightweight)

1. Parse `$ARGUMENTS` for the phase number. If not provided, use `AskUserQuestion`: "Which phase number should I implement?"

1b. Read `pipeline-state.md` at project root. If it exists and "Last Skill" is "dev":
    - Present resume summary via `AskUserQuestion`: "Pipeline state shows dev was last active on Phase {N}, Task {N.M}. Resume from Task {N.M} or restart Phase {N}?"
    - If user chooses Resume AND `dev-plan-phase-{NN}.md` exists at project root: use existing plan, skip to the recorded task in Stage 4
    - If user chooses Resume BUT `dev-plan-phase-{NN}.md` does NOT exist: STOP with: "Cannot resume — plan file `dev-plan-phase-{NN}.md` not found. Run `/dev {N}` to restart the phase."
    - If user chooses Restart: proceed normally
    If `pipeline-state.md` does not exist or "Last Skill" is not "dev", proceed normally.
    See `~/.claude/skills/_shared/references/pipeline-state-protocol.md` for full resume logic.

1c. Verify phases.md exists and key-learnings directory is present. If
    pipeline-state.md shows a phase this one depends on is still IN PROGRESS,
    stop and alert the user.

1c2. **Testing strategy detection**: Check if phases.md contains a `## Project Strategy`
    section. If present, extract:
    - Testing Archetype (A/B/C/D)
    - Verification Mode (per-phase/incremental)
    - Max Task Duration
    - AI Feature Inventory (if present)
    Store these as `{project_strategy}` for use in Stage 4. If verification mode
    is `incremental`, announce: "Incremental verification mode — each task will include
    its own verification step before proceeding." If not present, default to
    Archetype A / per-phase verification.

1d. **Complexity routing**: Determine whether this phase uses the Quick, Standard, or Deep planning tier. Compute a complexity score from 4 mechanical signals:

    ```
    +1 if task count in this phase ≥ 4
    +1 if total file count across all tasks ≥ 8
    +1 if ANY task title or AC contains HIGH sensitivity keywords
       (auth, token, password, session, permission, role, encrypt, decrypt,
        payment, billing, delete, migrate, secret, credential, CORS)
    +1 if key-learnings/ directory contains ≥ 3 files
    ```

    **Routing**: Score 0–1 → **Quick** | Score 2 → **Standard** | Score 3–4 → **Deep**

    Announce the tier to the user: "Complexity score: {score}/4 → {Quick|Standard|Deep} tier"

    To compute:
    - Count tasks: parse the target phase section in phases.md, count `- [ ]` and `- [x]` items
    - Count files: sum all file paths listed across task definitions in this phase
    - Scan keywords: check each task title + AC text against the HIGH sensitivity list (same list used by Stage 4 step 4 sensitivity classification)
    - Count key-learnings: Glob `key-learnings/key-learnings-*.md` at project root

1e. **Plan file detection**: Check if `dev-plan-phase-{NN}.md` exists at the project root:
    - If exists AND not restarting (i.e., user did not choose "Restart" in step 1b): present via `AskUserQuestion`: "An existing plan file was found for Phase {N}. Use existing plan or regenerate?"
      - If user chooses "Use existing": skip to Stage 3 (User Approval) with the existing plan
      - If user chooses "Regenerate": proceed to Stage 2
    - If not exists: proceed to Stage 2

### Blocking Conditions
- phases.md not found → HALT
- Dependent phase still IN PROGRESS → HALT
- Missing prerequisites → HALT and suggest correct skill

### Success: Phase number identified, prerequisites verified, plan file status determined.
### Failure: Missing prerequisites or unresolvable resume state.

→ Present result. HALT. Wait for user before Stage 2.

### Stage 2Q: Quick Planning (Inline)

**Condition**: Execute this stage when complexity tier = **Quick** (from Stage 1d). If tier = **Standard** or **Deep**, skip to Stage 2.

Quick Planning runs inline — no subagent spawn, no three-pass codebase exploration. The savings come from convention inheritance (from prior key-learnings) instead of fresh scanning.

1. **Read target phase** from phases.md (already identified in Stage 1). Extract all task definitions, ACs, file lists, and notes.

2. **Read prior key-learnings** (if any): Glob `key-learnings/key-learnings-*.md` at project root. For each file, extract:
   - Conventions Established → carry forward as conventions
   - Patterns Established → carry forward as patterns
   - Architecture Decisions Made → carry forward as accumulated context
   - Issues Encountered & Resolutions → carry forward as warnings
   - **Cross-phase synthesis**: Note recurring signals across multiple key-learnings files — repeated issue types, common gate failure categories, task sizing patterns (phases that needed splitting). Include as `## Cross-Phase Patterns` in the plan file's Accumulated Context section.

3. **Quick file inventory**: For each file path listed across all tasks in this phase:
   - Glob to check existence → classify as EXISTS or TO_CREATE
   - Skip dependency tracing (Pass 2) and convention scanning (Pass 3) — these are Standard-tier operations

4. **Inherit conventions**: Use conventions extracted from prior key-learnings directly. Do not perform a fresh codebase convention scan. If no prior key-learnings exist, note "No prior conventions — first phase" in the plan.

4b. **Apply modifiers**: For each modifier in the `modifiers list`:
    - REVIEW: add named review step in Per-Task Implementation Plan for affected tasks
    - GATE: add validation gate entry
    - TRUST: note "No explicit review — trusted capability" in affected task risks

5. **Write plan file** to `dev-plan-phase-{NN}.md` at the project root with all 11 required sections:
   - `## Metadata` — phase number, title, task count, tier: Quick
   - `## Phase Scope` — from phases.md
   - `## Accumulated Context` — inherited from prior key-learnings
   - `## File Inventory` — EXISTS/TO_CREATE from step 3
   - `## Convention Scan Results` — "Inherited from prior key-learnings (Quick tier — no fresh scan)"
   - `## Execution Order` — task sequence from phases.md
   - `## Per-Task Implementation Plan` — strategy + files + ACs per task (risks section: "None identified — Quick tier")
   - `## Validation Gates` — from phases.md
   - `## Open Questions` — "None" unless ambiguities found during reading
   - `## New Dependencies Required` — from phases.md or "None"
   - `## Blockers` — "None" unless blocking issues found

6. **Verify sections**: Check all 11 section headers are present. If any missing: fix inline before continuing.

7. **Check Blockers / Open Questions / Dependencies**: Same checks as Stage 2 steps 5-7.

8. **Present initialization summary** (same format as Stage 2 step 8):
   ```
   Phase {N}: {Phase Title} (Quick tier)
   Plan: dev-plan-phase-{NN}.md
   Tasks: {count}
   Validation gates: {count}
   Key-learnings loaded: {count} files
   ```

Present the implementation plan (Execution Order + Per-Task Implementation Plan sections) to the user.

### Blocking Conditions
- Plan file missing required sections → HALT (fix inline)
- Unresolved blockers in plan → HALT

### Success: Plan file written with all sections, no unresolved blockers, plan presented to user.
### Failure: Blocking issue found during quick planning.

→ Present plan. HALT. Wait for user approval before Stage 3.

### Stage 2: Planning via Subagent

**Condition**: Execute this stage when complexity tier = **Standard** or **Deep** (from Stage 1d). If tier = **Quick**, Stage 2Q above was already executed — skip to Stage 3.

Invoke the `dev-planner` subagent to perform heavy context loading, codebase exploration, and implementation planning in a fresh context window. This offloads ~1200-1700 lines of context from the main conversation.

1. **Pre-read system files** (subagents cannot read `~/.claude/` paths):
   - Read `~/.claude/agents/dev-planner.md` → `{planner_protocol}`
   - Read `~/.claude/skills/_shared/deep-knowledge.md` → `{patterns_content}` (use `"(not found)"` if absent)
   - Read `~/.claude/skills/dev/references/plan-mode-protocol.md` → `{plan_mode_content}`
   - If `phases.md` → `## Project Strategy` contains a `Stack Pack:` field (e.g., `stacks/rust.md`), read the referenced file at `~/.claude/skills/_shared/references/stacks/{name}.md` → `{stack_content}` (use `"(not found)"` if absent or file doesn't exist)

2. Invoke `dev-planner` subagent via the Task tool with:
   - `subagent_type`: `"general-purpose"`
   - `model`: `"opus"` (planning requires high reasoning)
   - Prompt: include the full planner protocol and reference files inline (wrapped in XML tags: `<planner-protocol>`, `<deep-knowledge>`, `<plan-mode-protocol>`, and `<stack-knowledge>` if stack pack was loaded), provide the phase number and project root path, instruct the agent to skip reading these files from disk and use the provided content instead. The stack knowledge provides language-specific conventions, safety patterns, and anti-patterns that should be applied as additional constraints during convention scanning and task planning
   - The subagent reads phases.md, all prior key-learnings (project-local files it CAN access), performs three-pass codebase exploration, synthesizes cross-phase patterns from key-learnings, and returns the plan content as text

3. After the subagent completes, write the returned content to `dev-plan-phase-{NN}.md` at the project root using the Write tool.
   - If the subagent returned no content or an error: STOP with: "Planning subagent failed to produce a plan. Retry `/dev {N}`."

4. Verify all required sections are present in the plan file. Check for these section headers:
   - `## Metadata`
   - `## Phase Scope`
   - `## Accumulated Context`
   - `## File Inventory`
   - `## Convention Scan Results`
   - `## Execution Order`
   - `## Per-Task Implementation Plan`
   - `## Validation Gates`
   - `## Open Questions`
   - `## New Dependencies Required`
   - `## Blockers`
   If any section is missing: STOP with: "Plan file incomplete. Missing sections: {list}. Retry `/dev {N}`."

   If tier = **Deep**: also verify `## Risk Mitigations` exists (12 sections total). If missing, instruct dev-planner to include risk mitigation strategies for HIGH-sensitivity tasks.

5. **Check Blockers section**: If the plan file contains any blockers (not "None"), STOP and present each blocker to the user. Do not proceed until all blockers are resolved.

6. **Check Open Questions section**: If the plan file contains open questions (not "None"), batch all questions into a single `AskUserQuestion` call. Wait for user answers before proceeding.

7. **Check New Dependencies Required section**: If new dependencies are listed, present them to the user for approval. Do not install until approved.

8. Present a lightweight initialization summary from the plan file's Metadata section:
   ```
   Phase {N}: {Phase Title}
   Plan: dev-plan-phase-{NN}.md
   Tasks: {count}
   Validation gates: {count}
   Key-learnings loaded: {count} files
   ```

Present the implementation plan (Execution Order + Per-Task Implementation Plan sections) to the user.

### Blocking Conditions
- Subagent returns no content → HALT
- Plan file missing required sections → HALT
- Unresolved blockers in plan → HALT

### Success: Plan file written with all sections, no unresolved blockers, plan presented to user.
### Failure: Subagent failure or incomplete plan.

→ Present plan. HALT. Wait for user approval before Stage 3.

### Stage 3: User Approval

This is a hard gate — no code is written until explicit approval.

1. Wait for the user to approve the implementation plan from the plan file.

2. If the user provides feedback, incorporate changes into the plan and re-present the updated plan. Update the plan file if changes are significant.

3. Once approved:
   - **Load task tools first**: Use `ToolSearch` with query `"select:TaskCreate,TaskUpdate,TaskList"` to load deferred task tracking tools. This is MANDATORY — these tools are not available until discovered.
   - Create `TaskCreate` entries for all tasks, validation gates, and key-learnings creation
   - Set up task dependencies using `addBlockedBy` so they reflect the execution order
   - Mark the first task as ready to begin
   - Verify tasks are visible by calling `TaskList` — if empty, the tools were not loaded correctly

### Success: User explicitly approves plan.
### Failure: User rejects plan — return to Stage 2 for replanning.

→ HALT. Wait for explicit approval before Stage 4.

### Stage 4: Sequential Task Execution (Orchestrator Pattern)

Each task runs in a fresh `task-implementer` subagent with its own context window. The orchestrator (this conversation) manages task flow, collects results, and maintains state. This prevents implementation details from accumulating in the main context.

0a. **Port awareness**: If `pipeline-state.md` contains a `Dev Port` field, include port info in task-spec notes. Before the first task:
   - Run `lsof -i :{port}` via Bash to check if the port is available
   - If occupied: warn user and resolve before proceeding
   - If `pipeline-state.md` has no `Dev Port` field: skip this step

0b. **Pre-read for subagent context**:
   - Read `~/.claude/skills/_shared/deep-knowledge.md` → `{deep_knowledge}` (use `"(not found)"` if absent)
   - If phases.md `## Project Strategy` contains a `Stack Pack:` field, read the referenced file at `~/.claude/skills/_shared/references/stacks/{name}.md` → `{stack_knowledge}` (use `"(not found)"` if absent or file doesn't exist)
   - Extract the Accumulated Context section from the plan file → `{conventions}`

0c. Initialize accumulated task summaries: `prior_tasks = ""`

For each task in the approved order:

1. `TaskUpdate` → `in_progress`
2. Announce: "Starting Task {N}.{M}: {title}"
3. Update `pipeline-state.md` (if it exists): set Active Task to "{N}.{M}", set Last Updated, set Last Skill to "dev".

4. **Build task-spec** from phases.md:
   - Re-read task details: title, ACs (Given/When/Then), files, notes
   - Scan for `[UNVERIFIED]` markers. If found: resolve with user via `AskUserQuestion` BEFORE spawning subagent. Never pass unverified items to a subagent without flagging them.
     If the user also cannot resolve the item: continue with the task, marking the task-spec item as `[UNVERIFIED — unresolved]`. This is not a blocking condition.
   - **Sensitivity Classification**: Scan the task title, ACs, and notes for indicators:
     - HIGH: auth, token, password, session, permission, role, encrypt, decrypt,
       payment, billing, delete (destructive), migrate (data), secret, credential, CORS
     - NORMAL: everything else
     If HIGH: add `sensitivity: HIGH` to the task-spec XML. This triggers the
     task-implementer's enhanced verification protocol (negative case testing,
     security-aware quality checks). Load `references/sensitivity-heuristics.md`
     and include the matching domain row in the task-spec as verification checklist.
   - **Modifier overlay**: Check the `modifiers list` for modifiers intersecting this task. If REVIEW: add to task-spec notes — "Modifier: verify {area} explicitly after implementation." If GATE: add — "Modifier: flag {area} decisions for user review before marking complete."
   - **Testing strategy overlay**: If `{project_strategy}` indicates incremental verification (Archetype B or C):
     - Add to task-spec notes: `verification-mode: incremental`
     - For Archetype B (Hardware): add "After implementation, flash/deploy and verify on hardware before marking complete"
     - For Archetype C (Perception): add "After implementation, perform visual/auditory review before marking complete"
     - These tasks return REQUIRES_VERIFICATION instead of COMPLETE, triggering orchestrator step 6c
   - **AI task annotation**: If `{project_strategy}` has an AI Feature Inventory and this task implements an AI feature, add the tier classification and guard mechanism to task-spec notes: `ai-output-tier: {N}, guard: {mechanism}`
   - **Steal constraints extraction**: If the task notes contain a `Steal:` block
     (from phases.md), read the referenced steal-doc section (e.g., `steal-memory.md §3.2`).
     Include in the task-spec XML as `<steal-constraints>` with:
     - The full text of the referenced steal-doc section
     - All Preserve directives from the Steal block
     - All Verify lines from the Steal block
     - Instruction: "Implementation MUST match Preserve directives exactly. Verify lines
       are acceptance criteria — check each one before reporting COMPLETE."

5. **Spawn task-implementer subagent** via Task tool:
   - `subagent_type`: `"general-purpose"`
   - `model`: `"sonnet"` (cost-efficient for focused execution)
   - Prompt includes all context in XML tags:
     ```
     <task-spec>{task title, ACs, files, notes, unverified items}</task-spec>
     <conventions>{from plan file Accumulated Context}</conventions>
     <prior-tasks>{accumulated 1-line summaries from completed tasks}</prior-tasks>
     <deep-knowledge>{pre-read content}</deep-knowledge>
     <stack-knowledge>{stack pack content if loaded, omit tag entirely if not}</stack-knowledge>
     ```
   - If `{stack_knowledge}` was loaded: instruct the task-implementer to treat its Anti-Patterns section as hard constraints (violations are bugs) and its Safety Patterns as mandatory checks before reporting COMPLETE
   - Include the full task-implementer protocol instructions (from `~/.claude/agents/task-implementer.md`, pre-read once at stage start)

6. **Process subagent result**:

   - **COMPLETE**:
     a. Verify the result includes Files Changed and AC Verification tables
     b. Update `phases.md` checkbox: `- [ ]` → `- [x]`
     c. Append 1-line summary to `prior_tasks`: "Task {N.M}: {title} — COMPLETE | Files: {file list} | Notes: {notes for next task}"
     d. Write task summary to `pipeline-state.md` Task Summaries section
     e. `TaskUpdate` → `completed`
     f. Report progress: "[{done}/{total}] Task {N.M} complete. Files: {list}"
     g. **Decision preservation**: When the task-implementer returns Decisions Made that are
        non-trivial (new pattern introduced, API constraint discovered, convention deviation):
        include the full decision text (not just the 1-line summary) in the prior-tasks field
        for the NEXT task only. After that task, collapse back to 1-line summary.
     h. **Sensitive task review** (Deep tier OR HIGH sensitivity): Orchestrator reads all
        changed files from the subagent result. Targeted check: exposed secrets, unhandled
        error paths, auth bypass vectors, missing input validation. If issues found: present
        to user before marking complete. This applies regardless of tier when sensitivity = HIGH.
     i. **Steal compliance check**: If the task had `<steal-constraints>` in its spec,
        verify the subagent result confirms each Preserve directive and Verify line was
        satisfied. If any Preserve directive is not reflected in the implementation: treat
        as AC failure — do not mark complete. Present the specific deviation to the user.
     j. **Extended decision preservation** (Deep tier only): Extend the window to 2 tasks —
        full decision text rides in `prior_tasks` for the next 2 tasks, then collapses to 1-line.

   - **BLOCKED**:
     a. Read the Blockers section from the result
     b. Present to user via `AskUserQuestion`: "Task {N.M} is blocked: {blocker description}. How to proceed?"
     c. Based on user response: resolve and re-spawn subagent, skip task, or HALT phase
     d. **Scope change re-assessment**: If the user resolves a block by approving scope expansion
        (new files, new dependency, scope creep): re-compute the complexity score. If the tier
        changes (e.g., Standard → Deep), announce: "Scope expansion changes tier: {old} → {new}.
        Applying {new} tier from this point forward."

   - **REQUIRES_VERIFICATION**:
     a. Present manual verification items to user
     b. If user confirms: treat as COMPLETE (step 6a)
     c. If user rejects: treat as BLOCKED (step 6b)

   - **Crash/empty output**:
     a. Retry once with same context
     b. If second attempt fails: present to user as BLOCKED

7. Update `pipeline-state.md`: set Active Task to next task (or "none" if last), update phase progress, set Next Action.

### What the orchestrator holds in context
- Plan summary (execution order + task titles)
- Task status table (which tasks done, which remaining)
- Accumulated 1-line summaries from completed tasks
- Pre-read deep-knowledge and conventions (loaded once)

### What each task-implementer gets fresh
- Full task spec with ACs
- Conventions from plan
- Prior task summaries (1 line each)
- Deep-knowledge content
- Fresh codebase reads (sees all prior task changes on disk)

### Blocking Conditions
- Subagent returns BLOCKED → surface to user
- 3 consecutive subagent failures on same task → HALT with diagnostic
- Scope creep detected in subagent result → HALT, present to user

### Success: All tasks complete, all ACs verified, all checkboxes updated.
### Failure: Any task blocked after retries and user intervention.

### Stage 5: Validation Gates

Follow `references/validation-and-recovery.md` for gate execution and error recovery.

1. Run each gate from the phase's Validation Gates table.
   - **Automated gates**: Run the command via Bash, capture output, compare against expected result
   - **Manual-visual/behavioral gates**: Present the instruction to the user, wait for confirmation

2. Present a results table:
   ```
   | Gate | Status |
   |------|--------|
   | Build succeeds | PASS |
   | Tests pass | PASS |
   | Manual: Login form renders | WAITING |
   ```

3. If all gates PASS → proceed to Stage 6.

4. If any gate FAILS → enter error recovery loop:
   - Analyze failure and identify root cause
   - Fix the issue and re-run the failing gate
   - Re-run ALL previously-passing gates (regression check)
   - If a regression is detected → STOP immediately
   - If the same gate fails 3 times → STOP with full diagnostic

5. **Deep tier additions**:
   - After every gate fix: re-run ALL gates (full regression every time, not just previously-passing).
   - Implicit gate: grep for patterns from prior key-learnings "Patterns Established" sections.
     If any established pattern is violated by this phase's code → FAIL with pattern name + violation location.

### Success: All validation gates PASS.
### Failure: Any gate fails 3 times, or regression detected.

→ Present gate results. HALT. Wait for user before Stage 6.

### Stage 6: Key Learnings Creation

Follow `references/key-learnings-creation-guide.md` for the full creation process.

1. Ensure `key-learnings/` directory exists at project root (`mkdir -p key-learnings`).

2. Generate key-learnings content. The file MUST use these EXACT section headers from the template (do not rename, reorder, or omit any section):
   - `## Summary` — MANDATORY first section. One paragraph: what was planned, what was built, deviations, current state.
   - `## Architecture Decisions Made`
   - `## Patterns Established`
   - `## Issues Encountered & Resolutions`
   - `## Dependencies & Versions Locked` (write "None — no new dependencies in this phase." if empty)
   - `## Conventions Established`
   - `## Notes for Next Phase`
   - `## Files Created/Modified`

3. Write to `key-learnings/key-learnings-{NN}.md` using the template from `assets/key-learnings-template.md`.

4. Present the key-learnings file to the user for review. Incorporate edits if requested.

### Success: key-learnings file written with all 8 required sections.
### Failure: Unable to generate accurate key-learnings content.

### Stage 7: Phase Completion

0. Update `pipeline-state.md` (if it exists): set dev Status for this phase to `COMPLETE`, set Active Phase to "{N}", set Active Task to "none", set Next Action to "Run /qa {N} to validate this phase", set Last Updated to current timestamp, set Last Skill to "dev".

**Before presenting the completion summary, run these mandatory checks:**

1. **Verify all checkboxes**: Read `phases.md` and confirm every task in this phase is `- [x]`. If any task is still `- [ ]`, update it NOW before proceeding.

2. **Verify key-learnings exists**: Confirm `key-learnings/key-learnings-{NN}.md` exists and is non-empty. If it doesn't exist, go back to Stage 6 and create it NOW.

3. **Verify key-learnings has all required sections**: Grep the file for all 8 required `##` headers. If any are missing, fix the file NOW.

If any of these checks fail, fix the issue before continuing. Do NOT present the completion summary with missing artifacts.

3a. **Update README.md**: If `README.md` exists at project root, update it to reflect the project state after this phase. If it doesn't exist, create it. Include: project purpose, current capabilities (what works now), requirements and setup instructions, how to run, and a brief architecture note if significant. Keep it concise and written as a developer would — no AI attribution, no generation notices, no tool references.

3b. **Git commit**: Stage and commit all project changes from this phase:
   - Verify git is initialized and configured: `git status`, `git config user.name`, `git config user.email`, `git remote -v`. If user.name/email are not set, STOP and ask the user to configure them. If remote is not configured, warn the user but proceed with local commit.
   - Stage all modified/created project files (only files not excluded by `.gitignore` and global gitignore)
   - Write a concise commit message: imperative mood, lowercase, describing the phase's deliverable (e.g., "add emotion system and instinct reactions"). No structured prefixes unless the project uses conventional commits. No AI attribution of any kind — no `Co-Authored-By`, no "generated by", no AI emoji, no AI references.
   - Do NOT push to remote unless the user explicitly requests it
   - If git is not initialized, skip with: "Git not initialized — skipping commit."

4. **Knowledge capture** (lightweight):
   - Read `~/.claude/skills/_shared/deep-knowledge.md` (if exists)
   - Note any `[UNVERIFIED]` items that persisted across multiple tasks in the completion summary.

5. Present a final summary:
   ```
   Phase {N} Complete: {Phase Title}

   Tasks completed: {done}/{total}
   Validation gates: {passed}/{total} PASS
   Key learnings: key-learnings/key-learnings-{NN}.md
   Files created: {list}
   Files modified: {list}
   ```

6. Suggest next steps:
   - "/qa {N}" to validate this phase
   - "/dev {N+1}" to implement the next phase

7. Mark all remaining `TaskCreate` entries as completed.

**Note**: The plan file (`dev-plan-phase-{NN}.md`) may be kept for reference or deleted at the user's discretion. It is not required by downstream skills.

---

## Important Rules

1. **Never write code before Stage 3 approval.** Exploration reads and Grep/Glob are fine, but no file writes until the user approves the plan.

2. **Never skip validation gates.** Every gate must run and pass. Partial success is not success.

3. **Never mark a task complete with failing ACs.** If an AC cannot be satisfied, STOP and present the issue.

4. **NEVER end a phase without these two artifacts:**
   - ALL phase tasks checked off in `phases.md` (`- [x]`)
   - `key-learnings/key-learnings-{NN}.md` created with all 8 required sections

   These are the ONLY persistent outputs of a dev phase. Without them, qa cannot run and the next dev phase cannot start. Before presenting the completion summary, explicitly verify both artifacts exist by reading them.

5. **Never install unapproved dependencies.** If a package is not in `phases.md` or prior key-learnings, present it to the user for approval before installing.

6. **Match established patterns.** If prior phases use a specific error handling pattern, naming convention, or file structure, follow it exactly. Consistency beats personal preference.

7. **One phase per invocation.** Each `/dev {N}` call implements exactly one phase. Do not cascade into subsequent phases.

8. **Never critique code quality or suggest improvements outside the current task's scope.** If you spot an issue in unrelated code, note it in key-learnings "Notes for Next Phase" instead of addressing it inline.

9. **Never propose alternative architectures mid-implementation.** If a fundamentally better approach emerges during implementation, use the blocking conditions protocol (Scope Creep) to surface it — do not silently switch approaches.

---

## Reference Files

Load these files when the workflow reaches the relevant stage:

- `references/task-execution-protocol.md` — Pre-task checklist, implementation rules, AC verification, and deviation handling. Load at **Stage 4**.
- `references/validation-and-recovery.md` — Gate execution by type, 3-strike error recovery, and regression detection. Load at **Stage 5**.
- `references/key-learnings-creation-guide.md` — Data gathering, section-by-section population, and quality checklist. Load at **Stage 6**.
- `references/blocking-conditions.md` — Complete list of STOP conditions with detection, presentation, and resumption instructions. Load at **any stage** when a blocking condition is encountered.
- `references/sensitivity-heuristics.md` — Domain-specific verification checklists per HIGH-sensitivity category. Load at **Stage 4** when task sensitivity = HIGH.
- `~/.claude/skills/_shared/references/pipeline-state-protocol.md` — Pipeline state read/update rules and resume detection. Load at **Stage 1**.
- `~/.claude/skills/_shared/references/testing-strategy-archetypes.md` — Testing archetype definitions and verification point rules. Load at **Stage 1** (step 1c2) to detect project testing strategy from phases.md.

**Subagents**:
- `dev-planner` (`~/.claude/agents/dev-planner.md`): Handles codebase exploration and implementation planning at **Stage 2**. Model: opus.
- `task-implementer` (`~/.claude/agents/task-implementer.md`): Handles single-task implementation at **Stage 4**. One invocation per task, fresh context each. Model: sonnet.

---

## Example Invocation

**User**: `/dev 1`

**Expected behavior**:
1. Check for existing plan file or resume state (lightweight)
2. Invoke `dev-planner` subagent → produces `dev-plan-phase-01.md`
3. Read plan file, verify sections, check blockers/questions/dependencies
4. Present implementation plan with per-task approach
5. Wait for user approval
6. Execute tasks sequentially: implement, verify ACs, check off in `phases.md`
7. Run all validation gates
8. Create `key-learnings/key-learnings-01.md`
9. Present completion summary with next steps
