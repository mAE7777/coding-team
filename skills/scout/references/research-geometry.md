# Research Geometry & Investigation Workflows

Dimension-first research methodology and per-type workflows for scout Stage 2.

---

## Research Geometry

Do NOT research candidate-by-candidate (Candidate A then Candidate B then compare).
This anchors on the first candidate and biases the evaluation.

Instead, decompose into orthogonal research questions and research each across
ALL candidates simultaneously:

1. **Decompose**: From the key questions in Stage 1, derive 3-5 orthogonal
   research dimensions. Common dimensions:
   - Feasibility: Can this work within our constraints?
   - Ecosystem maturity: Is this production-ready or experimental?
   - Integration cost: How much existing code must change?
   - Scaling ceiling: Where does this approach break?
   - Failure modes: How does this approach fail?

2. **Research per dimension, not per candidate**: For each dimension, research
   ALL candidates in a single pass. Use one WebSearch/Context7 session per
   dimension, comparing candidates side-by-side. This makes comparison the
   organizing principle, not an afterthought.

3. **Synthesize through the comparison matrix**: The comparison table in Stage 3
   is not a summary — it's the primary research artifact. Each cell is filled
   during research, not after.

For Standard/Full tier: if a dimension requires deep investigation, spawn one
subagent per dimension (not per candidate) to prevent anchoring.

---

## Investigation Type Workflows

### Greenfield

1. Use Context7 to fetch current documentation for candidate technologies.
2. Use `WebSearch` for recent benchmarks, known issues, community adoption, prior art.
3. Check for reference implementations.

### Brownfield

1. Invoke `project-analyzer` subagent (via Task tool with `subagent_type: "project-analyzer"`) to generate comprehensive codebase analysis.
2. Invoke `feature-dev:code-explorer` subagent to trace specific systems relevant to the research topic.
3. Identify constraints from the codebase.
   Present the constraint map to the user before proceeding to options — constraints first, then possibilities.

### Migration

1. Invoke `migration-planner` subagent if available.
2. Research migration guides and community experiences via `WebSearch` and Context7.

### Evaluation

1. For each candidate: Context7 docs + `WebSearch` for benchmarks and ecosystem maturity.
2. Build comparison matrix with objective criteria.

---

## Extended Research (Full tier or insufficient evidence)

If WebSearch + Context7 produce insufficient or contradictory results, spawn
deep-researcher via `Task(subagent_type="general-purpose")` with the prompt
referencing `~/.claude/agents/deep-researcher.md` and the specific claim needing
multi-source triangulation.

If deep-researcher returns dense material, extract the key trade-offs, benchmarks,
and maturity signals relevant to the research question.
