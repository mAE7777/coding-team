# Pre-Mortem Analysis: {Topic}

**Date:** {YYYY-MM-DD}
**Approach Under Test:** {selected approach from Stage 3}
**Time Horizon:** {6 months / 1 year}
**Linked Discovery Report:** discovery/discovery-{slug}.md

---

## Failure Premise

"It is {time horizon} after launch. The project has failed completely.
Here is why."

---

## Failure Test Set

### Market/Product

| ID | Scenario | Evidence | Classification | Confidence |
|----|----------|----------|----------------|------------|
| M-01 | {scenario} | {source} | Tiger/Paper Tiger/Elephant | High/Med/Low |

### Technical

| ID | Scenario | Evidence | Classification | Confidence |
|----|----------|----------|----------------|------------|
| T-01 | {scenario} | {source} | Tiger/Paper Tiger/Elephant | High/Med/Low |

### Execution

| ID | Scenario | Evidence | Classification | Confidence |
|----|----------|----------|----------------|------------|
| E-01 | {scenario} | {source} | Tiger/Paper Tiger/Elephant | High/Med/Low |

### Environment

| ID | Scenario | Evidence | Classification | Confidence |
|----|----------|----------|----------------|------------|
| V-01 | {scenario} | {source} | Tiger/Paper Tiger/Elephant | High/Med/Low |

---

## Threat Summary

| Classification | Count | Action Required |
|----------------|-------|-----------------|
| Tiger | {N} | Mitigation designed |
| Paper Tiger | {N} | Documented as non-threat |
| Elephant | {N} | Monitoring tripwire set |

---

## Tiger Mitigations (RED → GREEN)

### {ID}: {Scenario title}

**Threat:** {specific failure scenario}
**Evidence:** {what research supports this}
**Mitigation:** {minimum viable change that prevents this failure}
**Affects feat Phase:** {which phase this constrains}
**Validation Criterion:** {how to verify mitigation works}

{repeat for each Tiger}

---

## Paper Tiger Documentation

### {ID}: {Scenario title}

**Apparent Threat:** {what it looks like}
**Why It's Not Real:** {counter-evidence}

{repeat for each Paper Tiger}

---

## Elephant Monitoring

### {ID}: {Scenario title}

**Latent Risk:** {what nobody's talking about}
**Tripwire:** {measurable condition that means this became a Tiger}
**When to Check:** {during which feat phase or dev stage}

{repeat for each Elephant}

---

## Unresolved Risks

{Failure scenarios where no mitigation is possible yet.
These become Open Questions for feat.}

---

## feat Integration Checklist

- [ ] Each Tiger mitigation is reflected as a phase constraint or task
- [ ] Each Elephant tripwire is reflected as a validation gate criterion
- [ ] Unresolved risks are included in phases.md Open Questions
