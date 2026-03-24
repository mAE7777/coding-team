# Complexity Routing

After Phase 1 extraction, compute a complexity score to determine workflow path.

## Complexity Signals

From Phase 1 findings:
- +1 per 5 requirements extracted (rounded down)
- +1 per distinct technology beyond the primary framework
- +1 if external API integrations exist
- +2 if auth, payments, data migrations, or multi-service architecture involved
- +1 if >1 deployment target

## Routes

| Route | Score | Behavior |
|-------|-------|----------|
| **Quick** | ≤ 3 | Lightweight path — reduced ceremony, same output quality |
| **Standard** | 4–7 | Full workflow |
| **Deep** | ≥ 8 | Amplified verification — more spot-checks, mandatory risk tagging, research escalation |

## Procedure

1. Compute and present the complexity score with breakdown.
2. Announce the route: "**Quick Path** (score: N)", "**Standard Path** (score: N)", or "**Deep Path** (score: N)".
3. User can always override to any tier.

## Quick Path Changes

Standard is the baseline. Quick adjusts:
- **Phase 2**: Detect ONLY primary runtime + package manager (2-3 commands). Skip Layer 2 (project manifest) and Layer 3 (common tools) from the environment scanning guide. Record as "Quick Scan" in phases.md.
- **Phases 3+4**: Collapse into a single pass — present all phases at once instead of one-by-one. Still apply Decomposition Framework lenses.
- **Phase 4b**: Skip honesty check (few enough claims that spot-checking isn't needed).
- **Phase 4c**: Scan extraction list for DROPPED items only — skip full classification table.
- **All HALTs preserved**: User authority is never reduced.

## Deep Path Changes

Amplifies Standard, no new stages:
- **Phase 3 Risk Lens**: Applied on all phases even when pre-mortem exists (Standard skips when pre-mortem covers risk).
- **Phase 4b**: Max spot-checks raised from 5 to 10. Spawn deep-researcher for inconclusive results before marking [UNVERIFIED].
- **Phase 4c**: Enhanced — also verify each COVERED item's AC actually tests the requirement.
