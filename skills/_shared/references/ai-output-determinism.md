# AI Output Determinism Classification

When designing AI-powered features, explicitly classify each output's determinism
requirement and choose the implementation approach accordingly. Loaded by /plan
at Phase 4 and /scout at Stage 4 when the project involves AI/LLM features.

---

## The Three Tiers

### Tier 1: Deterministic (same input → same output)

**Use cases**: Data extraction, classification, structured parsing, form filling,
entity recognition, schema validation, code formatting.

**Users expect**: Machine-like consistency. Running twice gives the same result.

**Implementation patterns**:
- Structured output mode (provider-native JSON schema enforcement)
- Temperature: 0.0-0.2, Top-p: 0.1-0.3
- Schema validation + re-ask on failure (max 2-3 retries)
- Deterministic post-processing (normalize, lowercase, dedup)
- Enum constraints for classification tasks
- For truly deterministic needs: consider hardcoding or rule-based systems
  with LLM as fallback only

**Guard mechanisms**:
- Pydantic/JSON Schema validation layer
- Re-ask pattern: on validation failure, re-prompt with error message
- Fallback to rule-based system when confidence < threshold

**Failure modes**:
| Mode | Mitigation |
|------|-----------|
| Schema violations | Provider-native structured outputs |
| Inconsistent enum values | Constrained decoding + normalization |
| Extraction hallucination | Few-shot examples + "if not found, return null" |
| Batch-dependent drift | Accept ~95-99% consistency; validate on top |

**Key truth**: Temperature=0 does NOT guarantee determinism. Batched GPU
inference introduces floating-point variation. Design for "consistent enough"
with a deterministic validation layer on top.

### Tier 2: Reasoning/Synthesis (grounded, thoughtful, minor variation OK)

**Use cases**: Summaries, analysis, recommendations, explanations, comparisons,
code review, debugging suggestions.

**Users expect**: Thoughtful, factually accurate. Wording can vary; facts cannot.

**Implementation patterns**:
- Temperature: 0.3-0.7
- RAG (Retrieval-Augmented Generation) for grounding
- Citation requirements (Perplexity pattern: inline citations, not post-hoc)
- Chain-of-thought + verification step
- Task decomposition (break complex analysis into focused subtasks)
- Self-consistency (3-5 samples + majority vote) for high-stakes

**Guard mechanisms**:
- **Fact-check layer**: Run extracted claims through verification
- **Confidence thresholds**: Model rates confidence per claim; flag low for human review
- **Contradiction detection**: Second call asking "does this contain contradictions?"
- **Citation enforcement**: Every claim must reference a retrieved source
- **Guardian agent**: Lightweight model monitoring for hallucination patterns

**Failure modes**:
| Mode | Mitigation |
|------|-----------|
| Hallucination | RAG grounding + citation requirements |
| Sycophancy | Adversarial prompting ("challenge assumptions") |
| Inconsistent reasoning | Self-consistency (3-5x) + majority vote |
| Overconfidence | Explicit uncertainty calibration prompts |

### Tier 3: Creative (users WANT different results every time)

**Use cases**: Brainstorming, content generation, art, naming, ideation,
storytelling, exploration.

**Users expect**: Novelty, surprise, diversity. Same prompt = different results.

**Implementation patterns**:
- Temperature: 0.7-1.2
- Top-p: 0.9-1.0
- Frequency/presence penalties: 0.3-0.8 (fight mode collapse)
- Generate N candidates, present to user or auto-select best
- Prompt variation (randomized elements, different angles/personas)
- Verbalized sampling (ask model to verbalize probability distribution first)

**Guard mechanisms**:
- Content safety filters (pre and post generation)
- Quality scoring on candidates before presenting
- Style consistency via strong persona instructions
- Coherence check (cap temperature if output becomes nonsensical)

**Failure modes**:
| Mode | Mitigation |
|------|-----------|
| Mode collapse (samey outputs) | Frequency penalties + verbalized sampling |
| Loss of coherence | Cap temperature; use top-p < 1.0 as safety net |
| Style inconsistency | Strong persona in system prompt + few-shot |

---

## The Determinism Router (Architecture Pattern)

Mature AI products don't pick one tier — they classify and route:

```
User request → Task classifier (Tier 1, low temp)
                      |
           +----------+-----------+
           |          |           |
     Tier 1       Tier 2       Tier 3
     Extract    Reason+Cite    Generate
     Validate   Verify         Filter+Score
           |          |           |
           +----------+-----------+
                      |
                  Response
```

---

## Planning Application

### For /plan Phase 4 (Task Specification)

When a task involves AI-generated output:
1. Classify the output tier (1/2/3)
2. Add the tier to the task notes: `AI output: Tier {N} ({type})`
3. Include the corresponding guard mechanism in the task's ACs
4. If Tier 1: add AC for validation layer (schema check, re-ask)
5. If Tier 2: add AC for grounding (RAG source, citation, fact-check)
6. If Tier 3: add AC for quality gate (content filter, coherence check)

### For /scout Stage 4 (Deep Dive)

When evaluating AI integration approaches:
- What tier does each AI feature need?
- Does the chosen model/API support the required tier?
  (e.g., structured outputs, function calling, streaming)
- What's the cost profile? (Tier 2 with self-consistency = 3-5x cost)
- What's the latency impact? (multi-sample adds latency)

### Decision Framework

| Question | If YES | If NO |
|----------|--------|-------|
| Must output match a schema exactly? | Tier 1 + structured outputs | Tier 2 or 3 |
| Can factual error cause harm? | Tier 2 + self-consistency + human review | Single generation sufficient |
| Do users want variety? | Tier 3 + generate-and-select | Tier 1 or 2 |
| Is latency critical? | Single generation, Tier 1 | Multi-sample OK |
| Is the domain narrow? | Fine-tuning + constrained decoding | General model + RAG |

---

## The Uncomfortable Truths

1. True determinism from LLMs is impossible. Design for "consistent enough" +
   deterministic validation layer.
2. LLM confidence scores are poorly calibrated. Don't use verbalized confidence
   for high-stakes decisions without external calibration.
3. The winning architecture is always LLM + deterministic code. LLM for the
   fuzzy part, code for the hard part.
4. Multi-sample methods work but cost linearly. Budget accordingly.
5. Mode collapse from RLHF is the silent killer of creative features.
