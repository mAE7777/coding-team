# Key Learnings Protocol

Defines the complete lifecycle of `key-learnings-XX.md` files — the consistency glue that connects phases in the feat → dev → qa workflow.

---

## Purpose

Key-learnings files capture the reality of what was built versus what was planned. They serve three critical functions:

1. **Context Transfer**: Each phase passes knowledge to the next phase via its key-learnings file
2. **Drift Documentation**: When implementation diverges from `phases.md`, key-learnings records why and how
3. **Conflict Resolution**: When key-learnings contradict `phases.md`, key-learnings take precedence because they reflect actual implementation

---

## File Naming

**Pattern**: `key-learnings-{NN}.md`

Where `{NN}` is the zero-padded phase number:
- Phase 0 → `key-learnings-00.md`
- Phase 1 → `key-learnings-01.md`
- Phase 2 → `key-learnings-02.md`
- ...
- Phase 12 → `key-learnings-12.md`

---

## File Location

```
{project-root}/
├── key-learnings/
│   ├── key-learnings-00.md
│   ├── key-learnings-01.md
│   ├── key-learnings-02.md
│   └── ...
├── phases.md
└── [project files]
```

The `key-learnings/` directory is created at the project root during feat Phase 5 (or by dev when completing Phase 0).

---

## Lifecycle

### Creation
- **Who**: dev agent, after completing a phase's development work
- **When**: After all validation gates pass for the phase
- **Where**: `{project-root}/key-learnings/key-learnings-{NN}.md`

### Update
- **Who**: qa agent, after validating the phase
- **When**: After qa review is complete
- **What**: Adds a "qa Notes" section at the bottom with findings, issues, and resolutions

### Reference
- **Who**: dev agent, before starting the next phase
- **When**: Before writing any code for Phase N, read ALL key-learnings from Phase 0 through Phase N-1
- **Why**: To understand the actual state of the codebase, not just what was planned

---

## Required Sections

Every key-learnings file MUST contain these sections:

```markdown
# Key Learnings — Phase {N}: {Phase Title}

## Summary
One paragraph describing what was accomplished in this phase. Include the overall
outcome, any major deviations from the plan, and the current state of the project
after this phase.

## Architecture Decisions Made

| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| Used server components for data fetching | Reduces client bundle, leverages Next.js 14 patterns | Could have used client-side fetching with SWR |
| Chose Zustand over Redux | Simpler API, less boilerplate, sufficient for app scope | Redux Toolkit, Jotai, Context API |

## Patterns Established

| Pattern | Used In | Why |
|---------|---------|-----|
| Repository pattern for data access | `src/lib/repositories/` | Decouples data layer from business logic |
| Compound component pattern | `src/components/Form/` | Flexible form composition |

## Issues Encountered & Resolutions

| Issue | Resolution | Prevention |
|-------|------------|------------|
| Hydration mismatch with dynamic dates | Used `suppressHydrationWarning` + client-only rendering for dates | Always use client components for dynamic content |
| pnpm peer dependency conflicts | Added `peerDependencyRules` to `.npmrc` | Check peer deps before adding packages |

## Dependencies & Versions Locked

| Package | Version | Why This Version |
|---------|---------|------------------|
| next | 14.1.0 | Stable App Router support |
| @auth/nextjs | 0.5.0 | Latest with route handler support |

## Conventions Established

| Convention | Scope | Example |
|------------|-------|---------|
| All API routes return `{ data, error }` shape | API layer | `return NextResponse.json({ data: user, error: null })` |
| Components use named exports | Components | `export function LoginForm() { ... }` |

## Notes for Next Phase
- Authentication middleware is set up but only protects `/dashboard/*` routes — extend as new protected routes are added
- Database schema includes `users` table only — next phase should add related tables
- The `NEXT_PUBLIC_` prefix is required for any env vars needed client-side
- Rate limiting is not yet implemented — consider adding in Phase 3

## Files Created/Modified

| File | Action | What Changed / Purpose |
|------|--------|----------------------|
| `src/lib/auth.ts` | Created | Authentication utility functions |
| `src/app/api/auth/[...nextauth]/route.ts` | Created | NextAuth route handler |
| `src/middleware.ts` | Created | Route protection middleware |
| `package.json` | Modified | Added auth dependencies |
```

---

## How Subsequent Phases Reference Key-Learnings

### In phases.md
Each phase's "Context" section includes:

```markdown
### Context

> **Required reading before starting this phase:**
> - `key-learnings/key-learnings-{N-1}.md`
> - All previous key-learnings files (key-learnings-00 through key-learnings-{N-1})
> - Phase {N-1} validation gates must all pass
```

### dev Agent Protocol

Before starting Phase N, the dev agent MUST:

1. Read `key-learnings/key-learnings-00.md` through `key-learnings/key-learnings-{N-1}.md`
2. Note any conventions, patterns, or architecture decisions from prior phases
3. Check for any "Notes for Next Phase" that apply to Phase N
4. If a key-learning contradicts `phases.md`, follow the key-learning (it reflects reality)
5. If unsure about a contradiction, ask the user

### qa Agent Protocol

Before validating Phase N, the qa agent MUST:

1. Read the phase's key-learnings file (`key-learnings/key-learnings-{N}.md`)
2. Validate that all "Conventions Established" are actually followed in the code
3. Verify that "Patterns Established" are consistently applied
4. After validation, append a "qa Notes" section:

```markdown
## qa Notes (added by qa)

### Validation Date
{YYYY-MM-DD}

### Issues Found
| Issue | Severity | Resolution |
|-------|----------|------------|
| Missing error boundary in /dashboard | Medium | Added ErrorBoundary component |
| Type assertion without validation | Low | Added runtime type check |

### Verified
- [ ] All validation gates pass
- [ ] Conventions from key-learnings followed
- [ ] No regressions in previous phase functionality
- [ ] Key-learnings file is accurate and complete
```

---

## Conflict Resolution Rules

When `key-learnings-{N}.md` contradicts `phases.md`:

1. **Key-learnings wins**. It reflects what was actually built and why.
2. The dev agent for the next phase follows the key-learnings version.
3. The contradiction MUST be documented in the key-learnings file under "Architecture Decisions Made" with a clear explanation of why the divergence happened.
4. If the divergence is significant (affects multiple future phases), the user should be notified so they can decide whether to update `phases.md` or adjust the remaining phases.

---

## Directory Bootstrap

The feat skill creates the `key-learnings/` directory during Phase 5 of its workflow. If the directory doesn't exist when dev starts Phase 0:

```bash
mkdir -p key-learnings
```

dev creates `key-learnings/key-learnings-00.md` after completing Phase 0's validation gates.
