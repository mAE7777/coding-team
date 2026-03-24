# Research Architecture

Structural patterns that shape how scout organizes research. Complements
research-methodology.md (source quality) and research-geometry.md (dimension-first method).

---

## 1. Research Blocking Conditions

When any condition is detected during Stage 2 or Stage 3, halt research and present the
issue to the user. Format: Detection / Present / Resume.

### 1.1 Contradictory Primary Sources

**Detection**: Two T1/T2 sources give opposing answers for the same research dimension.

**Present**:
```
BLOCKED: Contradictory primary sources

Dimension: {dimension name}
Source A ({tier}): {claim A} — {citation}
Source B ({tier}): {claim B} — {citation}

These sources directly contradict each other on a critical dimension.
```

**Resume**: User decides which to trust, or scout runs deeper research
(additional WebSearch queries targeting the specific contradiction).

### 1.2 Evidence Vacuum

**Detection**: A comparison table cell for a critical dimension has only T3 or no data.
Includes unfetchable/paywalled sources as a sub-type.

**Present**:
```
BLOCKED: Evidence vacuum

Dimension: {dimension name}
Searched: {queries run}
Found: {only T3 sources / nothing / paywalled content at {URL}}

No T1/T2 evidence exists for this critical dimension.
```

**Resume**: User accepts LOW confidence for that dimension, or provides
access/alternative sources. If accepted, mark cell [UNVERIFIED].

### 1.3 Stale-Dependent Recommendation

**Detection**: >50% of Active findings supporting the recommendation are tagged
VOLATILE (per research-methodology.md freshness classes) with source dates >6 months.

**Present**:
```
BLOCKED: Recommendation rests on stale evidence

Stale evidence:
- {finding 1}: VOLATILE, sourced {date} — {what would change if outdated}
- {finding 2}: VOLATILE, sourced {date} — {what would change if outdated}

{N}% of Active findings supporting this recommendation are stale.
```

**Resume**: Re-verify via fresh WebSearch, or user accepts the staleness risk.

### 1.4 Scope Explosion

**Detection**: Research question count exceeds tier threshold.
Quick: 5 | Standard: 8 | Full: 12.

**Present**:
```
BLOCKED: Scope explosion — {N} questions exceed {tier} threshold of {limit}

Core questions:
{numbered list of core questions}

Derivative questions:
{numbered list of derivative questions}

Prune derivative questions, or escalate tier?
```

**Resume**: User prunes questions, or tier escalates.

### 1.5 Confirmation Bias Detection

**Detection**: No source contradicts the Stage 1 hypothesis after the
dimension-research pass. All evidence uniformly supports the hypothesis.

**Present**:
```
BLOCKED: Confirmation bias risk

Hypothesis: {hypothesis from Stage 1}
Evidence: {N} sources examined, zero counter-evidence found.

Uniform agreement is suspicious. Running adversarial queries before proceeding.
```

**Resume**: Run 2 targeted adversarial queries:
1. "why does {hypothesis} fail?"
2. "{alternative} advantages over {favored}"

If adversarial queries find counter-evidence, incorporate it. If they confirm
the hypothesis, proceed with added confidence and note the adversarial check.

**Quick-tier exception**: Confirmation Bias Detection and Scope Explosion are
inactive during Quick tier. Quick is capped at 3 queries and has no hypothesis
to confirm against.

---

## 2. Finding Lifecycle

Three tiers based on decision impact. Orthogonal to evidence freshness
(temporal decay from research-methodology.md).

- **Active**: Contradicts prior assumptions, introduces new constraints, or represents
  a critical decision factor. Full text preserved in deliverable. Marked with `[!]`
  in comparison table cells.

- **Collapsed**: Confirms existing knowledge or supports without surprising.
  One-line citation in comparison table.

- **Unresolved**: Couldn't confirm or deny. Marked `[UNVERIFIED]`, feeds /plan
  Phase 4b markers.

A finding can be Active+VOLATILE (critical but potentially stale) — highest urgency
for verification. A finding can be Collapsed+STABLE (confirms known, long-lived fact) —
lowest urgency. The two classifications are independent.

---

## 3. Topic Sensitivity Classification

Keyword scan on topic and key questions at start of Stage 2:

- **HIGH**: vendor lock-in, data migration, security model, regulatory, payment
  processing, user data, single point of failure
- **NORMAL**: everything else

HIGH triggers:
1. Adversarial source verification — find evidence AGAINST favored candidate
2. Mandatory T1 citation for every HIGH-dimension claim
3. +1 research query per HIGH dimension

---

## 4. Question Completeness Check

Integrated into Stage 1 step 4b key question formulation:

Key questions must cover all three angles:
- **Stakeholder**: Who is affected and what do they need answered?
- **Constraint**: What is fixed, what is negotiable, what is unknown?
- **Comparison**: What dimensions differentiate candidates for THIS context?

If any angle has zero questions, add one before proceeding.

---

## 5. Finding Propagation Protocol

Findings don't just populate tables — their tags reshape downstream stage structure.
Each stage boundary has a propagation rule that determines what the next stage
receives and how it adapts.

### 5.1 Stage 2 → Stage 3: Tag-Driven Cell Depth

Finding lifecycle + confidence determine how each comparison cell is rendered:

| Lifecycle | Confidence | Cell treatment |
|-----------|------------|----------------|
| Active | HIGH/MEDIUM | Full text in cell |
| Active | LOW | Full text + `[!L]` flag — low-confidence active finding |
| Collapsed | any | One-line citation (default) |
| Unresolved | any | `[UNRESOLVED]` marker — cannot support recommendation |

**Row-level gate**: If >50% of cells in a comparison row are LOW or Unresolved,
prefix the row with `[WEAK]`. Weak rows are excluded from the recommendation
basis — they inform but don't decide.

### 5.2 Stage 3 → Stage 4: Uncertainty Profile

Stage 3 produces an uncertainty profile struct passed to the Deep Dive:

```
Uncertainty Profile:
  strong_basis: {dimensions where all cells are Active+HIGH/MEDIUM}
  contested: {dimensions with contradictory Active findings}
  weak_spots: {dimensions with [WEAK] rows}
  volatile_deps: {Active findings tagged VOLATILE}
```

Stage 4 Deep Dive adapts based on this profile:
- **volatile_deps** → explicit assumption entries in the assumptions register
  ("Assumes {finding} remains true; last verified {date}")
- **weak_spots** → [UNVERIFIED] markers on any architecture decisions depending
  on weak dimensions
- **contested > strong_basis** → add "Contested Evidence" subsection documenting
  both sides before architecture decisions

### 5.3 Stage 4 → Stage 6: Profile-Shaped Deliverable

The uncertainty profile determines deliverable structure:

| Profile shape | Deliverable adaptation |
|---------------|----------------------|
| strong_basis ≥ 80% | Standard report structure |
| weak_spots present | Add "Verification Needed" section listing weak dimensions and what would resolve them |
| contested > strong_basis | Use "Tentatively recommended" language; add "Evidence Conflicts" section |
| strong_basis < 50% | Flag for deeper research; report clearly states insufficient evidence for confident recommendation |

The analyst self-check (Stage 6 step 0) verifies that the report structure
matches the uncertainty profile. A high-confidence profile with hedging language
is as wrong as a low-confidence profile with confident language.
