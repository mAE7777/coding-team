# Plan Mode Protocol

Detailed guide for Stage 2 of the dev workflow: codebase analysis and implementation planning. This protocol ensures the implementation plan is thorough, accurate, and actionable before any code is written.

---

## Three-Pass Exploration Strategy

### Pass 1: Task File Inventory

Extract every file path from the phase's tasks (the "Files" fields in `phases.md`).

**Steps:**
1. List all file paths mentioned across all tasks in the phase
2. Categorize each file:
   - **EXISTS**: File already exists in the codebase → read it to understand current state
   - **TO_CREATE**: File does not exist → verify parent directory exists
3. For EXISTS files, read them in parallel using the Read tool
4. For TO_CREATE files, use Glob to confirm parent directories exist; if a parent is missing, note it as a prerequisite step

**Output format:**
```
File Inventory:
- EXISTS: src/lib/auth.ts (read, 45 lines)
- EXISTS: src/app/layout.tsx (read, 32 lines)
- TO_CREATE: src/components/LoginForm.tsx (parent src/components/ exists)
- TO_CREATE: src/lib/validators/auth.ts (parent src/lib/validators/ MISSING — must create)
```

### Pass 2: Dependency Trace

Verify that the codebase matches what prior key-learnings describe.

**Steps:**
1. From prior key-learnings "Files Created/Modified" tables, identify files this phase depends on
2. Read those files to confirm they exist and match the documented state
3. From prior key-learnings "Patterns Established", verify the patterns are actually present in the codebase (Grep for key identifiers)
4. From prior key-learnings "Dependencies & Versions Locked", cross-check against the manifest file (`package.json`, `requirements.txt`, etc.)

**If a dependency trace fails:**
- A file documented in key-learnings is missing → STOP: present the discrepancy
- A pattern documented in key-learnings is not found → note as a risk in the plan
- A dependency version has changed → note the drift and document in the plan

### Pass 3: Convention Scan

Identify patterns the new code must follow for consistency.

**Steps:**
1. **Naming patterns**: Glob for file naming conventions (e.g., `src/components/**/*.tsx` reveals PascalCase convention)
2. **Import patterns**: Grep for import statements in existing files to identify path aliases, barrel exports, relative vs absolute imports
3. **Error handling**: Grep for `try`, `catch`, `.catch`, error utility usage to identify the established error pattern
4. **Testing patterns**: Glob for test files (`**/*.test.*`, `**/*.spec.*`), read one to identify the testing library and assertion style
5. **Config constraints**: Read config files (`tsconfig.json`, `eslint.config.*`, `.prettierrc`, etc.) to identify enforced rules

**Output format:**
```
Convention Scan:
- Naming: PascalCase components, camelCase utilities, kebab-case routes
- Imports: Path alias @/ maps to src/, barrel exports in each feature folder
- Errors: All API routes use { data, error } response shape
- Tests: Vitest with co-located test files, describe/it pattern
- Config: Strict TypeScript, no any allowed, Prettier enforced
```

---

## Implementation Plan Structure

After the three passes, construct the implementation plan using this structure:

### Execution Order

List all tasks with their execution sequence. If reordering from the `phases.md` sequence, provide rationale.

```
Execution Order:
1. Task 2.1: Create auth types — foundational types needed by all other tasks
2. Task 2.2: Implement auth service — depends on types from 2.1
3. Task 2.3: Create login form — depends on auth service from 2.2
4. Task 2.4: Add route protection — depends on auth service from 2.2
```

### Per-Task Approach

For each task, specify:

1. **Implementation strategy**: How to build it, not just what to build
2. **Patterns to follow**: Specific patterns from key-learnings or convention scan (with file:line references where possible)
3. **Files to create/modify**: With expected structure (imports, exports, key functions)
4. **Dependencies**: Other tasks that must complete first
5. **Risks**: Specific concerns (not vague "might break" — identify what could go wrong and how to detect it)

```
Task 2.1: Create auth types
  Strategy: Define TypeScript interfaces for User, Session, AuthResponse
  Pattern: Follow src/types/api.ts structure (named exports, JSDoc comments)
  Files:
    - CREATE src/types/auth.ts: export interface User, Session, LoginCredentials, RegisterCredentials
  Dependencies: None
  Risks: None identified
```

### Batched Questions

Collect all ambiguities discovered during exploration into a single `AskUserQuestion` call. Do not ask one question at a time — batch them.

Example:
```
I found 3 things that need your input:
1. The phase specifies "session management" but phases.md doesn't specify server-side vs client-side sessions. Which approach?
2. Task 2.3 mentions "form validation" but no validation library is in the dependencies. Should I use zod (already installed) or add a form-specific library?
3. The error handling convention from Phase 1 uses { data, error } for API routes, but this phase adds client-side forms. Should form errors follow the same shape?
```

### New Dependencies

List any packages that need to be installed that are not already in the project manifest or `phases.md`.

```
New Dependencies Required:
- bcryptjs@^2.4.3 — for password hashing (referenced in Task 2.2 but not in phases.md)
  → This triggers a blocking condition. Present to user for approval.
```

---

## Plan Quality Criteria

Before presenting the plan to the user, verify:

1. **Completeness**: Every task from `phases.md` appears in the plan
2. **File accuracy**: Every file path has been verified (EXISTS confirmed via Read, TO_CREATE confirmed via parent directory check)
3. **Actionability**: No vague language — "consider", "might need", "as appropriate" are banned. Every instruction is concrete and specific.
4. **Risk specificity**: Risks name a specific failure mode and detection method, not generic warnings
5. **Convention compliance**: The plan explicitly states which conventions apply to each task
6. **Dependency clarity**: Task dependencies form a valid directed acyclic graph (no circular dependencies)
