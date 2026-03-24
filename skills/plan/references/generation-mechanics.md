# Phase 5: Generation Mechanics

> Reference file for /plan Phase 5. Contains compilation procedure, pipeline state creation,
> port assignment, and summary template extracted from the main workflow.

## Compilation Procedure

1. Compile all approved phases into the final `phases.md` file using `~/.claude/skills/plan/assets/phases-template.md`.

2. The file includes: Header, Design Decisions Log, Environment & Tech Stack Audit, all phase specifications, Critical Files table, Consistency Rules, Key Learnings Protocol, Version Control Protocol.

3. Format for AI agent consumption:
   - Every task instruction uses imperative form with exact file paths (`Create src/lib/auth.ts`, not "set up an auth module")
   - All ACs use Given/When/Then with concrete values (`Given email "test@x.com"`, not "Given valid input")
   - Commands are copy-pasteable (`pnpm add next-auth@^4.24`, not "install an auth library")
   - No hedge words: remove "consider", "as appropriate", "if needed", "you might want to"
   - Error behavior specifies: what the user sees, what the system logs, what state changes

4. Write the file to `{project-root}/phases.md`.

## Pipeline State Creation

Read `~/.claude/skills/_shared/references/pipeline-state-protocol.md`. Create `pipeline-state.md` at the project root.

## Port Assignment

Read `~/.claude/skills/_shared/references/port-registry.md` (if it exists; create it if not). Detect framework, assign lowest available port, write to registry and pipeline-state.md.

## Key-Learnings Directory

Create the `key-learnings/` directory at project root if it doesn't exist.

## Summary Template

Present a final summary using this format:

```
phases.md has been generated at: ./phases.md
Pipeline state created at: ./pipeline-state.md

Summary:
- Total phases: N (Phase 0 + N feature phases)
- Total tasks: X
- Key learnings directory: ./key-learnings/
- Pipeline state: ./pipeline-state.md (all phases NOT STARTED)

Next steps:
- Review phases.md for accuracy
- Invoke /dev 0 to begin Phase 0 implementation
```

---

## Example Invocation

**User**: `/plan feature.md`

**Expected behavior**:
1. Read `feature.md`
2. Present extracted requirements and ask for confirmation
3. Scan environment for required tools
4. Present proposed phase breakdown and get approval
5. Detail each phase with tasks, acceptance criteria, and validation gates
6. Generate `phases.md` at project root
7. Create `pipeline-state.md` at project root
8. Create `key-learnings/` directory
9. Present summary with next steps
