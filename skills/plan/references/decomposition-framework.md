# Decomposition Framework

Four lenses applied to the Phase 1 extraction list during Phase 3. The lenses
generate the decomposition — they are not a post-hoc checklist.

---

## Value Lens

For each extracted requirement, answer: "What can a user DO after
this is built?" Group requirements that together enable one user capability. Each
group becomes a candidate phase. If a group has no user-facing action ("set up
infrastructure", "create utility layer"), it is not a valid phase — merge it into
the phase that first uses it.

---

## Dependency Lens

For each candidate phase, trace what must exist before it
works. If Phase N depends on something from Phase N+1, the dependency is backwards
— move the depended-on item earlier. Cascade-critical items (3+ dependents from
Phase 1 extraction) get priority placement: earliest phase that needs them, then
Grep all consumers to ensure nothing breaks downstream.

**Exhaustive consumer tracing**: For every cascade-critical item, grep the ENTIRE
`src/` directory (and any other source directories) for all references — including
re-exports, barrel files, type imports, and dynamic imports. A partial grep that
checks only direct imports will miss transitive consumers. The recipeforge failure
(F1 below) resulted from checking only 5 of 7 consuming files because re-exports through
`index.ts` barrels were not traced.

---

## Risk Lens

For each candidate phase, identify what could break in ways
undetectable during planning. The following categories are HIGH RISK — they get
an additional validation gate testing the failure path:

| Category | Example |
|----------|---------|
| Auth / identity | Session, tokens, RBAC |
| External APIs | Third-party services, webhooks |
| Data migrations | Schema changes, backfill scripts |
| Payments | Billing, subscriptions, refunds |
| Irreversible operations | Deletes, sends, publishes |
| Shell command construction | `exec`, `spawn`, `execSync` with user-derived args — command injection |
| Unbound array operations | `Math.max(...arr)`, `String.fromCharCode(...arr)` — stack overflow on large inputs |
| Type assertion without runtime validation | `as T` on external/API data without guard — silent corruption |
| Version-specific tool behavior | Breaking changes between major versions of CLIs, bundlers, linters |
| Error message forwarding | Raw `error.message` in fallthrough catch blocks exposed to users |

Library-specific usage claims get feasibility spot-checks in Phase 4b.
If >50% of phases are HIGH RISK, recommend /scout pre-mortem first.
Standard tier: skip Risk Lens when `discovery/premortem-*.md` exists (Tigers
already cover risk). Deep tier: always apply (mandatory supplement to pre-mortem).

---

## Journey Lens

For each candidate phase, simulate the user's experience: "What can a
user DO and FEEL after this phase ships?" This lens validates that every phase
produces a complete product layer (Progressive Shippability / Onion Model), not
just a technical milestone.

**Apply in order:**
1. After Phase 0 (setup), can the project at least build and run (even if empty)?
2. After Phase 1, is there a simplest usable product — something a real person
   could use, however basic? If not, the decomposition needs rework.
3. For each subsequent phase, verify: the product after this phase is strictly
   richer than after the previous phase. A user could stop here and have
   something complete (a cupcake, not a fraction of a wedding cake).

**Red flags this lens catches:**
- Phase 1 requires Phase 2 to be usable → merge or reorder
- A phase adds backend logic with no user-visible change → merge into the phase
  that surfaces it
- Three consecutive phases build infrastructure before any user value → wrong
  decomposition axis (switch from architecture-based to capability-based)
- A phase creates user-visible components (display, output, interaction) but no
  task wires them to the entry point → add an explicit integration task.
  "Create writeStatusLine()" without "Wire status line to REPL loop" means the
  feature is built but invisible. If the plan doesn't say "wire X to Y", dev
  won't do it.

**When this conflicts with other lenses:**
Sometimes module-based or architecture-based decomposition is genuinely better
(e.g., a library with no UI, a data pipeline, internal tooling). When Journey
Lens conflicts with Value or Dependency Lens, evaluate which approach better
serves the specific project and present options to the user. The Journey Lens
is not absolute — it's a strong default for user-facing products.

**Integration with User Journey Simulation:**
For user-facing projects (Standard/Deep tier), load `user-journey-simulation.md`
during Phase 3. Map each phase boundary to the 7-stage user journey:
- Phase 1 should reach at least Stage 4 (First Value / aha moment)
- Later phases progressively reach Stages 5-7 (Habit, Mastery, Identity)

---

## Known Failure Mapping

The known decomposition failures are structural consequences of skipping a lens:
Infrastructure-First (no Value Lens), Forward Dependencies (no Dependency Lens),
Scope Leak (ungrouped items bypass all lenses), Vague ACs (Value Lens demands
specific user actions), Missing Cascade Analysis (Dependency Lens traces consumers),
Unchecked Feasibility (Risk Lens flags unknowns), Construction-Site Phases (no
Journey Lens — phases build toward a future product instead of each being a
complete product layer). See `phase-design-principles.md` for detailed rules
and anti-patterns.

---

## Failure Catalog

Real planning failures from project key-learnings. Each entry identifies the
structural fix that prevents recurrence.

### F1: Incomplete cascade analysis
**Project**: recipeforge
**What happened**: A shared type was modified in Phase 1, but only 5 of 7
consuming files were updated. The 2 missed files were re-exports through
`index.ts` barrel files — the cascade trace checked direct imports but not
transitive consumers.
**Structural fix**: Dependency Lens now mandates exhaustive grep of entire `src/`
including re-exports and barrel files (see "Exhaustive consumer tracing" above).

### F2: Risk categories too narrow
**Project**: waveform
**What happened**: Three risk patterns went unflagged during planning:
(1) command injection via `exec()` with user-derived arguments,
(2) `Math.max(...waveformData)` stack overflow on large audio files,
(3) `as WaveformConfig` type assertion on API response without runtime validation.
None matched the original 5-category risk list.
**Structural fix**: Risk Lens expanded with 5 additional categories — shell
command construction, unbound array operations, type assertion without runtime
validation, version-specific tool behavior, and error message forwarding.

### F3: Specification honesty gap
**Project**: ai-code-reviewer
**What happened**: The plan claimed "never expose raw error messages to users"
as an architectural pattern, but Phase 4b only verified technology feasibility
claims — not architectural pattern claims. The generated phases.md did not
enforce the pattern in catch blocks and fallthrough error handlers, leading to
raw `error.message` leaking to the frontend in 3 API routes.
**Structural fix**: Phase 4b now includes step 1b — cross-reference architectural
pattern claims and verify phase tasks enforce the pattern in every code path,
including catch blocks and fallthrough cases.

### F4: Tooling/environment assumptions
**Projects**: waveform, forge
**What happened**: Plans assumed standard tool behavior that didn't hold:
(1) waveform — `pnpm` lockfile format differed between v8 and v9, causing
CI install failures; (2) forge — `create-next-app` changed its
default template structure between Next.js 14 and 15, breaking scaffold
assumptions; (3) waveform — `biome` v1.5→v1.9 changed default lint rules,
flagging previously-clean code.
**Structural fix**: Risk Lens now includes "version-specific tool behavior"
category. Plans that name specific tool versions get a feasibility spot-check
confirming the assumed behavior matches the pinned version.

---

## Empirical Sizing Data

From analysis of 28 project key-learnings directories:

| Metric | Observed | Source |
|--------|----------|--------|
| Tasks per phase (typical) | 3-6 | recipeforge, forge, waveform |
| Max tasks per phase | 7 | Framework integration phases |
| Phase splits during /dev | 0 | All sampled key-learnings |
| Phase merges during /dev | 0 | All sampled key-learnings |
| Primary failure mode | 14+ QA findings per phase | forge Phase 4 |

Current sizing heuristics work. If a phase exceeds 6 tasks during design,
split before /dev. Phases with 14+ QA findings indicate insufficient AC
granularity (see Rule 8 in phase-design-principles.md), not wrong phase sizing.
