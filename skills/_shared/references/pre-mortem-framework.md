# Pre-Mortem Framework

Universal pre-mortem analysis methodology. Any skill can load this framework
to generate failure scenarios, classify threats, design mitigations, and
monitor unresolved risks.

---

## 1. Theoretical Foundation

**Why pre-mortem works**: Prospective hindsight — imagining an event has already occurred — increases the ability to identify reasons for future outcomes by 30% (Mitchell, Russo & Pennington 1989, cited in Gary Klein's HBR 2007 "Performing a Project Premortem").

Key principles:

- **Klein's Pre-Mortem**: Instead of asking "what could go wrong?", assume the project has already failed and ask "why did it fail?" This subtle reframing bypasses optimism bias and activates different cognitive pathways.

- **Kahneman's Bias Correction**: Pre-mortems counteract two biases that plague project planning: (1) overconfidence in the chosen approach, and (2) groupthink that suppresses dissent. By making failure the premise, dissent becomes the task.

- **Munger's Inversion**: "Tell me where I'm going to die, so I'll never go there." Instead of only planning for success, systematically identify failure modes and design around them.

- **Doshi's Tiger Framework** (Shreyas Doshi, ex-Stripe/Google PM): Classify threats into Tigers (real threats requiring action), Paper Tigers (apparent threats that aren't real), and Elephants (real threats nobody's talking about). This prevents both over-reaction to noise and under-reaction to hidden risks.

**TDD Analogy**: Pre-mortem maps to Test-Driven Development at the project level:

| TDD for Code | Pre-Mortem for Projects |
|---|---|
| Write a failing test (RED) | Imagine the project failed — list all the reasons why |
| Make it pass with minimal work (GREEN) | For each failure mode, design the minimum viable mitigation |
| Refactor | Prioritize and integrate mitigations into the plan |

---

## 2. Failure Scenario Generation Protocol

### Source Hierarchy

Generate failure scenarios in this order of priority:

1. **Prior research findings**: Risks, limitations, known issues, and trade-offs already identified during earlier research. These are the highest-confidence scenarios because they have direct evidence.

2. **Targeted WebSearch**: Search for real-world failures in the same domain and technology. Use the query templates below.

3. **Structural reasoning**: Infer risks from the architecture, dependency chain, or market positioning — even without direct evidence. These become Elephant candidates.

### WebSearch Query Templates

Run 3-5 of these searches, adapted to the specific project:

- `"{technology} project failures"` / `"{technology} common mistakes"`
- `"{technology} production issues"` / `"{technology} scaling problems"`
- `"{domain} startup post-mortem"` / `"why {similar product} failed"`
- `"{technology} migration regrets"` / `"{technology} vs {alternative} real world"`
- `"{domain} lessons learned"` / `"{technology} pitfalls {current year}"`

### Scenario Requirements

- **Minimum**: 15 scenarios
- **Maximum**: 25 scenarios (beyond this, consolidate similar scenarios)
- **Spread**: Cover all 4 categories (Market/Product, Technical, Execution, Environment). Minimum 3 per category.

### Scenario Format

Each scenario must include:

| Field | Requirement |
|-------|-------------|
| **ID** | Category prefix + number: M-01, T-01, E-01, V-01 |
| **Category** | Market/Product, Technical, Execution, or Environment |
| **Scenario Description** | Specific failure narrative — what happened and why |
| **Evidence Source** | Citation from prior research or WebSearch result |
| **Classification** | Tiger, Paper Tiger, or Elephant (assigned in step 3) |
| **Confidence** | High (multiple sources), Medium (single source), Low (structural inference) |

### Specificity Requirement

Every scenario must be grounded in evidence. Compare:

- **Bad**: "The API might be slow" — vague, no evidence, not actionable
- **Good**: "API response times will exceed 2s under 100 concurrent users because {technology} has documented throughput limits of 50 req/s per instance [Source]" — specific, evidenced, testable

### Category Definitions

**Market/Product** (M-xx): Failure from outside the codebase
- Competition kills us, timing is wrong, users don't want this, market too small, positioning unclear, pricing wrong, regulatory changes

**Technical** (T-xx): Failure from within the codebase
- Architecture doesn't scale, dependency becomes unmaintained, performance is unacceptable, integration complexity explodes, security vulnerability in core dependency, data model can't support future features

**Execution** (E-xx): Failure from how we build it
- Scope creep beyond phases, critical skill gap, timeline impossible, coordination overhead, underestimated migration effort, testing infrastructure inadequate

**Environment** (V-xx): Failure from deployment and operational context
- Deployment target limitations, cost exceeds budget, compliance/security blockers, infrastructure constraints, monitoring gaps, third-party SLA insufficient

---

## 3. Tiger Classification Criteria

Apply these criteria to each scenario after generation:

### Tiger

A genuine threat that requires mitigation.

**Criteria** (must meet BOTH):
- **Evidence score >= 2**: At least two independent sources support this risk (research findings, WebSearch results, codebase analysis, or structural reasoning)
- **Impact is project-threatening**: If this risk materializes, it causes significant rework, pivot, or project failure — not just inconvenience

**Examples**:
- "Vercel serverless functions have a 10s execution timeout, and our video processing takes 30-60s" (documented limitation + architecture mismatch)
- "The free tier API has a 60 req/min rate limit, and our batch processing needs 500 req/min" (pricing page + usage estimate)

### Paper Tiger

Looks threatening but evidence shows it's manageable.

**Criteria**:
- Initial concern exists (someone would reasonably worry about this)
- BUT counter-evidence shows it's not a real threat in this context

**Documentation requirement**: Explain WHY it's not real. This prevents future panic when someone raises the same concern later.

**Examples**:
- "Redis memory limits" is a Paper Tiger when the entire dataset fits in 50MB
- "React re-render performance" is a Paper Tiger for a dashboard with 20 components

### Elephant

A real risk that nobody mentioned during research. Surface it explicitly.

**Criteria**:
- No direct evidence was found during prior research (nobody discussed it)
- BUT structural or systemic patterns suggest the risk exists
- Often found by asking: "What did nobody talk about?" or "What assumption are we making that we haven't validated?"

**Examples**:
- "Nobody discussed what happens when the free API tier runs out during development"
- "The design assumes stable internet, but the target users are in areas with intermittent connectivity"
- "No one mentioned who maintains this after launch"

---

## 4. Mitigation Strategy Requirements

For each Tiger, design a mitigation that meets ALL of these criteria:

### Structure

| Field | Requirement |
|-------|-------------|
| **What changes** | Specific modification to the approach, architecture, or plan |
| **Which phase it affects** | Map to an estimated phase from the investigation |
| **Validation criterion** | How to verify the mitigation works — must be testable |

### Minimum Viable Mitigation

Design the **simplest change** that neutralizes the threat. Not the most comprehensive — the simplest.

- If a dependency has a known vulnerability: pin to a safe version (not "build a custom alternative")
- If an API has rate limits: add rate limiting middleware (not "build a queue system with retry logic and dead letter handling")
- If a deployment target has memory limits: profile and optimize the critical path (not "rewrite in Rust")

### Escalation Flag

If a mitigation requires ANY of the following, flag it prominently — it may change the selected approach:

- Adding a major new dependency not in the original plan
- Changing the core architecture pattern
- Adding a new infrastructure component
- Significantly increasing the phase count

Format: `ESCALATION: This mitigation changes the selected approach. {description of change}`

---

## 5. Elephant Monitoring Protocol

For each Elephant, define a **tripwire** — a specific, measurable condition that, if observed, means the Elephant has become a Tiger.

### Tripwire Format

| Field | Requirement |
|-------|-------------|
| **Measurable condition** | Specific number, threshold, or observable event |
| **When to check** | During which phase or stage |
| **Action if triggered** | What to do — typically pause and re-evaluate |

### Examples

- "If API costs exceed $50/month during development testing, the Elephant 'API cost at scale' has become a Tiger" → Check at end of Phase 2 → Pause and evaluate alternative APIs
- "If build times exceed 60 seconds after Phase 1, the Elephant 'build tool scalability' has become a Tiger" → Check at Phase 1 validation → Evaluate build caching or tool switch
- "If no one on the team has touched the auth code in 30 days, the Elephant 'knowledge concentration risk' has become a Tiger" → Check at Phase 3 → Pair programming session
