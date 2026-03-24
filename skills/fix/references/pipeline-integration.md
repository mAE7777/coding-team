# Pipeline Integration

How fix interacts with an active plan/dev/qa pipeline. Load at Stage 4 when an active pipeline is detected.

---

## Detecting Active Pipeline

1. Check for `phases.md` at project root
2. If found, scan for task checkboxes:
   - All `- [x]` → pipeline complete, no active phases
   - Mix of `- [x]` and `- [ ]` → pipeline active, identify current phase
   - All `- [ ]` → pipeline exists but no phases started

3. Identify the current phase: the first phase with any `- [ ]` tasks

---

## Key-Learnings Update Protocol

When the fix affects files relevant to the pipeline:

### For completed phases (file was in Phase N, N is done)
- Read `key-learnings/key-learnings-{NN}.md`
- Append a `## Fix Notes` section at the end (before any qa Notes if present)
- This alerts subsequent dev/qa invocations that the codebase changed out-of-band

### For the current active phase
- Read `key-learnings/key-learnings-{NN}.md` if it exists (it may not if dev hasn't completed)
- If key-learnings exists: append `## Fix Notes` section
- If key-learnings does not exist: note in the triage output that the current phase hasn't completed yet — dev will discover the change during codebase analysis

### For future phases (file is in Phase M, M hasn't started)
- Do NOT modify future phase key-learnings (they don't exist yet)
- Instead, add a note to the MOST RECENT existing key-learnings file:
  ```markdown
  ## Fix Notes

  ### {YYYY-MM-DD}: {description}
  - Changed `{file}`: {what changed}
  - Relevant to Phase {M}: {what the phase implementor needs to know}
  ```

---

## Fix Notes Format

```markdown
## Fix Notes

### {YYYY-MM-DD}: {brief description}
- Changed `{file path}`: {what was changed and why}
- Impact on this phase: {what the dev/qa agent needs to know}
- Verification: {how to confirm the fix doesn't break this phase's work}
```

If multiple fixes accumulate, append each as a new `###` subsection under the same `## Fix Notes` header.

---

## What NOT to Modify

- **Never edit `phases.md`** — phase definitions are owned by /plan
- **Never edit qa reports** — qa reports are owned by /qa
- **Never check off tasks in phases.md** — task completion is owned by /dev
- **Only append to key-learnings** — never modify existing sections, only add the Fix Notes section
