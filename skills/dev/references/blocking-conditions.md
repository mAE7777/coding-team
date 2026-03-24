# Blocking Conditions

Complete list of STOP conditions for the dev workflow. When any of these conditions is detected, halt all implementation and present the issue to the user for resolution.

---

## 1. Unapproved Dependency

**Detection**: A task requires installing a package that is not listed in `phases.md`, not documented in prior key-learnings, and not already present in the project manifest.

**When it occurs**: Stage 2 (planning) or Stage 4 (implementation).

**Present to user**:
```
BLOCKED: Unapproved dependency required

Package: {package-name}@{version}
Needed by: Task {N}.{M}: {task title}
Reason: {why the package is needed}
Referenced in: {where in the task or code it's needed}

This package is not listed in phases.md or prior key-learnings.
Should I add it? If yes, I'll install it and document it in key-learnings.
```

**Resume**: User approves → install and continue. User rejects → find an alternative approach or STOP if no alternative exists.

---

## 2. Ambiguity After All Sources Checked

**Detection**: A task instruction, AC, or implementation detail is unclear AND:
- `phases.md` does not resolve the ambiguity
- Prior key-learnings do not resolve the ambiguity
- Codebase patterns do not suggest a clear approach

**When it occurs**: Stage 2 (planning) or Stage 4 (implementation).

**Present to user**:
```
BLOCKED: Ambiguity cannot be resolved from available sources

Task: {N}.{M}: {task title}
Ambiguity: {what is unclear}
Sources checked:
  - phases.md: {what it says, or "no guidance"}
  - Key-learnings: {what they say, or "no guidance"}
  - Codebase: {what patterns exist, or "no clear pattern"}

Options:
1. {Option A}: {description and trade-offs}
2. {Option B}: {description and trade-offs}
3. {Other option if applicable}

Which approach should I take?
```

**Resume**: User selects an option → proceed with that approach and document the decision in key-learnings.

---

## 3. Three Consecutive Failures

**Detection**: The same acceptance criterion or validation gate has failed 3 times with different attempted fixes.

**When it occurs**: Stage 4 (task AC verification) or Stage 5 (validation gates).

**Present to user**:
```
BLOCKED: {AC or Gate} has failed 3 consecutive times

{AC description or Gate name}

Failure output:
{latest error output}

Attempted fixes:
1. {Attempt 1}: {what was tried} → {result}
2. {Attempt 2}: {what was tried} → {result}
3. {Attempt 3}: {what was tried} → {result}

Root cause analysis:
{best understanding of why it keeps failing}

Requesting guidance to proceed.
```

**Resume**: User provides direction → apply their suggested fix. If user asks to skip the AC/gate, document the skip in key-learnings with user's approval.

---

## 4. Missing Configuration

**Detection**: The implementation references a configuration value, environment variable, secret, or external service that does not exist in the project.

**When it occurs**: Stage 4 (implementation) — typically when code needs a value that's not defined.

**Present to user**:
```
BLOCKED: Missing configuration

What's missing: {config name or env var}
Referenced in: Task {N}.{M}, file {file path}
Expected by: {what code expects this value}
Checked:
  - .env / .env.local: {not found / not present}
  - phases.md: {mentions it or doesn't}
  - Key-learnings: {mentions it or doesn't}

Please provide the value or tell me where to find it.
```

**Resume**: User provides the value or location → configure it and continue.

---

## 5. Regression Detected

**Detection**: After fixing a failing validation gate, a previously-passing gate now fails.

**When it occurs**: Stage 5 (validation gate regression check).

**Present to user**:
```
BLOCKED: Regression detected

Original failure: Gate "{gate A}" — {what failed}
Fix applied: {description of the fix}
Result: Gate "{gate A}" now passes

Regression: Gate "{gate B}" (previously passing) now FAILS
Regression output:
{error output from gate B}

The fix for "{gate A}" broke "{gate B}".
Both failures need to be resolved together.

Requesting guidance to proceed.
```

**Resume**: User provides direction on how to resolve both issues together.

---

## 6. Scope Creep

**Detection**: Implementing a task requires changes to files or systems that are outside the current phase's defined scope.

**When it occurs**: Stage 4 (implementation) — discovered when a task's implementation impacts areas not listed in the phase's scope.

**Present to user**:
```
BLOCKED: Implementation requires out-of-scope changes

Task: {N}.{M}: {task title}
Required change: {what needs to change}
File/system affected: {file path or system name}
Phase scope says: {what's in-scope for this phase}
Likely owner: Phase {X} based on phases.md

Options:
1. Make the change now (expands this phase's scope)
2. Add a workaround within scope (describe trade-off)
3. Stop and adjust phases.md to redistribute work

Which approach should I take?
```

**Resume**: User selects an option → proceed accordingly. Document the scope change (or workaround) in key-learnings.

---

## 7. Key-Learnings Conflict

**Detection**: A key-learnings file states one thing, but `phases.md` states something different, and the right choice is not obvious.

**When it occurs**: Stage 1 (context loading) or Stage 4 (implementation).

**Normally key-learnings wins** (per Core Principle 3). But when the conflict is significant enough that blindly following key-learnings could cause problems:

**Present to user**:
```
BLOCKED: Key-learnings conflicts with phases.md

Key-learnings-{NN}.md says: {what key-learnings states}
phases.md says: {what phases.md states}

Context: {why this conflict matters}
Impact: {what happens if we follow key-learnings vs phases.md}

Normally key-learnings takes precedence (it reflects reality).
However, this conflict is significant enough to confirm.

Should I follow key-learnings (recommended) or phases.md?
```

**Resume**: User decides → follow their choice and document the decision in this phase's key-learnings.

---

## 8. Destructive Operation

**Detection**: A task would perform an irreversible operation: deleting files, dropping database tables, removing data, overwriting uncommitted work.

**When it occurs**: Stage 4 (implementation).

**Present to user**:
```
BLOCKED: Task requires destructive operation

Task: {N}.{M}: {task title}
Operation: {what will be destroyed/deleted/overwritten}
Affected: {files, tables, data that will be lost}
Reversible: No

Please confirm this operation before I proceed.
```

**Resume**: User confirms → proceed with the destructive operation. User rejects → find a non-destructive alternative or STOP.

---

## General STOP Behavior

When any blocking condition is triggered:

1. **Immediately stop all implementation work.** Do not continue with other tasks while waiting.
2. **Present the blocking condition** using the format above.
3. **Do not attempt to work around the block.** The block exists for a reason.
4. **Wait for user guidance.** Do not make assumptions about what the user wants.
5. **After resolution, document the block and its resolution** — this goes into key-learnings under "Issues Encountered & Resolutions."
