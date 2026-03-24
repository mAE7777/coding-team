# Claude Code Pipeline

A development pipeline for [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview). Five skills that chain together to take a project from research to validated implementation.

```
/scout → /plan → /dev → /qa
                         │
                         └→ /fix (then re-run /qa)
```

## What It Does

| Command | Purpose |
|---------|---------|
| `/scout` | Research — investigate technologies, map existing codebases, evaluate options |
| `/plan` | Generate a structured `phases.md` with tasks, acceptance criteria, and validation gates |
| `/dev N` | Implement phase N — each task runs in a fresh subagent for clean context |
| `/qa N` | Adversarial validation across 8 categories (regression, functional, security, a11y, etc.) |
| `/fix` | Targeted bug fixes scoped to ~15 files, with root cause analysis |

## Architecture

**Skills**: Each skill is a markdown file (`SKILL.md`) that instructs Claude how to behave at each stage. Skills load references on demand and delegate heavy work to subagents.

**Subagents** (8 total):

| Agent | Model | Used By | Role |
|-------|-------|---------|------|
| `dev-planner` | opus | `/dev` | Rich planning with full project context |
| `task-implementer` | sonnet | `/dev` | Single-task execution, fresh context per task |
| `qa-planner` | opus | `/qa` | Test plan generation across 8 categories |
| `category-executor` | sonnet | `/qa` | Isolated test execution for high-context categories |
| `security-auditor` | sonnet | `/qa` | OWASP Top 10 vulnerability scanning |
| `project-analyzer` | inherit | `/scout` | Codebase analysis for brownfield projects |
| `migration-planner` | inherit | `/scout` | Dependency upgrade impact analysis |
| `deep-researcher` | general | any | Deep research when WebSearch isn't enough |

**Hooks** (7 total):

| Hook | Trigger | What It Does |
|------|---------|-------------|
| `guard-dangerous-commands.sh` | Before Bash | Blocks `rm -rf /`, force push to main |
| `scan-written-code.sh` | After Write/Edit | Async security scan (secrets, eval, XSS, SQLi) |
| `post-edit-typecheck.sh` | After Edit | Runs `tsc --noEmit` on edited TypeScript files |
| `suggest-compact.sh` | After Write/Edit | Suggests `/compact` at 50 tool calls |
| `save-pipeline-state.sh` | Before Compact | Preserves active skill state |
| `reinject-pipeline-state.sh` | After Compact | Re-injects pipeline state |
| `verify-pipeline-completion.sh` | On Stop | Warns if work is still in progress |

## Install

### Option A: Shell script

```bash
git clone <this-repo> pipeline
cd pipeline
./install.sh
```

### Option B: Claude Code guided setup

Open Claude Code and say:

> Read SETUP.md in the pipeline repo and follow its instructions to install.

Claude will walk you through installation interactively — asks global vs local, copies files, configures hooks, helps personalize your profile, and verifies everything works.

## Post-Install

1. **Edit your profile**: `~/.claude/skills/_shared/owner-profile.md` — fill in your role and tech preferences
2. **Merge settings** (if needed): Hook configuration in `settings.json` must be merged with existing settings

## How the Pipeline Works

```
Design doc or idea
    │
    ▼
/scout ────────► discovery/discovery-{slug}.md
    │
    ▼
/plan  ────────► phases.md (tasks + ACs)
    │             pipeline-state.md
    │             key-learnings/ directory
    ▼
/dev N ────────► key-learnings/key-learnings-{NN}.md
    │             Updated phases.md checkboxes
    ▼
/qa N  ────────► qa-reports/qa-report-phase-{NN}.md
    │
    ├─ PASS ───► /dev N+1 (next phase)
    ├─ COND ───► address issues, then continue
    └─ FAIL ───► /fix → re-run /qa
```

**Key concepts:**
- **Key-learnings chain**: Each `/dev` writes learnings, each `/qa` appends findings. Later phases read all prior learnings.
- **pipeline-state.md**: Tracks active skill, phase, task progress. Hooks preserve this across context compaction.
- **Subagent isolation**: Heavy work runs in fresh-context subagents. Main conversation stays lightweight.
- **User approval gates**: No skill advances without explicit user approval.
- **[UNVERIFIED] markers**: Plan marks ungrounded details. Dev verifies before implementing.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) installed and configured
- No other dependencies

## File Structure

```
pipeline/
├── skills/
│   ├── scout/          (SKILL.md + 6 references + 1 asset)
│   ├── plan/           (SKILL.md + 7 references + 1 asset)
│   ├── dev/            (SKILL.md + 6 references + 1 asset)
│   ├── qa/             (SKILL.md + 5 references + 2 assets)
│   ├── fix/            (SKILL.md + 3 references)
│   └── _shared/
│       ├── references/ (3 files: constitution, state protocol, testing archetypes)
│       ├── ground.md
│       └── owner-profile.md
├── agents/             (8 agent definitions)
├── hooks/              (7 shell scripts)
├── settings.json       (hook configuration)
├── install.sh
├── SETUP.md            (Claude Code guided installation)
└── README.md
```
