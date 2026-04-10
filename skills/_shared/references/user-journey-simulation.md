# User Journey Simulation Protocol

Simulate the complete user journey during design — from discovery to identity
integration — before writing code. This protocol is loaded by /plan at Phase 3
and by /scout at Stage 4 (deep dive) when relevant.

---

## When to Apply

- **Always**: Projects with a user-facing interface (web, mobile, CLI, desktop)
- **Partial** (Stages 1-4 only): Libraries, packages, developer tools
- **Skip**: Pure infrastructure, data pipelines with no human interaction

---

## The Seven Stages

### Stage 1: Discovery — "How do they find us?"

Map the moment the user first encounters the product:
- **Triggering event**: What frustration or need makes them search?
- **Search terms**: Their words, not your marketing terms
- **First touchpoint**: Landing page, GitHub README, blog post, word-of-mouth?
- **One-sentence promise**: What headline do they read?

JTBD Forces to check:
- Push (frustration with current solution) + Pull (attraction to this one)
  must exceed Anxiety (will it work?) + Inertia (switching cost)

### Stage 2: First Contact — "The first 30 seconds"

Apply cognitive walkthrough:
1. Can the user tell what this does in 5 seconds?
2. Is the primary action obvious and visible?
3. Does the CTA match their mental model?
4. Do they feel momentum after clicking?

Fogg check: Motivation present? Action easy? Prompt visible?

### Stage 3: Onboarding — "Learning without instruction"

Walk the empty state:
- What does the user see when nothing exists yet?
- What's the minimum viable action (so easy motivation is irrelevant)?
- What immediate feedback do they get?
- Is complexity hidden (progressive disclosure)?

Anti-patterns: Setup wizard >3 steps, requiring config before value,
showing empty dashboards, asking for info you don't need yet.

### Stage 4: First Value — "The aha moment"

Define precisely: the moment the user thinks "THIS is why I need this."
- Map every action from signup to aha moment
- Count: how many steps? How many minutes?
- Target: <5 min consumer, <30 min B2B
- What could prevent it? (missing data, need teammates, integration required)

### Stage 5: Habit Formation — "The return loop"

Map the Hook cycle:
- **Trigger**: What brings them back? (external first, then internal emotion)
- **Action**: Simplest thing they do (under 3 taps/clicks)
- **Variable reward**: Unpredictable payoff — social (tribe), info (hunt),
  or progress (self)
- **Investment**: What do they put in that makes next cycle better?
  (data, preferences, content, connections)

Check: What's the natural usage frequency? (daily, weekly, monthly)
If monthly+, you need strong scheduled triggers.

### Stage 6: Mastery — "Beginner to power user"

Three-persona check:
| Dimension | Beginner (Day 1) | Intermediate (Month 1) | Power User (Month 6+) |
|-----------|------------------|------------------------|----------------------|
| Features | Layer 1 only | Layer 1 + some Layer 2 | All layers + API |
| Speed | Slow, exploratory | Competent, purposeful | Fast, muscle memory |
| Value | Core promise | Efficiency gains | Irreplaceability |

Validate: beginner never sees power-user complexity; power user
never feels constrained by beginner guardrails.

### Stage 7: Identity Integration — "Part of me"

Rate 1-5 on five dimensions:
1. **Self-extension**: Does their work/data feel like "theirs" inside the product?
2. **Vocabulary**: Does the product introduce language they use outside it?
3. **Social signaling**: Does using it signal something about who they are?
4. **Community**: Is there a community of users who recognize each other?
5. **Workflow centrality**: Is it at the center of their workflow graph?

---

## Planning-Phase Application

### For /plan Phase 3 (Phase Architecture)

After applying the four decomposition lenses, simulate:
1. What can a user experience after each phase? (not just "what works" but
   "what does it feel like to use?")
2. Is there at least one aha moment reachable by the end of Phase 1?
3. Does each subsequent phase feel like a richer product, not a construction site?

### For /scout Stage 4 (Deep Dive)

When evaluating technology choices:
- How does this choice affect onboarding? (setup complexity, learning curve)
- How does this affect time-to-value? (build time, deploy complexity)
- How does this affect the user's daily experience? (latency, reliability)

### The Taste Audit (Apply at Every Gate)

Five questions for every design artifact:
1. **Conviction**: Does this reflect a clear opinion, or is it a hedge?
2. **Guest test**: Would a new user feel respected encountering this?
3. **Coherence**: Does this feel like it belongs with everything else?
4. **Craft**: Does this feel like someone cared about the details?
5. **Subtraction**: What can be removed without losing function?

---

## Output Artifacts

The simulation produces (concisely — not all are always needed):
1. **JTBD Forces summary** — why users switch (or don't)
2. **Time-to-Value map** — signup to aha, steps and minutes
3. **Hook cycle** — trigger/action/reward/investment loop
4. **Feature layer map** — what surfaces at beginner/intermediate/power user
5. **Friction points** — every point of confusion in the simulated walkthrough

These feed directly into phase architecture decisions.

---

## Relationship to Founder Vision

The simulation validates design choices against actual user scenarios, but
it never overrides the founder's philosophy or taste. When simulation reveals
friction, the response is to resolve it elegantly within the founder's vision —
not to abandon the vision for conventional UX. The goal: "standing with users"
means understanding their reality while maintaining the product's identity.
