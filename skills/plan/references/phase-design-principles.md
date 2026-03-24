# Phase Design Principles

Rules, patterns, and anti-patterns for decomposing a design document into implementable development phases.

---

## Decomposition Rules

### Rule 1: Phase 0 Is Always Setup
Phase 0 is ALWAYS "Prerequisites & Setup". It contains:
- Project scaffolding (e.g., `create-next-app`, `cargo init`)
- Dependency installation
- Configuration files (TypeScript, ESLint, Prettier, testing, etc.)
- Directory structure creation
- Environment variable templates (`.env.example`)
- Git initialization and `.gitignore`
- LICENSE file (if project will be public or published to a registry: detect from existing repo visibility, `"private"` field in package.json, or ask user. Use MIT unless user specifies otherwise. Must include copyright holder name.)

Phase 0 contains **zero feature code**. No business logic, no UI components, no API routes. The only exception is scaffold-generated boilerplate (e.g., the default page from `create-next-app`).

### Rule 2: Each Phase Delivers Testable Value
Every phase (except Phase 0) must deliver something a user or tester can verify. "Value" means:
- A user can see something new in the UI
- A user can perform a new action
- An API endpoint responds correctly
- A background process completes its job

If a phase only moves code around or "sets up infrastructure for later", it's not a valid phase — merge it with the phase that uses it.

### Rule 3: No Forward Dependencies
Phase N can ONLY depend on Phases 0 through N-1. Never on Phase N+1 or later.

This means:
- Phase 2 can use code from Phase 0 and Phase 1
- Phase 2 CANNOT rely on something that Phase 3 will provide
- If Phase 2 needs a database table, that table must be created in Phase 0, 1, or 2 — not deferred to Phase 3

### Rule 4: Group by User-Facing Capability
Phases are organized around what the user can do, not technical layers.

**Good decomposition:**
- Phase 1: User Authentication (login, register, session)
- Phase 2: Task Management (create, edit, delete tasks)
- Phase 3: Team Collaboration (invite, share, permissions)

**Bad decomposition:**
- Phase 1: Database Setup (all tables for all features)
- Phase 2: API Layer (all endpoints for all features)
- Phase 3: Frontend (all UI for all features)

The bad decomposition means nothing is testable until Phase 3. The good decomposition means each phase produces a working feature.

### Rule 5: Right-Sized Phases
Each phase should contain 3-8 tasks and be completable in 1-2 development sessions.
Adjust based on testing archetype (see `testing-strategy-archetypes.md`):

**Default sizing (Archetype A — Standard Software):**
- 3-4 tasks: Small phase (simple feature, configuration change)
- 5-6 tasks: Medium phase (typical feature with UI + API + tests)
- 7-8 tasks: Large phase (complex feature, consider splitting)

**Archetype B (Hardware/IoT) or C (Perception/Animation):**
- 2-4 tasks per phase, shorter duration per task (max 2hr for B, 1hr for C)
- Each task includes its own verification point (flash-and-test or visual check)
- Prefer more phases with fewer tasks over fewer phases with many tasks

**Archetype D (Data Pipeline):**
- 3-5 tasks per phase, 1-2hr per transformation step
- Schema check + spot-check values after each transformation task

**Too small** (under 2 tasks for B/C, under 3 for A/D): Merge with an adjacent phase. Overhead of key-learnings and validation gates isn't justified.

**Too large** (over 4 tasks for B/C, over 8 for A/D): Split into sub-phases. Each sub-phase should deliver its own testable increment.

### Rule 6: Every Task Maps to Files
Every task in a phase must create or modify at least one file. If a task doesn't touch a file, it's either:
- Not a development task (remove it or make it a validation gate)
- Too vague (make it more specific until it maps to files)

### Rule 7: Minimize Cross-Phase File Edits
Try to concentrate file modifications within a single phase. If `src/app/layout.tsx` is modified in Phase 1, 3, 5, and 7, that's a smell — the modifications may be better grouped.

**Acceptable:** A core file like `layout.tsx` or `package.json` touched in multiple phases (these are natural accumulation points).

**Not acceptable:** A feature-specific file like `UserProfile.tsx` touched in Phase 2, 4, and 6. Those changes should be consolidated.

### Rule 8: Decompose Acceptance Criteria to Observable Behaviors

Every AC must map to a single observable behavior. If an AC contains "validation", "error handling", "security", or "graceful degradation", decompose into sub-ACs that each name:
- **The trigger**: what specific input or event causes the behavior
- **The system response**: what the user sees, what the API returns, what gets logged
- **The boundary**: what happens at edges (empty input, max length, timeout)

**Decomposition test**: if two developers could implement the AC differently and both claim they pass, the AC is too vague.

Before: "Add ingredient validation with graceful degradation"
After:
- Given user blurs ingredient field with empty value, When blur fires, Then red border and "Ingredient name required" appear
- Given validation API is unreachable, When user submits, Then form submits with warning "Ingredient names not validated" (not blocking)
- Given name exceeds 200 characters, When user types 201st character, Then input truncates and counter shows "200/200"

### Rule 9: Progressive Shippability (Onion Model)
Every phase (after Phase 0) ships a complete product layer, not a slice of a future product.

- Phase 0: Environment — builds, runs, empty shell
- Phase 1: Simplest usable product — one core capability, end-to-end
- Phase 2+: Each adds a layer — the product is richer but was already whole

**Test**: After any phase, could you show this to a user and they'd understand what it does? If yes, the decomposition passes. If "it doesn't do anything useful until Phase 4", the decomposition fails.

**Exceptions**: Libraries, internal tools, and data pipelines may not have a "show to user" moment. For these, substitute: "Could a developer use this after this phase?" The principle still applies — each phase should produce something independently usable.

### Rule 10: Version Decomposition for Large Projects
If the project vision produces more than 10 phases (or >30 requirements, or >3 major feature areas), decompose into versions before phases.

- Version 1: Simplest viable product (3-5 phases)
- Version 2: Next capability layer (3-5 phases)
- Each version is independently shippable and useful

**Detection**: During Phase 1b requirement extraction, if the list exceeds the thresholds above, propose version boundaries to the user via AskUserQuestion before proceeding to phase architecture. Never generate a single phases.md with 12+ phases.

**Format**: When versioning, phases.md includes a Version wrapper (see `phases-md-specification.md`).

---

## Anti-Patterns

### Anti-Pattern 1: The Infrastructure Phase
**Symptom**: "Phase 1: Database Setup" — sets up all tables for all features.

**Problem**: No testable value. Later phases can't be validated independently because they depend on this monolithic setup.

**Fix**: Include database setup in the phase that first needs it. Phase 1 (Authentication) creates the `users` table. Phase 2 (Tasks) creates the `tasks` table.

### Anti-Pattern 2: The Mega Phase
**Symptom**: A phase with 15-20+ tasks.

**Problem**: Too large to complete in a session. Too many things can go wrong. Key-learnings become unwieldy.

**Fix**: Split by sub-capability. If "Task Management" has 18 tasks, split into "Task CRUD" (create, read, update, delete) and "Task Organization" (labels, filters, sorting).

### Anti-Pattern 3: The Omnibus Phase
**Symptom**: A phase that touches every file in the project.

**Problem**: Any failure requires debugging the entire codebase. Validation is nearly impossible.

**Fix**: Decompose by scope. If "Add Dark Mode" touches every component, consider: Phase A adds the theme system and converts core layout components, Phase B converts remaining components.

### Anti-Pattern 4: Vague Validation
**Symptom**: "Verify it works", "Check that everything is functional", or "Ensure graceful degradation".

**Problem**: Unverifiable. "Graceful degradation" meant different things in different components of the same project — Phase 23 had to reverse Phase 14's interpretation.

**Fix**: Every validation gate must have:
1. A specific command to run OR a specific action to perform
2. A specific expected result (including error message text for error-path gates)
3. A clear pass/fail criterion

Banned phrases in gates: "works correctly", "functions as expected", "handles errors gracefully", "is responsive". Replace each with a concrete observable.

### Anti-Pattern 5: The Premature Abstraction Phase
**Symptom**: "Phase 1: Create Utility Library" — builds a bunch of helpers before any feature uses them.

**Problem**: You don't know what abstractions you need until you build features. YAGNI applies.

**Fix**: Build utilities as needed within feature phases. If Phase 2 needs a date formatter, create it in Phase 2.

### Anti-Pattern 6: The Testing-Only Phase
**Symptom**: "Phase N: Write Tests" — all tests for all features in one phase.

**Problem**: Tests are most valuable when written alongside the feature. A separate testing phase means features ship untested.

**Fix**: Include tests within each feature phase. Phase 1 (Authentication) includes auth tests. Phase 2 (Tasks) includes task tests.

---

## Validation Gate Types

### Automated Gates

Commands that can be run in a terminal with a clear pass/fail result.

| Gate Type | Example Command | Pass Criteria |
|-----------|----------------|---------------|
| Build | `npm run build` | Exit code 0, no errors |
| Type check | `npx tsc --noEmit` | Exit code 0, no errors |
| Lint | `npm run lint` | Exit code 0, no warnings |
| Unit tests | `npm test` | All tests pass |
| Integration tests | `npm run test:integration` | All tests pass |
| E2E tests | `npx playwright test` | All tests pass |
| Format check | `npx prettier --check .` | Exit code 0 |

### Manual-Visual Gates

Require a human (or AI with browser access) to visually verify something.

| Gate Type | Format | Example |
|-----------|--------|---------|
| Page renders | "Open `{URL}`, verify `{element}` is visible" | "Open `/login`, verify login form with email and password fields is visible" |
| Layout correct | "Open `{URL}`, verify `{layout description}`" | "Open `/dashboard`, verify sidebar navigation on left, main content on right" |
| Responsive | "Open `{URL}` at `{viewport}`, verify `{behavior}`" | "Open `/` at 375px width, verify navigation collapses to hamburger menu" |

### Manual-Behavioral Gates

Require performing an action and verifying the result.

| Gate Type | Format | Example |
|-----------|--------|---------|
| User action | "Do `{action}`, verify `{result}`" | "Click 'Sign Up', fill form, submit → verify redirect to dashboard" |
| Error handling | "Do `{invalid action}`, verify `{error message}`" | "Submit login with wrong password → verify 'Invalid credentials' message" |
| State persistence | "Do `{action}`, refresh page, verify `{state persisted}`" | "Create a task, refresh page, verify task still appears" |

### Integration Gates

End-to-end flows that cross multiple features or phases.

| Gate Type | Format | Example |
|-----------|--------|---------|
| User flow | "Complete flow: `{step 1}` → `{step 2}` → `{step N}`" | "Register → Login → Create Task → Assign to Team → Verify notification" |
| Data flow | "Create `{data}` via `{method A}`, verify via `{method B}`" | "Create task via API, verify it appears in UI" |

---

## Phase Ordering Heuristics

When multiple valid orderings exist, prefer this priority:

1. **Core infrastructure first**: Authentication, data models, core layout
2. **Primary user flow second**: The main thing the app does (e.g., task management for a task app)
3. **Secondary features next**: Supporting features (search, filtering, notifications)
4. **Polish last**: Dark mode, animations, performance optimization, accessibility hardening

This ordering ensures the most critical features are implemented first, reducing risk.
