# Deep Dive Protocol — Analyst Brief

For the selected approach from Stage 3, produce an analyst brief covering all items below.

---

## 0. Assumptions Register

List every assumption underlying this approach.
For each: what breaks if this assumption is wrong? The analyst's first
job — make the implicit explicit.

## 1. Technology Specifics

Use Context7 for detailed documentation of the selected technology stack.

## 2. Architecture Sketch

Design the high-level architecture:
- Every component maps to a concrete file or module
- Every data flow specifies the transport (HTTP, WebSocket, in-memory, etc.)
- Every integration point identifies the API or interface

## 3. Dependency List

Identify specific libraries with exact versions. For each:
- Purpose and justification
- License compatibility
- Last release date and maintenance status

## 4. Risk Mitigation

For each identified risk, provide a specific mitigation strategy.
Mitigations must be minimum-viable — the simplest change that neutralizes the threat.

## 5. Unresolved Unknowns

List items that could not be confirmed even with research:
- "[item]: searched [sources], found [partial/nothing]. Risk: [impact if wrong]."

These feed into [UNVERIFIED] markers in /plan Phase 4b.
If no unknowns remain, state "All claims verified" explicitly.

## 6. Phase Estimation

Rough breakdown of how many /plan phases this work likely requires.
Map major capabilities to phases with complexity ratings (Low/Med/High).

## 7. Decision Consequences

What doors does this approach close? What future options does it preserve?
Describe downstream implications for /plan — what becomes easier, what becomes harder,
what becomes impossible.
