---
name: plan
description: "Generate structured phases.md files from project plans or designs. Use when the user says /plan, 'create phases', 'generate feature phases', 'make phases.md', 'plan this', or wants to transform a design document into implementable development phases with environment checks, validation gates, and key-learnings integration. /plan is the canonical name; /feat is a deprecated alias."
argument-hint: "<path-to-plan-or-design-file>"
---

# plan — Feature Phase Generator

> **EXECUTABLE WORKFLOW** — not reference material. Execute stages in order.
> Do not skip stages. Do not proceed without user confirmation at gates.

Transform a project plan or design document into a structured, AI-agent-consumable `phases.md` file with environment audits, validation gates, and key-learnings integration.

---

## How I Think

I think as a translator, not an architect. The user's design document is the source
of truth — my job is faithful extraction, not creative enhancement. When I encounter
a requirement, I trace it to its source section. When I encounter ambiguity, I surface
it via AskUserQuestion — I never resolve it silently.

My discipline has two modes: Extraction (Phases 1-3) surfaces what the design says.
Annotation (Phase 4b onward) marks what it doesn't say with [UNVERIFIED] markers.
The mode shift is mechanical: Phase 3 approval triggers it, not my judgment. Every
stage I execute, I ask: am I extracting or annotating? If annotating before Phase 4b,
I've drifted.

---

---

## Decomposition Framework

Four lenses generate the decomposition during Phase 3 — not a post-hoc checklist.
Full procedures, exhaustive consumer tracing rules, and failure catalog in
`~/.claude/skills/plan/references/decomposition-framework.md` (loaded at Phase 3).

**Value Lens**: "What can a user DO after this is built?" — groups requirements
into candidate phases by user capability. No user-facing action = not a phase.

**Dependency Lens**: Trace what must exist before each phase works. Cascade-critical
items (3+ dependents) get priority placement + exhaustive consumer grep.

**Risk Lens**: HIGH RISK categories get additional validation gates testing the
failure path:

| Category | Example |
|----------|---------|
| Auth / identity | Session, tokens, RBAC |
| External APIs | Third-party services, webhooks |
| Data migrations | Schema changes, backfill scripts |
| Payments | Billing, subscriptions, refunds |
| Irreversible operations | Deletes, sends, publishes |
| Shell command construction | `exec`/`spawn` with user-derived args |
| Unbound array operations | `Math.max(...arr)` stack overflow |
| Type assertion without runtime validation | `as T` on external data without guard |
| Version-specific tool behavior | Breaking changes between major versions |
| Error message forwarding | Raw `error.message` in fallthrough catch |

If >50% HIGH RISK, recommend /scout pre-mortem. Standard: skip when pre-mortem
exists. Deep: always apply.

---

## Workflow

**Entry**: Execute the Skill Entry Protocol (pipeline-constitution.md, "Skill Entry Protocol" section).

### Phase 1: Input Analysis

0. Read `~/.claude/skills/_shared/owner-profile.md` (if it exists). Use the owner's design philosophy, technical preferences, and constraints to inform phase architecture and technology choices. If the file does not exist, skip this step silently.

1. Read the file at `$ARGUMENTS` path. If no path was provided, use `AskUserQuestion` to ask the user for the path to their plan or design file.

1a. Verify prerequisites: design document or scout discovery report must exist.
    Read pipeline-state.md (if exists) and present context to user.

1b. **Steal-doc detection**: Glob at project root for `steal-*.md`, `reference-*.md`,
    `port-*.md`, and similar patterns. If any found:
    - Read each steal/reference document
    - Extract items with their section numbers and types:
      - **Code-portable**: API signatures, data schemas, algorithms, formulas, constants,
        configuration patterns (items with concrete code that should be ported verbatim)
      - **Design-pattern**: Architecture decisions, module boundaries, naming conventions,
        workflow patterns (items describing how to organize, not what to copy)
    - Extract all "Preserve" / "Don't change" / "Keep" directives — these are hard
      constraints that must survive into phases.md verbatim
    - Store as `{steal_items}` for use in Phases 3, 4, and 4b-4c
    - Announce: "Found {count} steal/reference documents with {item_count} items
      ({code_portable} code-portable, {design_pattern} design-pattern)"
    If no steal/reference documents found: skip silently.

2. **Three-pass extraction** (Extraction Mode — surface what's there, nothing else):

   | Pass | Action | Output |
   |------|--------|--------|
   | 1. Inventory | Read section by section. For each, extract: functional requirements ("must", "should", "will", "users can"), technology choices (package names, version pins), architecture decisions ("server/client", API patterns), UI specs (layouts, interactions), deployment targets, external dependencies, and constraints ("no X", "must use Y"). One item per line. | Raw item list with source location (section heading) per item |
   | 2. Dependency trace | For each item, identify what depends on it and what it depends on. Flag items with 3+ dependents as **cascade-critical**. For cascade-critical items in an existing codebase: `Grep` for all references to surface files that would break if the item changes. | Annotated list with dependency counts |
   | 3. Gap scan | For each cascade-critical item, verify the document specifies: error behavior, cleanup/rollback, and integration boundaries. Missing specs go to the Unspecified list. | Specified / Unspecified split ready for step 3 |

3. Categorize findings into **Specified** and **Unspecified** lists.

→ **GATE**: Present extraction to user via `AskUserQuestion`. Stop if no document or user rejects.

### Phase 1b: Complexity Routing

Load `~/.claude/skills/plan/references/complexity-routing.md`. Compute a complexity
score from Phase 1 findings. Three tiers: Quick (≤3), Standard (4-7), Deep (≥8).
Each tier adjusts preprocessing, risk tagging, spot-check limits, and research
escalation. User can always override.

### Phase 1c: Project Strategy Classification

Before Phase 2, classify the project on three dimensions that shape all
downstream decisions. These classifications persist into phases.md metadata.

1. **Version decomposition check**: Count the total extracted requirements from Phase 1.
   If the extraction list suggests 10+ phases (rough: >30 requirements, >3 major feature
   areas, or design doc exceeds 15 pages):
   - Propose version decomposition to the user via `AskUserQuestion`:
     "This project's scope suggests {N} phases. I recommend decomposing into versions:
     Version 1 = simplest shippable product ({suggested scope}), then Version 2 adds
     {next layer}. Plan one version at a time? Or plan all phases in one document?"
   - If user chooses versions: scope the current planning run to Version 1 only.
     Add a `## Version Roadmap` section to phases.md (brief — version titles + scope).
   - If user prefers single document: proceed normally but flag phases 8+ as higher risk.

2. **Testing archetype detection**: Load `~/.claude/skills/_shared/references/testing-strategy-archetypes.md`.
   Scan the extraction list and design document for archetype signals:
   - Hardware/sensor keywords → Archetype B (test-every-step)
   - Animation/audio/perception keywords → Archetype C (test-at-perception-points)
   - ETL/pipeline/transformation patterns → Archetype D (test-at-boundaries)
   - Standard web/CLI/API → Archetype A (test-after-phase, default)
   If mixed: assign archetypes per subsystem. If uncertain: present detection to user
   via `AskUserQuestion` with detected signals and ask for confirmation.
   Record the archetype — it affects Phase 3 task sizing and Phase 4 gate design.

3. **AI feature classification** (if applicable): If the extraction list includes
   AI/LLM-powered features, load `~/.claude/skills/_shared/references/ai-output-determinism.md`.
   For each AI feature, classify the output determinism tier:
   - Tier 1: Deterministic (extraction, classification, structured parsing)
   - Tier 2: Reasoning/synthesis (summaries, analysis, recommendations)
   - Tier 3: Creative (generation, brainstorming, content creation)
   Record tiers — they affect Phase 4 task specifications (guard mechanisms in ACs).

→ Proceed to Phase 2 (Quick or Standard).

### Phase 2: Environment & Tech Stack Scan

1. Identify ALL required tools and technologies.

2. For any open technology choices, use `AskUserQuestion` to present options.

3. Run detection commands for every identified tool. Follow `~/.claude/skills/plan/references/environment-scanning-guide.md`.

3b. **Package name validation** (if deployment target is npm): If the project will publish to npm (`"bin"`, `"main"`, `"exports"` in package.json, or design mentions npm publish), validate the intended package name NOW — before any code is written. Run `npm publish --dry-run` (not just `npm view`) to catch both taken names and npm's similarity/typosquatting rejection. If the name fails, resolve with `AskUserQuestion` before proceeding. This prevents a costly full-project rename at deploy time.

4. Record results as a structured table.

5. Present findings. For MISSING or WRONG_VERSION tools, use `AskUserQuestion`.

6. Record in Design Decisions Log.

→ **GATE**: Present environment findings via `AskUserQuestion`. Stop if critical tools missing with no resolution.

### Phase 3: Phase Architecture Design

Apply behavioral modifiers from entry to phase constraints: if modifiers emphasize security or compliance, apply the Risk Lens to ALL phases regardless of tier; if modifiers emphasize speed or MVP, use Quick tier spot-check limits even when score routes to Standard.

0. Read `~/.claude/skills/_shared/deep-knowledge.md` (if it exists). Search for entries matching technologies or patterns from the Phase 1 extraction list. Apply matching entries as additional phase constraints or validation gate criteria.

1. Load `~/.claude/skills/plan/references/decomposition-framework.md`. Apply the
   four lenses to the Phase 1 extraction list — each candidate phase answers one
   question a user would ask: "Can I do X?" The lenses translate the user's capability
   needs into phase boundaries; I generate decomposition candidates, the user validates.
   Then refine following `~/.claude/skills/plan/references/phase-design-principles.md`.

1a. **Onion Model validation**: After generating candidate phases, verify the
    Progressive Shippability principle: can a user experience the product as a
    complete (if simple) thing after Phase 1? Does each subsequent phase add a
    layer rather than build a disconnected piece? If any phase only makes sense
    when combined with a later phase, merge them or reorder. The goal: a user
    could stop after any phase and have something usable.
    Exception: when the project's architecture genuinely requires module-based or
    layer-based decomposition (e.g., a compiler: lexer → parser → codegen), present
    both onion and module-based options to the user with trade-offs.

1b. **User journey simulation** (Standard/Deep tier, user-facing projects):
    Load `~/.claude/skills/_shared/references/user-journey-simulation.md`.
    For the proposed phase architecture, simulate:
    - After Phase 1: Can a user discover, onboard, and reach first value?
    - After each subsequent phase: Does the user experience feel richer, not
      like a construction site?
    - Is the "aha moment" reachable by the end of Phase 1?
    Run the Taste Audit (5 questions from the reference) on the first-contact
    surface that Phase 1 produces. Note friction points as task-level notes.
    Quick tier: skip — simulate mentally, no formal output.

1c. **Testing strategy application**: Use the archetype from Phase 1c to size tasks:
    - Archetype B/C: Max 2-4 tasks per phase, shorter duration, manual verification
      gates between tasks (not just at phase end)
    - Archetype D: Include verification at each transformation boundary
    - Archetype A: Standard sizing (3-6 tasks per phase)

1d. If `discovery/premortem-*.md` exists: cross-reference Tigers with phase plan.

1e. **Final cross-validation phase** (versions with 5+ feature phases):
    After all feature phases are designed, append a final phase titled
    "Cross-Validation" (or "V{N} Cross-Validation" if versioned). This phase
    verifies the complete version against all source-of-truth documents —
    catching accumulated drift that per-phase qa misses.

    Include tasks based on project characteristics (skip irrelevant ones):

    | Task | Condition | What it checks |
    |------|-----------|----------------|
    | Reference doc compliance | Project has steal/reference docs | Code-portable items match source APIs; design-pattern params match "Preserve"/"Don't change" sections; deviations documented in key-learnings |
    | Architecture compliance | Project has architecture doc | Module dependency rules enforced; component boundaries match spec; no undocumented cross-module imports |
    | Security compliance | Project has security doc | Every defense layer from security doc is implemented or explicitly deferred; threat model coverage |
    | Cross-phase integration | Always (5+ phases) | All modules communicate correctly; shared types consistent; no broken imports across module boundaries |
    | Key-learnings consistency | Always (5+ phases) | No contradictions across key-learnings files; Phase 1 conventions still hold in final phase |
    | Design completeness | Always | Every requirement from original design doc is implemented or explicitly deferred with rationale |
    | Full E2E validation | Always | End-to-end user journey works with all subsystems active |

    This phase has no implementation tasks — only audit and verification tasks.
    Its validation gates are the audit results themselves. `/qa` for this phase
    runs the audits; `/dev` generates the audit report.

    For versions with <5 phases: skip this phase (per-phase qa is sufficient).

2. If multiple valid decompositions exist, use `AskUserQuestion` to present options.
   When the testing archetype is B or C, also ask: "This project involves
   {hardware/perception}. Should I design phases for incremental testing
   (recommended) or batch testing?"

→ **GATE**: Present proposed breakdown via `AskUserQuestion`. Stop if user rejects decomposition.

### Phase 4: Detailed Phase Specification

For each approved phase, generate detailed specification. Present each phase to the user for review before moving to the next.

**For each phase, specify**: Goal, Context, Scope, Tasks (with ACs in Given/When/Then), Validation Gates, Key Learnings Checkpoint.

**AI feature tasks**: If a task involves AI-generated output (classified in Phase 1c),
add to the task notes: `AI output: Tier {N} ({type})`. Include the tier-appropriate
guard mechanism in the ACs:
- Tier 1: AC for schema validation and retry logic
- Tier 2: AC for grounding source / citation check / fact verification
- Tier 3: AC for content quality gate and coherence check

**Testing archetype overlay**: For Archetype B/C projects, include per-task verification
instructions (not just phase-level gates). Each task should specify what to verify
manually and how (e.g., "Flash firmware, verify sensor reading within 5% of expected").

**Steal constraints** (when `{steal_items}` exists from Phase 1 step 1b): For each task
that implements a steal/reference item, include a `Steal:` block in the task notes:

    Steal: steal-memory.md §3.2 (code-portable)
    Preserve: "decay rates: bridge=0.025, confirmed=0.025, regular=0.05, shallow=0.075"
    Preserve: "time-proportional formula: confidence * (1.0 - rate * days_since_last_use)"
    Verify: decay() reads last_used field from semantic_memories table
    Verify: rate constants match values above exactly

Rules for Steal blocks:
- **Code-portable items**: Copy "Preserve" directives verbatim from the steal doc —
  these are the literal values, formulas, or API signatures that must appear in code.
  Do NOT rephrase, summarize, or interpret. The exact text from the steal doc goes here.
- **Design-pattern items**: Describe the pattern with a "Verify" line specifying what
  the implementation must demonstrate (e.g., "Verify: all tool calls route through
  ToolExecutor, not called directly from orchestrator")
- **Every "Preserve"/"Don't change"/"Keep" directive** from the steal doc MUST appear
  as a Preserve line in the corresponding task's Steal block. Missing a Preserve
  directive is a completeness failure caught in Phase 4c.
- **Verify lines** are manual integration checks derived from Preserve directives
  (e.g., if steal says "Preserve: BM25 weight 0.3", Verify line is "Verify: search
  combines vector and BM25 scores with BM25_WEIGHT=0.3")

Incorporate user feedback on each phase before proceeding to the next.

### Phase 4b: Annotation Mode — Specification Honesty Check

Extraction is complete. From here, every addition is interpretation — marked so
the user sees where translation ends and opinion begins. The mode shift is
mechanical: triggered by Phase 3 approval, not by judgment.

Before presenting each phase, mark where the specification crosses from extraction
to interpretation:

1. Cross-reference every technical detail against source documents.

1b. Cross-reference architectural pattern claims (e.g., "never expose X to users",
   "all errors go through handler Y"). Verify the phase tasks enforce the pattern
   in every code path — including catch blocks and fallthrough cases.

1c. **Steal cross-reference audit** (when `{steal_items}` exists): This is the PRIMARY
   gate against substitution errors — where the planner describes a different mechanism
   than what the steal doc specifies.

   For each task with a `Steal:` block, compare the task's narrative description
   (ACs, notes, file descriptions) against the referenced steal-doc section:

   | Check | What it catches | Action |
   |-------|----------------|--------|
   | Algorithm match | Task says "cosine similarity" but steal says "BM25" | STEAL_DEVIATION: substitution |
   | Parameter match | Task says "decay rate 0.01" but steal says "0.025" | STEAL_DEVIATION: wrong constant |
   | Schema match | Task omits a field that steal doc defines | STEAL_DEVIATION: missing field |
   | Preserve fidelity | Task rephrases a Preserve directive instead of quoting it | STEAL_DEVIATION: lossy compression |

   For each STEAL_DEVIATION found:
   - Mark it: `[STEAL_DEVIATION: {type} — task says "{task_text}", steal says "{steal_text}"]`
   - Present ALL deviations to user in a batch before proceeding
   - User resolves each: **fix** (update task to match steal) or **override** (document
     intentional deviation with rationale in task notes)

   Zero deviations → proceed. Any unresolved deviation → STOP.

2. **Feasibility Spot-Check**: For each technology named in the design document with a specific
   usage claim ("use Library X for feature Y"):
   - One Context7 or WebSearch query to confirm the capability exists
   - If confirmed: no marker needed
   - If contradicted: mark as [FEASIBILITY_RISK: {library} may not support {feature} —
     {what research found}]. Present to user before proceeding.
   - If inconclusive AND tier is Standard or Deep: spawn deep-researcher before marking.
     Use `Task` tool (subagent_type: `general-purpose`) with prompt:
     `"Research whether {library} supports {feature}. Check official docs, GitHub issues,
     and Stack Overflow. Return: confirmed/contradicted/still-inconclusive with sources."`
     - If deep-researcher resolves: use its finding (no [UNVERIFIED] marker needed).
     - If still inconclusive: mark as [UNVERIFIED: feasibility not confirmed despite research]
   - If inconclusive AND Quick tier: mark as [UNVERIFIED] with note "feasibility not confirmed"
   Limit: max 5 spot-checks (Quick/Standard), max 10 (Deep). Prioritize claims about
   unfamiliar libraries or capabilities you haven't used before. Skip well-known patterns
   (React components, Express middleware, standard SQL).

3. Mark every detail added without a source section:
   `[UNVERIFIED: not in source documents — included because {reason}]`

3. Count markers: 0-5 is fine. 6+ → STOP and batch-resolve with user.

### Phase 4c: Completeness Verification

Compare the final phases against the source extraction to catch dropped requirements.
This is a mechanical diff of two lists, not a judgment call.

1. Retrieve the Phase 1 extraction list (raw item list from three-pass extraction).

2. Walk each extracted item. Classify:

   | Code | Meaning | Action |
   |------|---------|--------|
   | COVERED | Maps to a specific task in a specific phase | Record the phase.task reference |
   | DEFERRED | Explicitly out-of-scope with reasoning | Verify deferral appears in a phase's Out-of-scope |
   | DROPPED | Not in any phase or deferral | Flag for user review |

3. Present: `Completeness: {covered}/{total} covered, {deferred} deferred, {dropped} dropped.`

4. If any DROPPED items: use `AskUserQuestion` — "These requirements from the design
   are not covered. Add to an existing phase, create a new phase, or defer explicitly?"

4b. **Steal completeness** (when `{steal_items}` exists): Walk each steal item from
   Phase 1 step 1b. Classify:

   | Code | Meaning | Action |
   |------|---------|--------|
   | COVERED | Has a `Steal:` block in a specific task | Record the phase.task reference |
   | DEFERRED | Explicitly out-of-scope with reasoning | Verify deferral documented |
   | DROPPED | No `Steal:` block, not deferred | Flag for user review |

   Present: `Steal completeness: {covered}/{total} covered, {deferred} deferred, {dropped} dropped.`

   Also verify: every "Preserve"/"Don't change" directive from the steal docs appears
   as a Preserve line in some task's Steal block. Missing Preserve directives are
   flagged as DROPPED regardless of whether the parent item is COVERED.

   If any DROPPED: use `AskUserQuestion` — "These steal items are not covered.
   Add to existing task, create new task, or defer explicitly?"

5. Zero DROPPED items → proceed to Phase 5.

→ **OUTPUT**: All phases specified, verified complete against extraction list.

### Phase 5: Generate phases.md

Follow `~/.claude/skills/plan/references/generation-mechanics.md` for compilation, pipeline-state
creation, port assignment, key-learnings directory, and summary template.

**Translator's Summary** (present to user before writing files):

```
Translator's Summary:
- Items extracted: {count} ({specified} specified, {unspecified} unspecified)
- Design decisions deferred to user: {count}
- Feasibility spot-checks: {conducted}/{confirmed}/{marked-unverified}
- Cascade-critical items traced: {count}
- [UNVERIFIED] markers remaining: {count}
- Completeness: {covered}/{total} covered, {deferred} deferred, {dropped} dropped
```

→ **OUTPUT**: phases.md and pipeline-state.md written, key-learnings directory created.

---

## Reference Files

- `~/.claude/skills/plan/references/phases-md-specification.md` — Complete schema for phases.md
- `~/.claude/skills/plan/references/environment-scanning-guide.md` — Command matrix for tool detection
- `~/.claude/skills/plan/references/key-learnings-protocol.md` — Key-learnings lifecycle
- `~/.claude/skills/plan/references/phase-design-principles.md` — Decomposition rules and anti-patterns
- `~/.claude/skills/plan/references/decomposition-framework.md` — Four lenses + failure catalog. Load at **Phase 3**.
- `~/.claude/skills/plan/references/complexity-routing.md` — Scoring, routes, tier changes. Load at **Phase 1b**.
- `~/.claude/skills/_shared/references/pipeline-state-protocol.md` — Pipeline state format. Load at **Phase 5**.
- `~/.claude/skills/plan/references/generation-mechanics.md` — Compilation, state, port, summary template. Load at **Phase 5**.
- `~/.claude/skills/_shared/references/testing-strategy-archetypes.md` — Four testing archetypes + detection algorithm. Load at **Phase 1c**.

---

## Example Invocation

See `~/.claude/skills/plan/references/generation-mechanics.md` for a full example walkthrough.
