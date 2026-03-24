# Key Learnings Creation Guide

Step-by-step process for Stage 6 of the dev workflow. Defines how to gather data from the implementation session and populate each section of the key-learnings file.

---

## Data Gathering

Before writing the key-learnings file, gather data from these sources:

### From phases.md
- Phase goal and scope (what was planned)
- Original task list and acceptance criteria
- Validation gates and expected results

### From the Implementation Session
- Actual files created and modified (compare to the plan)
- Deviations from the approved plan (what changed and why)
- Decisions made during implementation (architecture, patterns, trade-offs)

### From Task Execution
- Tasks that required retry cycles (what failed and how it was fixed)
- AC failures and their resolutions
- Any user questions asked and answers received

### From Validation Gates
- Gates that initially failed and the fixes applied
- Regression issues encountered (if any)
- Manual gate outcomes (user confirmations)

### From the Codebase
- `git diff` if available (shows exact file changes)
- Or compare file states: what existed before vs. after
- Manifest file changes (`package.json`, `requirements.txt`, etc.) for dependency diffs
- New patterns that emerged in the code

---

## Section-by-Section Population

Use the template from `assets/key-learnings-template.md`. For each section:

### Summary

Write one paragraph covering:
- What the phase set out to accomplish (from phases.md Goal)
- What was actually built (may differ from the plan)
- Any significant deviations and why they occurred
- Current state of the project after this phase

**Quality check**: The summary should let someone unfamiliar with the project understand what this phase achieved in 30 seconds.

### Architecture Decisions Made

Populate the table with every decision that shaped the implementation:

| Source | What to Capture |
|--------|----------------|
| Stage 2 planning | Decisions about execution order, approach, patterns |
| Stage 3 user feedback | Changes requested by the user to the plan |
| Stage 4 mid-task | Decisions made during implementation (e.g., choosing between two valid approaches) |
| User questions | Answers to ambiguity questions asked via `AskUserQuestion` |

**What to include**: Decision description, rationale (why this choice), alternatives that were considered.
**What to exclude**: Trivial decisions (variable naming within a function, import order).

### Patterns Established

Scan the code written in this phase for repeating structures:

1. Use Grep to find similar code blocks across the new files
2. Identify patterns in: file structure, component organization, API design, error handling, data flow
3. For each pattern, provide:
   - Pattern name and description
   - Which files use it (with paths)
   - Why this pattern was chosen

**Only include patterns that are NEW in this phase.** Patterns inherited from prior phases belong in their key-learnings, not this one.

### Issues Encountered & Resolutions

Capture every problem that required troubleshooting:

1. AC failures during task execution (from Stage 4 retry cycles)
2. Validation gate failures (from Stage 5 recovery)
3. Unexpected behavior during implementation
4. Configuration issues

For each issue, document:
- **Issue**: What went wrong (specific error or unexpected behavior)
- **Resolution**: How it was fixed
- **Prevention**: How to avoid this in future phases

### Dependencies & Versions Locked

Compare the manifest file before and after this phase:

1. Read the manifest file (`package.json`, `requirements.txt`, etc.)
2. Identify packages added during this phase
3. Record the exact version installed (not the range — the resolved version)
4. Note why this version was chosen (compatibility, stability, feature requirements)

If no dependencies were added, write "None — no new dependencies in this phase."

### Conventions Established

Only document conventions that are NEW in this phase:

- Naming conventions introduced by this phase's code
- File organization patterns created
- API design conventions established
- Testing patterns started
- Error handling approaches introduced

**Do not repeat conventions from prior phases.** Those are already documented in their respective key-learnings files. Only document what this phase adds to the convention set.

For each convention:
- **Convention**: What the rule is
- **Scope**: Where it applies (e.g., "API routes", "form components", "utility functions")
- **Example**: A concrete code example from this phase's files

### Notes for Next Phase

Capture forward-looking guidance:

- Deferred items: things explicitly pushed to a later phase
- Limitations of current implementation: known constraints
- Gotchas: non-obvious behaviors or configurations to be aware of
- Extension points: where future phases will need to add to this phase's work
- Configuration that needs updating: env vars, config files that future phases must modify

**Quality check**: Each note should map to an actual future phase's scope in `phases.md`. Do not create notes for hypothetical work.

### Files Created/Modified

List every file touched during the phase:

1. Use Glob to verify each file path is correct
2. For created files: describe the file's purpose
3. For modified files: describe what was changed and why

---

## Quality Checklist

Before writing the key-learnings file, verify:

- [ ] Every table has at least one row (or "None" with explanation for Dependencies and Conventions sections)
- [ ] No placeholder text remains (no `{placeholder}`, no `TBD`, no `TODO`)
- [ ] All file paths are verified with Glob (they exist on disk)
- [ ] Conventions do not contradict prior key-learnings files
- [ ] "Notes for Next Phase" entries map to actual future phases in `phases.md`
- [ ] Summary accurately reflects what was built (not just what was planned)
- [ ] Architecture decisions include rationale (not just "we chose X")
- [ ] Issues include prevention guidance (not just "we fixed it")

---

## Writing the File

**CRITICAL**: Use the EXACT section headers from the template. Do not rename headers (e.g., use `## Architecture Decisions Made`, not `## Architecture Decisions`). Do not omit sections — use "None" with explanation if a section has no entries.

1. Copy the template from `assets/key-learnings-template.md`
2. Fill in the phase number and title in the header
3. Populate each section following the guidance above
4. Write to `key-learnings/key-learnings-{NN}.md` where `{NN}` is the zero-padded phase number
5. Present the completed file to the user for review
6. Incorporate any edits the user requests
7. Confirm the final version is written to disk
