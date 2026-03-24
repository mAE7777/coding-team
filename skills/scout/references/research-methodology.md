# Research Methodology

Source evaluation criteria, search strategies, and evidence quality standards for scout Stage 2.

---

## Source Quality Tiers

### Tier 1: Primary Sources (highest confidence)
- Official documentation (via Context7)
- Official migration guides and changelogs
- Project README and source code
- npm/PyPI/crates.io package metadata (download counts, last publish date)

### Tier 2: Secondary Sources (good confidence)
- Benchmark results with reproducible methodology
- Technical blog posts from recognized organizations (Vercel, Google, Meta, etc.)
- Conference talks with code examples
- Stack Overflow answers with high vote counts

### Tier 3: Tertiary Sources (supporting evidence only)
- Community blog posts and tutorials
- Reddit/HN discussions
- Twitter/social media discussions
- AI-generated content (flag as needing verification)

**Rule**: Never base a recommendation solely on Tier 3 sources. Every recommendation needs at least one Tier 1 or Tier 2 source.

---

## Search Strategies

### Technology Evaluation
1. Context7 first: fetch docs for each candidate
2. WebSearch for `"{technology} vs {alternative} {current-year}"` — recent comparisons
3. WebSearch for `"{technology} production experience"` — real-world usage reports
4. WebSearch for `"{technology} known issues"` — problems to anticipate

### Brownfield Codebase Analysis
1. `project-analyzer` subagent for broad overview
2. `code-explorer` subagent for targeted system analysis
3. Grep for framework/library usage patterns
4. Read config files for version constraints
5. Read test files for established testing patterns

### Migration Research
1. Context7 for target version docs and migration guide
2. WebSearch for `"migrate {package} {from-version} to {to-version}"`
3. WebSearch for `"{package} {to-version} breaking changes"`
4. GitHub issues search for migration-related bugs

---

## Evidence Quality Standards

### For Trade-off Tables
- **Complexity**: Count files, components, or concepts involved. "Low/Med/High" must map to specific criteria.
- **Performance**: Cite benchmark source. If no benchmark exists, say "No data available" rather than guessing.
- **Ecosystem maturity**: npm download count, GitHub stars, last release date, number of maintainers. All verifiable.
- **Risk**: Specific scenarios, not vague "it might break." Each risk has a likelihood and impact.

### For Recommendations
- Cite at least 2 supporting evidence points
- Acknowledge the strongest counterargument
- State the confidence level: "High confidence (multiple sources agree)" vs "Moderate confidence (limited data)"

### For Architecture Sketches
- Every component must map to a concrete file or module
- Every data flow must specify the transport (HTTP, WebSocket, in-memory, etc.)
- Every integration point must identify the API or interface

---

## Evidence Freshness

Different research claims decay at different rates. Tag evidence with a
freshness class alongside the source tier:

| Freshness Class | Decay Rate | Examples | Stale After |
|----------------|-----------|---------|-------------|
| VOLATILE | Months | API pricing, rate limits, free tier quotas | 6 months |
| MODERATE | Quarters | Community size, download counts, maintainer count | 12 months |
| STABLE | Years | Architecture patterns, protocol specs, language features | 36 months |

**Rules**:
- VOLATILE evidence older than 6 months: re-verify via WebSearch before citing.
  If unverifiable, mark [STALE] in the comparison table.
- Flag any recommendation that depends primarily on VOLATILE evidence — it may
  not survive to implementation.
- STABLE evidence needs no freshness check.
- When two sources conflict, prefer the more recent one — unless the older
  source is higher-tier AND the claim is STABLE-class.
