# Validation & Recovery Protocol

Gate execution strategy and error recovery for Stage 5 of the dev workflow. Defines how to run each gate type, handle failures, and detect regressions.

---

## Gate Execution by Type

### Automated Gates

**Execution**: Run the command via Bash tool.

**Steps:**
1. Run the exact command from the Validation Gates table
2. Capture exit code and output
3. Compare against expected result from `phases.md`
4. PASS if exit code and output match expectations; FAIL otherwise

**Example:**
```
Gate: TypeScript compiles
Command: npx tsc --noEmit
Expected: Exit code 0, no errors

Run: npx tsc --noEmit
Result: Exit code 0, no output
Status: PASS
```

### Manual-Visual Gates

**Execution**: Present instructions to the user and wait for confirmation.

**Steps:**
1. Display the gate description and what the user should check
2. If a URL or path is involved, provide it explicitly
3. Ask the user to confirm with a clear question

**Example:**
```
Gate: Login form renders correctly
Instructions: Open your browser to localhost:3000/login

Please verify:
- Login form is visible with email and password fields
- Submit button is present and labeled "Sign In"
- Layout matches the design specification

Does the login form render correctly? (yes/no)
```

### Manual-Behavioral Gates

**Execution**: Present step-by-step instructions for the user to follow.

**Steps:**
1. List each action the user must take, in order
2. Specify the expected behavior at each step
3. Ask for confirmation after the complete flow

**Example:**
```
Gate: Login flow works end-to-end
Steps:
1. Open localhost:3000/login
2. Enter valid test credentials (email: test@example.com, password: testpass)
3. Click "Sign In"
4. Expected: Redirect to /dashboard, user name displayed in header

5. Click "Sign Out" in the header
6. Expected: Redirect to /login, session cleared

Did the login flow work as described? (yes/no)
```

### Integration Gates

**Execution**: Orchestrate a multi-step automated flow, sometimes combining automated commands with manual verification.

**Steps:**
1. Run automated setup steps (seed database, start services)
2. Execute the integration flow
3. Verify each step's output
4. All steps must pass for the gate to pass

---

## Results Presentation

After running all gates, present a summary table:

```
Validation Results:
| # | Gate | Type | Status |
|---|------|------|--------|
| 1 | Dependencies installed | Automated | PASS |
| 2 | TypeScript compiles | Automated | PASS |
| 3 | Tests pass | Automated | PASS |
| 4 | Build succeeds | Automated | PASS |
| 5 | Login form renders | Manual-visual | PASS |
| 6 | Login flow works | Manual-behavioral | FAIL |
```

---

## 3-Strike Error Recovery Protocol

When a gate fails, enter the recovery loop:

### Strike 1: Standard Fix

1. Analyze the failure output
2. Identify the root cause
3. Fix the issue (edit code, adjust config, etc.)
4. Re-run the failing gate
5. If it passes → run regression check (see below)
6. If it fails → proceed to Strike 2

### Strike 2: Alternative Approach

1. The previous fix did not work. Perform a different root cause analysis.
2. Consider:
   - Is the expected result in `phases.md` correct?
   - Is a dependency missing or misconfigured?
   - Is there an interaction with code from a prior phase?
3. Apply a different fix than Strike 1
4. Re-run the failing gate
5. If it passes → run regression check
6. If it fails → proceed to Strike 3

### Strike 3: STOP

The same gate has failed 3 times with different attempted fixes. This is a blocking condition.

1. STOP all implementation
2. Present a full diagnostic to the user:

```
BLOCKED: Gate "{gate name}" has failed 3 times.

Failure output:
{latest error output}

Attempted fixes:
1. {Strike 1 approach}: {what was tried and why it didn't work}
2. {Strike 2 approach}: {what was tried and why it didn't work}
3. {Strike 3 approach}: {what was tried and why it didn't work}

Root cause analysis:
{best understanding of why the gate is failing}

Requesting user guidance to proceed.
```

3. Wait for user guidance before continuing

---

## Regression Detection

After fixing a failing gate, re-run ALL previously-passing gates to check for regressions.

### Process

1. Record which gates passed before the fix
2. Apply the fix
3. Re-run the failing gate — confirm it now passes
4. Re-run every gate that was previously passing
5. Compare results

### If No Regression

All previously-passing gates still pass → continue to the next failing gate or proceed to Stage 6.

### If Regression Detected

A previously-passing gate now fails after the fix → STOP immediately.

```
REGRESSION DETECTED

Original failure: Gate "{gate A}" failed
Fix applied: {description of the fix}
Result: Gate "{gate A}" now passes

BUT Gate "{gate B}" (previously passing) now FAILS:
{failure output}

The fix for {gate A} has broken {gate B}.
Both the original failure and the regression need to be resolved.

Requesting user guidance to proceed.
```

Do not attempt to fix the regression automatically. Present both failures and let the user decide the approach.

---

## Partial Success Handling

If some gates pass and others fail after exhausting recovery attempts:

1. Report the mixed results clearly:
   ```
   Validation: 4/6 gates passed

   PASSING:
   - Dependencies installed
   - TypeScript compiles
   - Tests pass
   - Build succeeds

   FAILING:
   - Login form renders (3 strikes exhausted)
   - Login flow works (blocked by login form issue)
   ```

2. Never mark the phase as complete with any failing gates

3. The key-learnings file is NOT created until all gates pass (key-learnings documents a completed phase)

4. Wait for user guidance on how to proceed with the failing gates
