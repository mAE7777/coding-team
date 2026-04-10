# Request Emission Guide

How skills identify and emit requests when they encounter gaps they can't resolve.

---

## When to Emit

- **Blocking condition**: The skill cannot complete its current task without a
  capability that doesn't exist. Example: /scout needs to analyze a proprietary
  framework but has no documentation source for it.

- **Repeated workaround**: The skill has worked around the same limitation multiple
  times across sessions. Example: /fix consistently encounters architectural issues
  beyond its scope that require the same kind of analysis.

- **Missing capability**: The skill identifies a category of work it should support
  but can't. Example: /absorb encounters a source type it can't process (video
  transcript, audio file).

## When NOT to Emit

- **One-off edge case**: The gap occurred once in unusual circumstances and is
  unlikely to recur. Don't create bureaucracy for anomalies.

- **User preference**: The user chose not to use a capability, not that the
  capability is missing. Don't request what the user declined.

- **Already documented**: The gap is in the skill's brain.md Gaps section and has
  a known workaround. Only emit if the workaround is insufficient.

- **Scope boundary**: The skill correctly redirected to another skill (e.g., /fix
  redirecting to /plan). This is working as designed, not a gap.

## How to Write a Good Request

1. **Specific gap**: Not "needs better research" but "cannot access library X
   documentation when version Y introduces breaking API changes."

2. **Evidence**: Include the actual failure — error output, what was tried, what
   the user had to do manually. Concrete, not abstract.

3. **Suggested resolution**: The skill's best guess. This guides /craft but
   doesn't constrain it. "A reference file with common migration patterns for
   framework X" is better than "make the skill smarter."

4. **Impact**: Who benefits? "Any skill that encounters framework X" is more
   useful than "this skill sometimes."

## Where to Write

Path: `~/.claude/skills/_shared/requests/pending/{YYYY-MM-DD}-{source}-{brief}.md`

Example: `2026-02-21-scout-proprietary-framework-docs.md`

## Workflow Integration

Emitting a request does NOT interrupt the current workflow:

1. Identify the gap
2. Work around it (or mark the relevant output as [UNVERIFIED])
3. Write the request to `pending/`
4. Continue the current task
5. Mention the request in the skill's completion output

The request is a signal for future improvement, not a blocking condition for
the current session.
