# Task Execution Protocol

The inner implementation loop for Stage 4 of the dev workflow. Defines how each task is prepared, implemented, verified, and checkpointed.

---

## Pre-Task Checklist

Before writing any code for a task, complete these checks:

1. **Re-read the task** from `phases.md` — do not rely on memory from Stage 2. The source of truth is `phases.md`.

2. **Check conventions** applicable to this task:
   - From the Consistency Rules section of `phases.md`
   - From prior key-learnings "Conventions Established" and "Patterns Established"
   - From the convention scan done in Stage 2

3. **Verify prerequisites**:
   - Prior tasks in the sequence are marked `- [x]` in `phases.md`
   - Files that this task depends on exist and are in the expected state
   - Any configuration or environment this task needs is in place

4. **Review the approved plan** for this specific task — the implementation strategy, patterns to follow, and risks identified.

---

## Implementation Rules

### General

- Follow the approved plan's approach for this task. Do not deviate without user approval.
- Match established patterns from key-learnings. If Phase 1 uses named exports, use named exports. If Phase 0 established a specific directory structure, follow it.
- Make minimal changes. Do not refactor surrounding code, add comments to existing code, or "improve" things outside the task's scope.

### When Creating Files

- Follow naming conventions from Consistency Rules
- Match the structure of similar existing files (imports, exports, organization)
- Include only what the task specifies — do not add placeholder code for future tasks
- Create parent directories if they do not exist

### When Modifying Files

- Read the file first with the Read tool. Understand its current state before making changes.
- Use the Edit tool for targeted changes. Do not rewrite entire files when a surgical edit suffices.
- Preserve existing formatting, comments, and style
- If the modification affects imports or exports, verify that dependent files still work

### When Writing Tests

- Write and run tests as part of the task — never defer testing to a later step
- Follow the existing test patterns identified in the convention scan
- Test acceptance criteria directly: each Given/When/Then maps to at least one test assertion
- Run the test suite to verify no regressions

### When Testing Modules with Side Effects

For modules that interact with filesystem, shell, network, or external services:

- **Prefer dependency injection over direct imports** for I/O primitives (`spawn`, `fs` operations, `dns.resolve`, `fetch`). Accept these via constructor or function parameters so tests can inject controlled versions without `vi.mock` on Node.js built-ins
- **Use fixture directories** (isolated temp dirs with controlled file trees) instead of touching the real filesystem. Reuse any `create-test-env` or similar helper if the project provides one
- **Use HTTP interception** (`msw`, `nock`, or equivalent) for outbound network tests instead of hitting real endpoints. Check project's testing conventions for the preferred tool
- **Use in-process servers** for protocol tests (e.g., MCP SDK test server) — avoids port conflicts and external process management
- **Never rely on real system services** (Keychain, Docker, Ollama) in unit tests. Mock them. Use `describe.skipIf(!serviceAvailable)` for optional integration tests that verify real service interaction
- **Test the security pipeline in integration**, not just individual modules — e.g., verify that a tool result passes through leak detection → injection scanning → boundary wrapping as a connected chain

---

## Acceptance Criteria Verification

For each Given/When/Then criterion in the task:

### Automated ACs

1. Set up the "Given" precondition (create test data, navigate to state, configure environment)
2. Perform the "When" action (run command, call function, trigger event)
3. Verify the "Then" result (check output, assert state, verify file contents)
4. Record: PASS or FAIL with details

### Manual ACs

1. Present the AC to the user with clear instructions:
   ```
   Verifying AC: Given the login page is open, When invalid credentials are submitted, Then an error message displays

   Please verify: Open localhost:3000/login, enter invalid credentials, and confirm an error message appears.
   ```
2. Wait for user confirmation
3. Record: PASS (user confirmed) or FAIL (user reported issue)

### AC Failure Handling

If any AC fails:

1. **Attempt 1**: Analyze the failure, identify the root cause, fix the code, re-verify
2. **Attempt 2**: If the same AC fails again, try a different approach to the fix, re-verify
3. **Attempt 3**: If the same AC fails a third time, STOP — this is a blocking condition

Do not proceed to the next task with any failing ACs. The task is not complete until all ACs pass.

---

## Checkpoint Marking

After all ACs pass for a task:

1. **Update `phases.md`**: Change `- [ ]` to `- [x]` for the completed task. Use the Edit tool to make this change.

2. **Report progress**:
   ```
   [{done}/{total}] Task {N}.{M} complete: {task title}
   Files created: {list}
   Files modified: {list}
   ```

3. **Update task tracker**: `TaskUpdate` → `completed`

---

## Deviation Handling

### Minor Deviation

If the implementation differs slightly from the approved plan (e.g., a function takes an additional parameter, a file has a slightly different structure):

- Proceed with the implementation
- Document the deviation: what changed and why
- Include in key-learnings under "Architecture Decisions Made"

### Major Deviation

If a better approach is discovered mid-task that significantly differs from the approved plan:

1. STOP implementation
2. Present the alternative to the user:
   ```
   While implementing Task {N}.{M}, I found a better approach:

   Approved plan: {original approach}
   Better approach: {new approach}
   Reason: {why it's better}
   Impact: {what changes in the plan}
   ```
3. Wait for user approval before switching approaches
4. If approved, update the implementation plan mentally and document the decision in key-learnings

### Scope Creep Detection

If implementing a task requires changes outside the phase's defined scope:

1. STOP — this is a blocking condition (scope creep)
2. Present to the user: what additional work is needed, which phase likely owns it, and options for proceeding
3. Do not make out-of-scope changes without explicit user approval
