# Claude Code Pipeline — Setup Instructions

You are helping a user install the Claude Code Pipeline into their system.
This file contains everything you need to guide them through the process.

---

## Step 1: Ask the User

Before doing anything, ask the user:

> **Where would you like to install the pipeline?**
>
> - **Global** (recommended) — installs to `~/.claude/`. Available in all projects.
> - **Project-local** — installs to `.claude/` in the current project directory. Only available in this project.
>
> Global is recommended for most users — the pipeline works across all your projects.

Wait for their answer before proceeding.

---

## Step 2: Determine Paths

Based on their choice, set the base directory:

- **Global**: `~/.claude/`
- **Project-local**: `.claude/` (relative to current working directory)

All paths below use `{BASE}` as placeholder for whichever they chose.

---

## Step 3: Check for Conflicts

Before copying, check if any of these already exist:
- `{BASE}/skills/scout/`
- `{BASE}/skills/plan/`
- `{BASE}/skills/dev/`
- `{BASE}/skills/qa/`
- `{BASE}/skills/fix/`
- `{BASE}/skills/deploy/`
- `{BASE}/agents/dev-planner.md`
- `{BASE}/agents/task-implementer.md`
- `{BASE}/hooks/guard-dangerous-commands.sh`

If conflicts exist, tell the user which files already exist and ask:

> Some pipeline files already exist. Should I overwrite them, or skip existing files?

---

## Step 4: Copy Files

Copy the following files from this repository into `{BASE}/`. Preserve the directory structure exactly.

### Skills (6 directories)

```
skills/scout/SKILL.md
skills/scout/references/brownfield-analysis-guide.md
skills/scout/references/deep-dive-protocol.md
skills/scout/references/evaluation-heuristics.md
skills/scout/references/research-architecture.md
skills/scout/references/research-geometry.md
skills/scout/references/research-methodology.md
skills/scout/assets/discovery-template.md

skills/plan/SKILL.md
skills/plan/references/complexity-routing.md
skills/plan/references/decomposition-framework.md
skills/plan/references/environment-scanning-guide.md
skills/plan/references/generation-mechanics.md
skills/plan/references/key-learnings-protocol.md
skills/plan/references/phase-design-principles.md
skills/plan/references/phases-md-specification.md
skills/plan/assets/phases-template.md

skills/dev/SKILL.md
skills/dev/references/blocking-conditions.md
skills/dev/references/key-learnings-creation-guide.md
skills/dev/references/plan-mode-protocol.md
skills/dev/references/sensitivity-heuristics.md
skills/dev/references/task-execution-protocol.md
skills/dev/references/validation-and-recovery.md
skills/dev/assets/key-learnings-template.md

skills/qa/SKILL.md
skills/qa/references/adversarial-review-protocol.md
skills/qa/references/blocking-conditions.md
skills/qa/references/regression-and-coverage-strategy.md
skills/qa/references/test-generation-protocol.md
skills/qa/references/ui-ux-validation-protocol.md
skills/qa/assets/qa-report-template.md
skills/qa/assets/test-plan-template.md

skills/fix/SKILL.md
skills/fix/references/pipeline-integration.md
skills/fix/references/root-cause-catalogs.md
skills/fix/references/triage-criteria.md

skills/deploy/SKILL.md
skills/deploy/references/checklist-generation-guide.md
skills/deploy/references/deployment-failure-patterns.md
skills/deploy/references/deployment-targets.md
skills/deploy/assets/release-checklist-template.md
```

### Shared References and Config

```
skills/_shared/references/pipeline-constitution.md
skills/_shared/references/pipeline-state-protocol.md
skills/_shared/references/testing-strategy-archetypes.md
skills/_shared/references/ai-output-determinism.md
skills/_shared/references/user-journey-simulation.md
skills/_shared/references/request-emission-guide.md
skills/_shared/references/port-registry.md
skills/_shared/references/stacks/README.md
skills/_shared/references/stacks/rust.md
skills/_shared/references/stacks/python.md
skills/_shared/references/stacks/go.md
skills/_shared/references/stacks/swift-ios.md
skills/_shared/ground.md
skills/_shared/owner-profile.md
```

**Important**: For `ground.md` and `owner-profile.md`, do NOT overwrite if they already exist — they contain user data.

### Agents (8 files)

```
agents/category-executor.md
agents/deep-researcher.md
agents/dev-planner.md
agents/migration-planner.md
agents/project-analyzer.md
agents/qa-planner.md
agents/security-auditor.md
agents/task-implementer.md
```

### Hooks (7 files)

```
hooks/guard-dangerous-commands.sh
hooks/post-edit-typecheck.sh
hooks/reinject-pipeline-state.sh
hooks/save-pipeline-state.sh
hooks/scan-written-code.sh
hooks/suggest-compact.sh
hooks/verify-pipeline-completion.sh
```

After copying hooks, make them executable: `chmod +x {BASE}/hooks/*.sh`

---

## Step 5: Configure Hooks in settings.json

The hooks need to be registered in `{BASE}/settings.json`. If the file already exists, **merge** the hooks section — do not overwrite other settings.

The required hooks configuration:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "{BASE_WITH_TILDE}/hooks/guard-dangerous-commands.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "{BASE_WITH_TILDE}/hooks/scan-written-code.sh"
          },
          {
            "type": "command",
            "command": "{BASE_WITH_TILDE}/hooks/suggest-compact.sh"
          }
        ]
      },
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "{BASE_WITH_TILDE}/hooks/post-edit-typecheck.sh"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "{BASE_WITH_TILDE}/hooks/save-pipeline-state.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "{BASE_WITH_TILDE}/hooks/reinject-pipeline-state.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "{BASE_WITH_TILDE}/hooks/verify-pipeline-completion.sh"
          }
        ]
      }
    ]
  }
}
```

Where `{BASE_WITH_TILDE}` is:
- Global: `~/.claude`
- Project-local: `.claude` (relative path)

---

## Step 6: Personalize

Tell the user:

> The pipeline is installed. One file benefits from your personal info:
>
> **`{BASE}/skills/_shared/owner-profile.md`** — Your role and tech preferences. High-level skills (scout, plan) read this to tailor recommendations.
>
> Want me to help you fill it in now, or would you rather do it later?

If they want help now, ask them:
1. What's your role? (e.g., fullstack engineer, student, founder)
2. What's your primary tech stack? (e.g., React Native, Swift/SwiftUI, Flutter, etc.)
3. What's your preferred package manager? (npm, pnpm, yarn, bun)
4. What do you deploy to? (App Store, Google Play, Vercel, etc.)
5. Any strong preferences? (testing framework, dark/light mode, etc.)

Then update `owner-profile.md` with their answers.

---

## Step 7: Verify Installation

Run these checks and report results:

1. **File count**: Verify all pipeline files exist in their expected locations (6 SKILL.md + 31 skill references + 7 skill assets + 14 shared files + 8 agents + 7 hooks; minus install.sh/README.md/SETUP.md/settings.json which stay in the repo)
2. **Hook permissions**: Verify all 7 hooks are executable (`ls -la {BASE}/hooks/*.sh`)
3. **Settings merge**: Verify hooks are registered in `{BASE}/settings.json`
4. **Quick smoke test**:
   - Read `{BASE}/skills/scout/SKILL.md` — verify it loads
   - Read `{BASE}/skills/_shared/references/pipeline-constitution.md` — verify shared refs accessible
   - Read `{BASE}/agents/dev-planner.md` — verify agents accessible
   - Run `bash {BASE}/hooks/guard-dangerous-commands.sh` with safe input — verify clean exit

Report the results as a checklist:

> **Installation verified:**
> - [x] Skills installed (scout, plan, dev, qa, fix, deploy)
> - [x] Shared references installed (constitution, state protocol, testing archetypes)
> - [x] 8 agents installed
> - [x] 7 hooks installed and executable
> - [x] Settings configured with hooks
> - [x] Owner profile ready for personalization
>
> You're ready to go. Start with `/scout` to research, or `/plan` to generate phases from a design doc.

If any check fails, diagnose and fix the issue before completing.

---

## Step 8: Show File Locations

At the end, always show this reference:

> ### Installed File Locations
>
> **Skills** — use these slash commands in Claude Code:
> ```
> {BASE}/skills/scout/SKILL.md       — /scout  (research & discovery)
> {BASE}/skills/plan/SKILL.md        — /plan   (phase generation)
> {BASE}/skills/dev/SKILL.md         — /dev N  (phase implementation)
> {BASE}/skills/qa/SKILL.md          — /qa N   (phase validation)
> {BASE}/skills/fix/SKILL.md         — /fix    (bug fixes)
> {BASE}/skills/deploy/SKILL.md      — /deploy (deployment & release)
> ```
>
> **Agents** — invoked automatically by skills:
> ```
> {BASE}/agents/dev-planner.md       — planning (opus model)
> {BASE}/agents/task-implementer.md  — task execution (sonnet model)
> {BASE}/agents/qa-planner.md        — test planning (opus model)
> {BASE}/agents/category-executor.md — test execution (sonnet model)
> {BASE}/agents/security-auditor.md  — security scanning
> {BASE}/agents/project-analyzer.md  — codebase analysis
> {BASE}/agents/migration-planner.md — migration planning
> {BASE}/agents/deep-researcher.md   — deep research
> ```
>
> **Hooks** — run automatically during sessions:
> ```
> {BASE}/hooks/guard-dangerous-commands.sh  — blocks dangerous bash commands
> {BASE}/hooks/scan-written-code.sh         — security scan on writes
> {BASE}/hooks/post-edit-typecheck.sh       — TypeScript check on edits
> {BASE}/hooks/suggest-compact.sh           — context management reminder
> {BASE}/hooks/save-pipeline-state.sh       — state preservation
> {BASE}/hooks/reinject-pipeline-state.sh   — state recovery
> {BASE}/hooks/verify-pipeline-completion.sh — completion check
> ```
>
> **Shared Config** — personalize these:
> ```
> {BASE}/skills/_shared/owner-profile.md                    — your role & preferences
> {BASE}/skills/_shared/ground.md                           — 4 ground rules
> {BASE}/skills/_shared/references/pipeline-constitution.md — core principles
> {BASE}/skills/_shared/references/pipeline-state-protocol.md — state management
> {BASE}/skills/_shared/references/testing-strategy-archetypes.md — testing modes (A-F)
> {BASE}/skills/_shared/references/stacks/                  — language-specific knowledge packs
> ```
>
> **Settings**:
> ```
> {BASE}/settings.json — hook configuration
> ```
>
> To uninstall: delete the skill directories, agent files, and hook files listed above, then remove the hooks section from settings.json.

---

## Quick Reference

After installation, the pipeline works like this:

```
/scout    — research technologies, map existing codebases, evaluate options
/plan     — generate phases.md with tasks and acceptance criteria
/dev 1    — implement phase 1 (then /dev 2, /dev 3, etc.)
/qa 1     — validate phase 1 (adversarial, 8-category testing)
/fix      — fix bugs found by /qa (scoped, with root cause analysis)
```

The pipeline creates these files in each project:
- `phases.md` — task definitions and progress tracking
- `pipeline-state.md` — active skill/phase/task state
- `key-learnings/` — structured learnings per phase
- `qa-reports/` — validation results per phase
- `discovery/` — research reports (from /scout)
