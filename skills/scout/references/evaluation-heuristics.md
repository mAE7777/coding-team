# Technology Evaluation Heuristics

Red flags and maturity signals for technology assessment. Load at Stage 2
alongside research-methodology.md.

---

## Red Flags (investigate further if detected)

| Signal | Threshold | What It Means |
|--------|-----------|---------------|
| Major version churn | >3 major bumps in 2 years | Unstable API surface — integration cost will compound |
| Bus factor | Single maintainer + >5K weekly npm downloads | One departure breaks ecosystem |
| Maintenance stall | Last release >12 months + >100 open issues | Likely abandoned; security patches unlikely |
| Sponsor volatility | Corporate sponsor removed/changed within 12 months | Funding model unstable |
| Hype-maturity gap | "experimental"/"alpha" in README but >1K GitHub stars | Community enthusiasm exceeds production readiness |
| Documentation debt | >50% of API surface undocumented | Integration cost higher than it appears |
| Breaking change cadence | Breaking changes in minor/patch versions | Semver violations — pinning won't protect you |

## Green Flags (increase confidence)

| Signal | Threshold | What It Means |
|--------|-----------|---------------|
| Multiple maintainers | 3+ active committers in last 6 months | Bus factor mitigated |
| Corporate adoption | 2+ known production users at scale | Battle-tested beyond demos |
| LTS policy | Documented long-term support commitment | Safe for multi-phase projects |
| Migration guides | Official guides for each major version | Upgrade path exists |
| TypeScript native | Written in TypeScript (not just @types/) | Type safety at source, not bolted on |

## Application

During Stage 2 research, check each candidate against these signals. In the
comparison table, flag detected red flags as Active findings with `[!]` marker.
Green flags strengthen confidence tags (M→H) when corroborated by T1/T2 sources.

A candidate with 2+ red flags and 0 green flags warrants an explicit risk
callout in the comparison table — even if other dimensions look strong.
