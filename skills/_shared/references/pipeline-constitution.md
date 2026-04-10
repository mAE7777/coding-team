# Pipeline Constitution

Core principles for all pipeline skills. These are principles, not prescriptions — they
guide judgment rather than replacing it.

---

## Decision Authority

- **User approves every transition.** No skill advances to a new stage/phase
  without explicit user approval via `AskUserQuestion`. Never silently proceed.
- **When uncertain, mark it.** If a skill needs to introduce information not
  grounded in prior pipeline artifacts (scout research, design doc, user input),
  mark it `[UNVERIFIED: reason]` instead of stating it as fact.
- **No auto-resume.** When pipeline-state.md indicates a prior session was
  interrupted, always present the resume option to the user. Never auto-continue.

## Knowledge Flow

- **Key-learnings are mandatory.** Every dev phase writes structured key-learnings.
- **pipeline-state.md is updated at entry AND exit.** Skills that modify
  pipeline-state.md must update it when starting work AND when completing work.
- **Pre-mortem findings propagate.** Tiger mitigations become plan phase
  constraints. Elephant tripwires become dev/qa validation criteria. Unresolved
  risks become phases.md Open Questions.
- **Chain integrity.** Each dev/qa phase reads ALL prior key-learnings.
  Conventions established in Phase 0 apply to all subsequent phases.

## Specification Integrity

- **Trace to source.** Every technical detail in phases.md must trace to either:
  scout discovery findings, the user's design document, or explicit user input.
- **[UNVERIFIED] markers.** When plan introduces technologies, libraries, APIs,
  architecture patterns, or integrations not found in source documents, mark them:
  `[UNVERIFIED: not in source documents — {brief reason for inclusion}]`
- **dev respects markers.** When dev encounters an [UNVERIFIED] item in
  phases.md, verify it via research or user confirmation before implementing.

## Quality

- **qa is adversarial.** qa's job is to find defects, not confirm success.
  Assume defects exist and hunt for them.
- **Validation before completion.** No skill marks a phase as COMPLETE without
  running verification (build, typecheck, tests, or equivalent).
- **Security is continuous.** Security scanning occurs at write-time (hooks),
  per-phase (qa security audit), and pre-deploy (dependency audit). Not just at deploy.

## Context as Public Good

Every token loaded into context must justify itself. Prefer lazy-loading over eager-loading.
Skills load their body only when invoked. References load only when needed. Subagents
receive only the context relevant to their specific task, not the full project state.

## Lean Execution, Rich Planning

Planning agents (dev-planner, qa-planner) receive full project context to produce
thorough plans. Execution agents (task-implementer, category-executor) receive only
what they need for one task/category. The plan file on disk is the bridge — rich
context produces a detailed plan, lean context executes one piece at a time.

## Adaptive Complexity

Three implementation tracks: /fix (up to ~15 files, no architectural decisions),
/dev (phase-scoped, spec-driven), /plan+/dev (full feature decomposition).
/fix routes upward when scope exceeds its gate.

## Context Resilience

Context compaction is managed externally:
- PreCompact: saves structured summary (Goal/Progress/Decisions/Next Steps)
- SessionStart(compact): re-injects active skill, phase, task, remaining stages
- Stop: warns if pipeline shows work in-progress

Skills isolate heavy context through subagents:
- /dev: task-implementer (one per task, fresh context each)
- /qa: category-executor (for high-context categories C/E/F)
- Planning subagents (dev-planner, qa-planner) continue unchanged

## Product Design Philosophy

Five principles that govern how the pipeline approaches design and implementation
decisions. These ensure every technical choice is grounded in real user impact.

- **User Journey Simulation.** Design decisions are validated by simulating the
  complete user journey — from discovery to daily use to identity integration.
  When /plan designs phase boundaries, it asks: "What can a user experience after
  this phase?" not just "What works?" Load `user-journey-simulation.md` when
  making phase architecture decisions for user-facing projects.

- **AI Output Determinism.** When designing features powered by AI/LLMs, explicitly
  classify each output's determinism tier: Tier 1 (deterministic — hardcode or
  structured output), Tier 2 (reasoning/synthesis — RAG + guards), Tier 3
  (creative — high temperature + quality gate). The tier drives implementation
  pattern, guard mechanisms, and testing approach. Load `ai-output-determinism.md`
  when planning AI-powered features.

- **Progressive Shippability (Onion Model).** Every phase ships a complete product
  layer, not a slice of a future product. Phase 0 = environment. Phase 1 = simplest
  usable product. Each subsequent phase adds a layer — the product can be displayed
  and used after every phase, progressively richer. A cupcake is a complete thing,
  not a fraction of a wedding cake. When this conflicts with module-based or
  architecture-based decomposition, the skill evaluates which approach better serves
  the specific project and presents options to the user.

- **Version-First Decomposition.** Projects whose vision is so large that it would
  produce 10+ phases decompose into versions first. Version 1 = the simplest viable
  product (3-5 phases). Version 2 adds the next capability layer. Each version is
  independently shippable. /plan detects this at Phase 1b and proposes version
  boundaries to the user instead of a single massive phases.md.

- **Adaptive Testing Strategy.** Different project domains need different testing
  cadences. Hardware/sensor projects test after every task (sim-to-real gap).
  UI/animation projects need human perception checks per change. Standard web apps
  test per phase. /plan detects the project archetype and sizes tasks/phases
  accordingly. Load `testing-strategy-archetypes.md` when classifying projects.

All five principles serve one meta-goal: **stand with users**. Every decision
should be traceable to "what would happen when a real person uses this?"

## Anti-Patterns

- Never skip user approval gates.
- Never assume a library or API has a capability — verify first.
- Never silently drop a pre-mortem Tiger from the phase plan.
- Never proceed with a missing prerequisite — stop and tell the user.

## File Ownership

| File | Writers | Readers |
|------|---------|---------|
| `phases.md` | /plan (create), /dev (checkboxes only) | all pipeline skills |
| `pipeline-state.md` | /plan (create), /dev, /qa, /fix, /deploy (archive) | all skills + hooks |
| `key-learnings/*.md` | /dev (create), /qa (append qa Notes) | /dev, /qa, /fix, /deploy |
| `qa-reports/*.md` | /qa only | /fix, /deploy |
| `README.md` | /dev (create/update), /qa (update if fixes applied) | all skills |
| `fix-log.md` | /fix only | /deploy |
| `deep-knowledge.md` | /update only | all skills (read at entry) |
| `pipeline-constitution.md` | /update only (with ground + consistency check) | all skills (at entry) |

## Skill Entry Protocol

Every skill, as its first action after parsing arguments:

1. Read `pipeline-state.md` at project root (if exists) — verify previous skill
   completed cleanly.

2. Verify skill-specific prerequisites exist:
   - plan: design document or scout discovery report
   - dev: phases.md + key-learnings directory
   - qa: phases.md + completed dev phase
   - fix: (no prerequisites — always available)
   - deploy: phases.md + all phases qa'd (or user-approved exceptions)

4. If anything is missing or inconsistent: stop, explain what's missing, suggest
   the correct skill to run first.

5. **Knowledge capture** (lightweight, at skill completion):
   - dev/qa: write key-learnings, check deep-knowledge for contradictions/extensions
   - fix: append to fix-log.md
   - Others: no action required
