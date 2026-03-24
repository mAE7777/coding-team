# Adversarial Review Protocol

Code review with an adversarial mindset. qa actively searches for defects — minimum findings policy enforces thoroughness. Load at Stage 7 of the qa workflow.

---

## Section 1: Minimum Findings Policy

### Requirements

| Phase Type | Minimum Findings | Target Range |
|------------|-----------------|--------------|
| Phase 0 (setup only) | 1 | 1-3 |
| Normal phases | 3 | 5-10 |

This is a **forcing function to look harder**, NOT permission to fabricate findings.

### Why Minimum Findings?

Every nontrivial codebase has imperfections. If qa finds nothing, it means qa didn't look hard enough — not that the code is perfect. The minimum forces qa to examine:
- Error handling completeness
- Edge cases the developer didn't consider
- Type safety shortcuts
- Convention adherence
- Import organization
- Resource cleanup
- Dead code

### If Fewer Than Minimum Found After Exhaustive Review

If after completing all four passes (convention audit, code quality, key-learnings verification, cross-phase integrity), the finding count is still below minimum:

1. Re-examine every `catch` block — is the error handling meaningful or swallowed?
2. Re-examine every type assertion (`as`, `!`) — is there runtime validation?
3. Re-examine every async function — is there proper error handling?
4. Check for missing cleanup (useEffect returns, event listener removal)
5. Check for accessibility gaps (missing labels, poor tab order)
6. Check for documentation accuracy (comments match behavior)

If STILL below minimum after this secondary pass, document the review process to prove thoroughness:

```
Minimum finding threshold: 3
Actual findings: {N}
Secondary pass completed: Yes
Areas reviewed without findings:
- Error handling: All catch blocks have meaningful handling
- Type safety: No unsafe assertions found
- Async operations: All properly awaited with error handling
- Resource cleanup: All effects have cleanup returns
- Accessibility: All interactive elements labeled
- Documentation: All comments accurate
```

---

## Section 2: Convention Audit Procedure

### Input

Collect ALL conventions from:
1. Every key-learnings file's "Conventions Established" table
2. Every key-learnings file's "Patterns Established" table
3. The Consistency Rules section of `phases.md`

### Audit Procedure

For EACH convention:

1. **Identify the rule**: What must be true? (e.g., "All API routes return `{ data, error }` shape")
2. **Identify the scope**: Where does it apply? (e.g., "API layer" → `src/app/api/**`)
3. **Search for compliance**: `Grep` for the pattern in all scoped files
4. **Search for violations**: `Grep` for anti-patterns that would violate the convention
5. **Document every violation**:

```
Convention: {convention from key-learnings}
Source: key-learnings-{NN}.md, Conventions Established
Scope: {where it applies}
Violation: {file:line} — {what was found instead}
```

### Common Convention Violations

| Convention Type | How to Check | Common Violation |
|----------------|-------------|------------------|
| Import style (relative vs absolute) | Grep for import patterns | Mixed styles in same directory |
| Error handling pattern | Grep for try/catch, .catch() | Swallowed errors, missing catch |
| Naming convention | Grep for file names, function names | Inconsistent casing or prefixes |
| Component export style | Grep for export patterns | Mix of default and named exports |
| API response shape | Grep for return/response patterns | Missing error field, inconsistent structure |
| State management pattern | Grep for state hooks/stores | Direct state mutation, inconsistent patterns |

---

## Section 3: Code Quality Dimensions

### 8-Dimension Checklist

For EVERY file created or modified in the target phase, evaluate across these 8 dimensions:

#### 1. Error Handling
- [ ] All async operations have try/catch or .catch()
- [ ] Error messages are meaningful (not just `catch(e) {}`)
- [ ] No swallowed errors (empty catch blocks)
- [ ] Error boundaries present for component trees (React)
- [ ] User-facing errors are friendly, developer errors are detailed

**Grep patterns**: `catch\s*\(\s*\)`, `catch\s*\(.*\)\s*\{\s*\}` (empty catch)

#### 2. Type Safety
- [ ] No `any` type (search: `: any`, `as any`)
- [ ] No type assertions without runtime validation (`as Type` without checks)
- [ ] No `!` non-null assertions without justification
- [ ] No implicit `any` from untyped dependencies
- [ ] Generic constraints are meaningful (not just `<T>`)

**Grep patterns**: `: any`, `as any`, `as unknown as`, `!\.(` or `!\.`

#### 3. Resource Management
- [ ] useEffect cleanup functions return cleanup logic
- [ ] Event listeners are removed on unmount
- [ ] Timers (setTimeout, setInterval) are cleared
- [ ] Subscriptions are unsubscribed
- [ ] File handles and connections are closed

**Grep patterns**: `addEventListener` without matching `removeEventListener`, `setInterval` without `clearInterval`, `setTimeout` without `clearTimeout`

#### 4. Input Validation
- [ ] All user inputs are validated before processing
- [ ] Validation messages are descriptive
- [ ] Validation runs on both client and server (if applicable)
- [ ] Type coercion is explicit (no relying on `==`)
- [ ] Array bounds are checked before access

**Grep patterns**: `==\s` (loose equality instead of `===`), `\[\w+\]` without bounds check

#### 5. Security
- [ ] No `eval()` or `Function()` constructor
- [ ] No `innerHTML` or `dangerouslySetInnerHTML` with user data
- [ ] No secrets or credentials in source code
- [ ] No `process.env` variables exposed to client without `NEXT_PUBLIC_` (or framework equivalent)
- [ ] No `http://` URLs in production code (except localhost)

**Grep patterns**: `eval\(`, `\.innerHTML\s*=`, `dangerouslySetInnerHTML`, `password\s*[:=]\s*['"]`, `api[_-]?key\s*[:=]\s*['"]`

#### 6. Dead Code
- [ ] No unused imports
- [ ] No unreachable code after return/throw
- [ ] No commented-out code blocks (should be deleted, not commented)
- [ ] No unused function parameters
- [ ] No unused variables

**Grep patterns**: `// .*\(`, `/* .*\*/` (multi-line comments containing code), unused import warnings from TypeScript

#### 7. Naming
- [ ] Variables and functions follow established convention (camelCase, snake_case, etc.)
- [ ] File names follow established convention
- [ ] Boolean variables start with is/has/should/can
- [ ] Event handlers follow convention (handleClick, onClick, etc.)
- [ ] Constants are UPPER_SNAKE_CASE (if convention established)

#### 8. Dependencies
- [ ] All imports resolve (no broken import paths)
- [ ] No circular dependencies
- [ ] No unused packages in manifest
- [ ] Package versions match key-learnings declarations
- [ ] No duplicate packages (different versions of same package)

---

## Section 4: Key-Learnings Accuracy Verification

For EVERY section of the target phase's key-learnings file, verify against actual codebase:

### Architecture Decisions Made

For each decision in the table:
- Does the rationale match what's actually in the code?
- Was the decision actually followed, or was a different approach used?
- Are the "Alternatives Considered" accurate?

### Patterns Established

For each pattern:
- `Grep` for the pattern — does it exist where the key-learnings says it does?
- Is it used consistently, or are there files that don't follow it?
- Is the "Why" still accurate?

### Issues Encountered & Resolutions

For each issue:
- Was the resolution actually applied?
- Is the "Prevention" advice accurate and followed in subsequent code?

### Dependencies & Versions Locked

For each dependency:
- Check the actual manifest (package.json, etc.) — does the version match?
- Was the version actually locked, or is it a range?
- Is the "Why This Version" still accurate?

### Conventions Established

For each convention:
- `Grep` for adherence across ALL files in scope
- Count violations — even one violation makes the key-learnings inaccurate

### Notes for Next Phase

For each note:
- Is the note still relevant? (Did subsequent work address it?)
- Is the note accurate? (Does the described limitation still exist?)

### Files Created/Modified

For each file:
- `Glob` to verify the file exists at the stated path
- `Read` to verify the "What Changed / Purpose" is accurate
- Flag any files that exist but aren't listed (undocumented files)

### Documenting Corrections

For every inaccuracy found:

| Section | What Key-Learnings Claimed | What Actually Exists | Correction Applied |
|---------|---------------------------|---------------------|--------------------|
| Patterns Established | "Repository pattern in `src/lib/repositories/`" | Directory doesn't exist; functions are in `src/lib/data/` | Updated path to `src/lib/data/` |

---

## Section 5: Severity Classification

### CRITICAL

Findings that indicate:
- **Application crashes** or unrecoverable errors
- **Data loss** or corruption possible
- **Security vulnerabilities** exploitable by users
- **Core feature broken** (feature doesn't work as specified)
- **Regression** (prior phase functionality broken)

Examples:
- Unhandled promise rejection crashes the server
- XSS vulnerability in user input field
- Authentication bypass possible
- Data saved but not retrievable
- Prior phase's API endpoint returns 500

### MEDIUM

Findings that indicate:
- **Edge case failures** (feature works normally but fails under specific conditions)
- **Convention violations** (established patterns not followed)
- **Missing error handling** (happy path works but error path crashes)
- **Accessibility violations** (feature works but not accessible)
- **Performance issues** (feature works but is noticeably slow)

Examples:
- Form submission fails with unicode characters
- Named export convention violated in 3 files
- Missing try/catch on API call (crashes on network error)
- Button missing accessible name
- 3-second delay on page load due to unoptimized query

### LOW

Findings that indicate:
- **Style inconsistencies** (cosmetic, not functional)
- **Documentation improvements** (comments inaccurate or missing)
- **Minor naming violations** (one variable doesn't follow convention)
- **Unused code** (dead code that doesn't affect functionality)
- **Informational** (not a defect, but worth noting)

Examples:
- Inconsistent spacing in one component
- Comment says "returns array" but returns object
- Variable named `data` instead of `userData` (less descriptive than convention)
- Unused import left in file
- Console.log left in non-debug code
