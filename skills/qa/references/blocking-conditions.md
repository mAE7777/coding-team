# qa Blocking Conditions

Six conditions that cause qa to STOP immediately. qa blocks on quality protection — if the foundation is unreliable or the implementation is incomplete, testing results would be meaningless.

---

## Condition 1: dev Phase Incomplete

### Detection
- Unchecked tasks (`- [ ]`) found in `phases.md` for the target phase
- Missing `key-learnings/key-learnings-{NN}.md` for the target phase
- Key-learnings file exists but is missing required sections

### When Detected
Stage 1 (Initialization & Context Loading)

### Presentation
```
BLOCKED: Phase {N} is not complete.

{If unchecked tasks}:
The following tasks are not checked off in phases.md:
- [ ] Task {N}.{M}: {description}
- [ ] Task {N}.{M}: {description}

{If missing key-learnings}:
key-learnings/key-learnings-{NN}.md does not exist.

{If incomplete key-learnings}:
key-learnings/key-learnings-{NN}.md is missing required sections:
- {missing section name}

Run /dev {N} to complete implementation before running qa.
```

### Resumption
User completes dev for the phase. Re-run `/qa {N}` from the beginning.

---

## Condition 2: Regression Failure

### Detection
Any automated gate from a PRIOR phase fails during regression testing.

### When Detected
Stage 5 (Automated Test Execution — regression portion)

### Presentation
```
BLOCKED: Regression failure detected.

Failed gate: {gate description}
From phase: Phase {M} ({phase title})
Command: {command}
Expected: {expected output}
Actual: {actual output}

Analysis:
Phase {N} likely broke this because:
{analysis of what changed and why it broke}

qa cannot continue — the foundation is unreliable.
Fix the regression and re-run /qa {N}.
```

### Resumption
User fixes the regression. Re-run `/qa {N}` from the beginning (not from where it stopped).

---

## Condition 3: Application Cannot Start

### Detection
- Build command fails (`npm run build` / equivalent returns non-zero)
- Dev server fails to start
- Application crashes on launch
- Required services unavailable (database, API)

### When Detected
Stage 5 (before any tests can run) or Stage 6 (before interactive tests)

### Presentation
```
BLOCKED: Application cannot start.

Command: {build/start command}
Error: {error output}

Without a running application, qa cannot execute:
- Interactive/visual tests (Stage 6)
- User journey simulations
- Accessibility audits
- Responsive testing

Fix the build/startup issue and re-run /qa {N}.
```

### Resumption
User fixes the build. Re-run `/qa {N}` from the beginning.

---

## Condition 4: Test Infrastructure Missing

### Detection
- Test runner not installed (jest, vitest, playwright not in dependencies)
- Test configuration missing or invalid
- Test commands from phases.md return "command not found"

### When Detected
Stage 5 (when attempting to run automated tests)

### Presentation
```
BLOCKED: Test infrastructure is not available.

Missing: {what's missing}
Command attempted: {command}
Error: {error output}

Expected by phases.md:
{relevant validation gate from phases.md}

Ensure test dependencies are installed and configured.
This may indicate Phase 0 was incomplete.
Re-run /qa {N} after resolving.
```

### Resumption
User installs/configures test infrastructure. Re-run `/qa {N}`.

---

## Condition 5: Critical Security Finding

### Detection
During Stage 7 (Adversarial Code Review) or Stage 5 (security tests):
- Exposed secrets in source code (API keys, passwords, tokens in plaintext)
- Active XSS vulnerability (user input rendered as HTML without sanitization)
- Authentication bypass possible
- SQL injection vulnerability
- Sensitive data exposed in client bundle or network responses

### When Detected
Stage 5 or Stage 7

### Presentation
```
CRITICAL SECURITY FINDING — Immediate action required.

Finding: {description}
Severity: CRITICAL
Evidence: {file:line or test output}

Details:
{specific explanation of the vulnerability}

Impact:
{what an attacker could do}

qa has paused to flag this for immediate attention.
This finding alone constitutes a qa FAIL regardless of other results.

Recommended action:
{specific fix recommendation}
```

### Resumption
qa does NOT stop entirely for security findings. qa flags the finding, records it as CRITICAL, and continues testing. The phase will automatically FAIL due to the CRITICAL finding. However, qa reports ALL findings, not just the first security issue.

**Exception**: If the security finding involves ACTIVE credential exposure (live API keys, database passwords visible in source), STOP all testing and report immediately — the credentials may need rotation.

---

## Condition 6: Three Consecutive P0 Failures in Same Category

### Detection
Three P0-priority tests in the same category (B through H) fail consecutively.

### When Detected
Stage 5 or Stage 6

### Presentation
```
BLOCKED: Systemic failure detected in {category name}.

Three consecutive P0 failures:
1. {test ID}: {description} — {failure reason}
2. {test ID}: {description} — {failure reason}
3. {test ID}: {description} — {failure reason}

This pattern suggests a fundamental issue in this area, not isolated bugs.
Remaining tests in this category are unlikely to pass.

qa will skip remaining tests in {category name} and continue with other categories.
The phase will FAIL due to P0 failures.

Suggested investigation:
{analysis of the common thread between the 3 failures}
```

### Resumption
qa continues with OTHER categories but skips the failing category. The phase will FAIL due to the P0 failures. User fixes the fundamental issue and re-runs `/qa {N}`.

---

## Key Difference from dev Blocking Conditions

| dev Blocks On | qa Blocks On |
|---------------|-------------|
| Plan protection (unapproved deps, scope creep) | Quality protection (regression, security, systemic failures) |
| Missing context (no phases.md, no key-learnings) | Incomplete implementation (unchecked tasks, missing key-learnings) |
| Gate failures after 3 strikes (while implementing) | Foundation failures (prior phases broken) |
| Ambiguity (unclear requirements) | Unreliability (can't trust test results) |

dev asks: "Should I build this?"
qa asks: "Is what was built actually correct?"
