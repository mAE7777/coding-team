# Pre-Mortem Protocol — scout Integration

Scout-specific integration layer for pre-mortem analysis.
The universal framework lives in the shared reference; this file defines
how scout feeds its research into the framework and how the output
connects to /plan.

---

## Framework

Load: `~/.claude/skills/_shared/references/pre-mortem-framework.md`

All principles, scenario generation, Tiger classification, mitigation design,
and Elephant monitoring protocols are defined there.

---

## Scout-Specific Source Priority

When populating the framework's Source Hierarchy (Section 2):

1. **Stage 2-4 research findings** (highest confidence — already have evidence
   from this scout investigation)
2. **Targeted WebSearch** (per shared framework query templates)
3. **Structural reasoning** (per shared framework)

---

## Integration with /plan

The pre-mortem output feeds directly into /plan phase design:

### Tigers with Mitigations → /plan Phase Constraints

Each Tiger mitigation becomes either:
- An **in-scope item** added to a specific phase
- A **task** within an existing phase
- A **constraint** that limits how a phase can be implemented

/plan reads these from the `## Tiger Mitigations (RED → GREEN)` section and maps each to a phase.

### Elephants with Tripwires → /plan Validation Gate Criteria

Each Elephant tripwire becomes a **validation gate check** in the relevant phase:
- Added to the phase's "Validation Gates" section
- Format: "Verify {condition} is still within acceptable range"

/plan reads these from the `## Elephant Monitoring` section.

### Unresolved Risks → /plan Open Questions

Failure scenarios where no mitigation was designed become:
- Items in the phases.md "Open Questions" section
- /dev must escalate if these risks are encountered during implementation

/plan reads these from the `## Unresolved Risks` section.

### Cross-Reference Checklist

/plan Phase 3 performs this verification:
1. Read `discovery/premortem-*.md`
2. For each Tiger: confirm a phase or task addresses it
3. For each Elephant: confirm a validation gate checks for it
4. Report gaps: "Pre-mortem cross-check: {N}/{M} Tigers addressed. Gaps: {list}"
