# Triage Criteria

Detailed rules for Stage 1 scope assessment. Load at Stage 1 after initial scope estimate for edge case handling, complexity classification, and qa-fix detection.

---

## File Count Assessment

Count files that need **modification**, not files that need **reading**.

### Tier Classification

| Files Modified | Tier | Process |
|----------------|------|---------|
| 1-3 | Quick | Triage → implement → verify (no plan review) |
| 4-15 | Standard | Triage → plan review → implement → verify → document |
| 15+ | Redirect | → /plan + /dev |

**How to count accurately:**
1. Start with the file containing the bug or change target
2. Trace imports: will the signature change? If so, count callers
3. Check tests: will existing tests need updates? Count those files
4. Check types: will shared type definitions change? Count consuming files

**Edge cases:**
- Renaming an export used in 5 files → Standard (even though the "fix" is conceptually simple)
- Changing a constant in a config file used everywhere → Quick IF only the config file is edited
- Updating a shared utility → count all files that import it if their behavior changes

---

## Complexity Assessment

Beyond file count, assess conceptual complexity:

### Low Complexity (proceed)
- Fix a typo, off-by-one error, missing null check
- Add a missing header, attribute, or config value
- Update a hardcoded value to match requirements
- Fix an import path or dependency version

### Medium Complexity (proceed with caution)
- Fix a race condition in a single component
- Add error handling to an existing function
- Fix a CSS layout issue across a few breakpoints
- Update an API response format

### High Complexity (redirect)
- Refactor a shared abstraction
- Change a data flow pattern
- Add a new component or endpoint
- Modify authentication/authorization logic
- Change database schema

---

## Dependency Rule

A fix NEVER installs new dependencies:

- Adding a package to `package.json` / `requirements.txt` / `Cargo.toml` → redirect
- Upgrading an existing package to a new major version → redirect
- Upgrading an existing package to a patch version → fix (if no API changes)

---

## Pipeline Overlap Detection

When `phases.md` exists, check for overlap:

1. Read the unchecked tasks in each phase
2. For each affected file, check if it appears in any phase's task list
3. Overlap categories:
   - **No overlap**: Fix file is not in any phase's scope → safe to proceed
   - **Past phase overlap**: File was created/modified in a completed phase → proceed, document in that phase's key-learnings
   - **Current phase overlap**: File is in the active phase's scope → warn user, proceed if approved
   - **Future phase overlap**: File is in an upcoming phase's scope → proceed, document in the upcoming phase's key-learnings context

---

## qa-Fix Context Detection

qa-fix mode provides additional context when fixing documented qa findings. Detection and verification rules:

### Detection Rules

qa-fix mode is activated when ANY of these conditions are true:

1. **Explicit qa reference**: `$ARGUMENTS` contains phrases like "fix qa", "qa phase", "qa-report", or "qa findings"
2. **Finding ID reference**: `$ARGUMENTS` contains a finding ID pattern (e.g., "B-03", "F-12", "P-07") that matches an ID in an existing qa report

### Verification Protocol

When qa-fix mode is detected:

1. Use `Glob` to find all `qa-reports/qa-report-phase-*.md` files
2. Read the relevant qa report(s)
3. Map the described fix to specific findings in the report:
   - Find the finding ID(s) that match the fix description
   - Verify the finding exists and is documented
   - List the files associated with the finding
4. Present the mapping in the triage output:
   ```
   qa-Fix Context:
   Report: qa-report-phase-{N}.md
   Findings addressed: {ID list}
   Files mapped from findings: {file list}
   ```

### Edge Cases

- **No qa report found**: Inform user: "No qa report found. Operating without qa-fix context."
- **Finding not found in report**: Inform user: "Could not match description to a documented qa finding."
- **Fix addresses both qa and non-qa issues**: Use qa-fix mode if at least one finding maps to a documented qa report.
- **Multiple qa reports**: If findings span multiple reports, combine the file lists.
- **polish-routed fix**: If `polish-report.md` exists and the fix description matches a P0 or P1 finding categorized as "Code" or "Polish", activate qa-fix mode even without a qa report reference.
