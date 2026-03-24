# Test Generation Protocol

Methodology for designing genuinely critical, independent tests. This is the heart of qa — the difference between rubber-stamping and real validation.

---

## Section 1: The Independence Principle (Gap-First Design)

qa does NOT re-run dev's gates. qa designs tests that fill gaps dev left uncovered.

For every dev gate, ask: **"What did this NOT test?"** Then design tests to fill those gaps.

### Common dev Gates and qa Expansions

| dev Gate | What dev Checked | What qa Adds |
|----------|-----------------|--------------|
| `npm run build` succeeds | Code compiles | Bundle size analysis, tree shaking verification, source maps present, no unexpected dependencies bundled |
| `npx tsc --noEmit` | Types compile | No `any` types, no unsafe assertions, generic constraints correct, strict mode compliance |
| `npm test` passes | Unit tests pass | Edge cases not covered by existing tests, boundary values, error paths, null inputs |
| Manual: "Page renders" | Visual presence | 4-viewport responsive check, accessibility tree, keyboard navigation, loading/error/empty states |
| Manual: "Form works" | Happy path submit | Empty submission, max-length input, special characters, double-submit, back-button after submit |
| Server starts | Process runs | Graceful shutdown, port conflict handling, environment variable validation, health check endpoint |

### Gap Identification Rule

If qa cannot name **3+ things** dev's gates missed per category, the analysis is insufficient. Go deeper:
- Read the actual test files — what assertions exist? What's NOT asserted?
- Read the actual component code — what states exist? Which are tested?
- Read error handling — what errors are caught? What happens with uncaught ones?

---

## Section 2: Test Design Techniques

### Boundary Value Analysis

For every input with constraints, test these values:

**Numeric inputs:**
| Value | Description |
|-------|-------------|
| min | Minimum valid value |
| min - 1 | Just below minimum (invalid) |
| max | Maximum valid value |
| max + 1 | Just above maximum (invalid) |
| 0 | Zero (often a special case) |
| -1 | Negative (if only positives expected) |
| middle | Typical valid value |

**String inputs:**
| Value | Description |
|-------|-------------|
| empty `""` | Empty string |
| single char `"a"` | Minimum meaningful input |
| max length | At the limit |
| max + 1 | One over the limit |
| whitespace only `"   "` | Looks empty but isn't |
| unicode `"日本語"` | Non-ASCII characters |
| emoji `"👍🏽"` | Multi-byte unicode |
| HTML `"<script>alert(1)</script>"` | Injection attempt |
| SQL `"'; DROP TABLE users; --"` | SQL injection attempt |

**Array/collection inputs:**
| Value | Description |
|-------|-------------|
| empty `[]` | No items |
| single `[item]` | One item |
| many | Typical count |
| maximum | At the limit |
| maximum + 1 | One over the limit |

### Equivalence Partitioning

Group inputs into classes that should behave identically. Test one from each class:

| Partition | Example | Expected Behavior |
|-----------|---------|-------------------|
| Valid typical | `"john@example.com"` | Accepted |
| Valid boundary | `"a@b.co"` | Accepted (minimum valid) |
| Invalid format | `"not-an-email"` | Rejected with error |
| Empty | `""` | Rejected with "required" |
| Null/undefined | `null` | Handled gracefully |
| Special characters | `"user+tag@example.com"` | Accepted (valid per RFC) |
| Very long | `"a" * 255 + "@example.com"` | Rejected or truncated |

### State Transition Testing

For every stateful component or workflow:

1. Draw the state diagram: identify all states and valid transitions
2. Test every valid transition: verify the transition happens and the new state is correct
3. Test every invalid transition: verify the system rejects it gracefully
4. Test terminal states: verify no further transitions are possible

Example for a form:
```
States: Empty → Filling → Submitting → Success/Error
Valid: Empty→Filling (type), Filling→Submitting (submit), Submitting→Success, Submitting→Error
Invalid: Empty→Submitting (submit without filling), Submitting→Filling (type during submit)
```

### Error Guessing

Common defect patterns to check for:
- Off-by-one errors in loops and pagination
- Race conditions in async operations
- Null/undefined not handled in data chain
- Encoding issues (UTF-8 in URLs, filenames, database)
- Timezone-sensitive date comparisons
- Floating point precision in calculations
- Integer overflow in counters or IDs
- Cache staleness after mutations

---

## Section 3: User Journey Design

A user journey is a realistic simulation of a complete user session: 5-20 sequential actions that tell a story.

### Journey Template

```
Journey: {descriptive name}
Persona: {who is doing this}
Goal: {what they're trying to accomplish}

Setup:
  - {preconditions — app state, data, auth status}

Steps:
  1. {Action} → Expected: {what should happen}
  2. {Action} → Expected: {what should happen}
  ...
  N. {Final action} → Expected: {final state}

Verification:
  - {What to check after the journey completes}
```

### Journey Types

1. **Happy Path Journey**: The ideal flow with no errors
2. **Alternate Path Journey**: Valid but non-standard flow (e.g., using keyboard instead of mouse)
3. **Error Recovery Journey**: Encounter an error, recover, complete the task
4. **Session Lifecycle Journey**: Login → work → idle → return → logout
5. **Multi-Feature Journey**: Use features from multiple phases in sequence

### Anti-Pattern: The Isolated Click Test

This is NOT a journey:
```
1. Click button → Expected: modal opens
```

This IS a journey:
```
1. Navigate to dashboard
2. Click "New Project" → Expected: creation form appears
3. Fill in project name "Test Project" → Expected: field populated
4. Select category from dropdown → Expected: category selected
5. Click "Create" → Expected: loading indicator shown
6. Wait for creation → Expected: redirect to project page
7. Verify project name displayed → Expected: "Test Project" visible
8. Click back to dashboard → Expected: new project in list
```

---

## Section 4: Security Test Generation

### Input Validation Tests

For EVERY text input field, test:

| Attack Vector | Test Input | Expected Defense |
|--------------|------------|------------------|
| XSS (reflected) | `<script>alert('XSS')</script>` | Input sanitized or escaped in output |
| XSS (stored) | `<img onerror=alert(1) src=x>` | HTML entities escaped |
| XSS (attribute) | `" onmouseover="alert(1)` | Attribute properly quoted/escaped |
| SQL injection | `' OR '1'='1` | Parameterized query, input rejected |
| Template injection | `{{7*7}}` or `${7*7}` | Template literal not evaluated |
| Path traversal | `../../../etc/passwd` | Path normalized, access denied |
| Command injection | `; ls -la` | Input not passed to shell |

### Source Code Security Grep Patterns

Search all project files for these patterns:

| Pattern | Risk | Grep Command |
|---------|------|-------------|
| `eval(` | Code injection | `eval\(` |
| `innerHTML` | XSS | `innerHTML` |
| `dangerouslySetInnerHTML` | XSS | `dangerouslySetInnerHTML` |
| `process.env` in client code | Secret exposure | `process\.env` in `src/` non-server files |
| Hardcoded secrets | Credential leak | `password\s*=\s*["']`, `secret\s*=\s*["']`, `api_key\s*=\s*["']` |
| `http://` (non-localhost) | Insecure transport | `http://(?!localhost)` |
| `console.log` with data | Data exposure | `console\.(log\|debug)` with variable arguments |
| `TODO` / `FIXME` / `HACK` | Incomplete code | `TODO\|FIXME\|HACK\|XXX` |

### Dependency Audit

Run and evaluate:
```bash
npm audit --json  # or equivalent for the package manager
```
Flag: critical/high vulnerabilities as P0, moderate as P1, low as P2.

---

## Section 5: Side-Effect Isolation for System-Interaction Modules

When testing modules that interact with filesystem, shell, network, or external services, qa tests must verify isolation — not just functionality.

### Gap Identification for Side-Effect Modules

For each module that touches real I/O, check:

| Check | What qa Adds |
|-------|-------------|
| DI used for I/O primitives? | If module imports `fs`/`child_process`/`dns` directly instead of accepting via constructor, flag as MEDIUM (testability risk). Tests would need `vi.mock` on Node built-ins — fragile and leaky |
| Tests use fixture dirs? | Verify tests create isolated temp directories and clean up. If tests read/write to real paths (CWD, home dir), flag as MEDIUM (test pollution). Check `afterEach`/`afterAll` for cleanup |
| HTTP requests intercepted? | If tests hit real endpoints, flag as MEDIUM (flaky, network-dependent). Check if project uses `msw`, `nock`, or equivalent. If not available and module makes HTTP requests, flag as gap in testing infrastructure |
| System services mocked? | Tests depending on Keychain, Docker, Ollama, etc. must mock or use `skipIf`. If they assume the service is running, flag as LOW (CI-incompatible) |
| Security pipeline tested as chain? | For modules in the security → tool → orchestrator pipeline, verify integration tests exist that test the connected flow (e.g., tool result → leak detection → injection scan → boundary wrap). If only unit-tested in isolation, note as gap |

### Environment Pollution Detection

After running the full test suite, check for leaked side effects:
- Files created outside temp directories (glob for unexpected files in project root)
- Ports left open (test servers not shut down)
- Environment variables modified (snapshot `process.env` before/after)
- Processes spawned but not killed (zombie child processes)

### Docker E2E Awareness

If the project has `Dockerfile.test` or `test/e2e/`:
- qa E2E tests should use the Docker environment, not the host
- Verify E2E scenarios cover the same flows as manual validation gates (they should replace manual testing)
- If Docker E2E doesn't exist yet but the phase involves tool execution, note: "Manual validation gates required — Docker E2E not yet available"

---

## Section 6: Anti-Patterns to Avoid

### The Rubber Stamp
Re-running dev's exact gates and declaring "all pass." This adds zero value. qa must generate NEW tests.

### The Trivial Assertion
Testing that `1 + 1 === 2` or that a static heading text matches. Test BEHAVIOR, not constants.

### The Implementation Test
Testing internal function signatures or private state instead of observable behavior. If the implementation changes but behavior stays the same, the test shouldn't break.

### The Happy-Path-Only Suite
Only testing the success case. Real users encounter errors, edge cases, and unexpected states. Test those.

### The Accommodating Reviewer
"The code does X, so the test should expect X." Wrong. The test should expect what the SPECIFICATION says, not what the code does. If the code is wrong, the test should catch it.

### The Flaky Test
Tests that depend on timing, network, or execution order. Use:
- Explicit waits for specific conditions, not `sleep()`
- `browser_snapshot` to verify state, not timing assumptions
- Deterministic test data, not random generation

---

## Section 7: Minimum Test Generation Per Behavior

For every testable behavior identified in Stage 2, generate at minimum:

| Test Type | Count | Purpose |
|-----------|-------|---------|
| Happy path | 1 | Verify the behavior works as specified |
| Edge case | 2 | Boundary values, special inputs, empty states |
| Error path | 1 | Invalid input, network failure, missing data |
| Cross-interaction | 1 | Behavior combined with another feature |

**Total minimum**: 5 tests per behavior.

If a behavior has fewer than 5 tests, the analysis is incomplete. Look for more edge cases.
