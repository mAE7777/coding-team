# Stack Knowledge Packs

Language and framework-specific knowledge for the coding pipeline.
Loaded by /plan, /dev, /qa, and /deploy when the project's stack is detected.

## How it works

1. **/plan Phase 2** detects the project's language/framework from manifests
2. **/plan Phase 3** loads the matching stack pack and applies conventions as phase constraints
3. The detected stack is recorded in `phases.md` → `## Project Strategy` → `Stack Pack:` field
4. **/dev** and **/qa** pre-read the stack pack when spawning subagents
5. **/deploy** uses the Toolchain and Deploy sections for build/test/publish commands

If no pack exists for a language, the pipeline runs normally — these are additive enhancements, not requirements.

## Template

Each file follows this structure. Keep to 200-350 lines. Focus on what Claude gets wrong, not what the language is.

```markdown
---
name: {language-or-framework}
detection: [manifest files or extensions that signal this stack]
archetype: A|E|F  (testing archetype — A=standard, E=compiled, F=mobile)
---

# {Name} — Stack Knowledge

## Conventions
Naming, project structure, import ordering, error handling philosophy.
Focus on opinionated choices that produce consistent, production-grade code.

## Toolchain
Build, test, lint, format, security audit, and doc generation commands.
These are the defaults /deploy uses when no project-specific commands exist.

## Safety Patterns
Language-specific safety concerns Claude should watch for.
Memory safety, concurrency, type safety, etc.

## Anti-Patterns
What Claude commonly gets wrong for this language. Each entry:
- BAD: what Claude generates
- GOOD: the correct idiom
- WHY: one sentence on why it matters

## Testing Patterns
Framework, patterns (table-driven, fixture-based, etc.), coverage tools.

## Deploy Patterns
Publish workflow, CI verification, distribution targets.
```

## Adding a new stack pack

1. Create `{name}.md` in this directory following the template above
2. If it needs a new testing archetype, add to `testing-strategy-archetypes.md`
3. If it has a deploy target, add to `deploy/references/deployment-targets.md`
4. No pipeline code changes needed — detection is manifest-based

## Naming conventions

- Language packs: `python.md`, `rust.md`, `go.md`, `cpp.md`
- Framework packs: `swift-ios.md`, `kotlin-android.md`, `python-django.md`, `java-spring.md`
- Framework packs are loaded IN ADDITION to language packs when both match

## What NOT to put here

- Generic language tutorials (Claude already knows the language)
- Syntax references (Claude doesn't need a cheat sheet)
- Opinions without justification (every rule needs a "why")
