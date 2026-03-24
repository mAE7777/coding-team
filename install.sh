#!/usr/bin/env bash
set -euo pipefail

# Claude Code Pipeline Installer
# Copies pipeline skills, agents, hooks, and shared references into ~/.claude/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; }

# Check Claude Code directory exists
if [ ! -d "$CLAUDE_DIR" ]; then
    error "~/.claude/ directory not found. Is Claude Code installed?"
    echo "  Install Claude Code first: https://docs.anthropic.com/en/docs/claude-code/overview"
    exit 1
fi

echo ""
echo "  Claude Code Pipeline Installer"
echo "  ==============================="
echo ""
echo "  This will install into ~/.claude/:"
echo "    - 5 pipeline skills (scout, plan, dev, qa, fix)"
echo "    - 8 subagents"
echo "    - 7 hooks"
echo "    - 3 shared references"
echo ""

# Check for existing installations
CONFLICTS=()
for skill in scout plan dev qa fix; do
    if [ -d "$CLAUDE_DIR/skills/$skill" ]; then
        CONFLICTS+=("skills/$skill")
    fi
done
for agent in deep-researcher dev-planner task-implementer qa-planner category-executor security-auditor project-analyzer migration-planner; do
    if [ -f "$CLAUDE_DIR/agents/$agent.md" ]; then
        CONFLICTS+=("agents/$agent.md")
    fi
done

if [ ${#CONFLICTS[@]} -gt 0 ]; then
    warn "The following files already exist and will be OVERWRITTEN:"
    for c in "${CONFLICTS[@]}"; do
        echo "    ~/.claude/$c"
    done
    echo ""
fi

read -rp "  Proceed with installation? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "  Aborted."
    exit 0
fi

echo ""

# ── Skills ──────────────────────────────────────────────────────────────────
info "Installing skills..."

for skill in scout plan dev qa fix; do
    mkdir -p "$CLAUDE_DIR/skills/$skill"
    cp -r "$SCRIPT_DIR/skills/$skill/"* "$CLAUDE_DIR/skills/$skill/"
    info "  $skill"
done

# ── Shared references ───────────────────────────────────────────────────────
info "Installing shared references..."

mkdir -p "$CLAUDE_DIR/skills/_shared/references"
cp "$SCRIPT_DIR/skills/_shared/references/"*.md "$CLAUDE_DIR/skills/_shared/references/"

# Shared state files — only if they don't already exist (don't overwrite user data)
for f in ground.md owner-profile.md; do
    if [ ! -f "$CLAUDE_DIR/skills/_shared/$f" ]; then
        cp "$SCRIPT_DIR/skills/_shared/$f" "$CLAUDE_DIR/skills/_shared/$f"
        info "  Created _shared/$f"
    else
        warn "  _shared/$f already exists — skipped (won't overwrite your data)"
    fi
done

# ── Agents ──────────────────────────────────────────────────────────────────
info "Installing agents..."

mkdir -p "$CLAUDE_DIR/agents"
cp "$SCRIPT_DIR/agents/"*.md "$CLAUDE_DIR/agents/"
info "  8 agents installed"

# ── Hooks ───────────────────────────────────────────────────────────────────
info "Installing hooks..."

mkdir -p "$CLAUDE_DIR/hooks"
cp "$SCRIPT_DIR/hooks/"*.sh "$CLAUDE_DIR/hooks/"
chmod +x "$CLAUDE_DIR/hooks/"*.sh
info "  7 hooks installed"

# ── Settings (hooks configuration) ──────────────────────────────────────────
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    warn "~/.claude/settings.json already exists."
    echo "    Hook configuration must be merged manually."
    echo "    See pipeline/settings.json for the required hook configuration."
    echo ""
    echo "    If your settings.json has no hooks section, you can merge with:"
    echo "      jq -s '.[0] * .[1]' ~/.claude/settings.json $SCRIPT_DIR/settings.json > /tmp/merged.json"
    echo "      mv /tmp/merged.json ~/.claude/settings.json"
else
    cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    info "  settings.json installed"
fi

# ── Post-install ────────────────────────────────────────────────────────────
echo ""
info "Installation complete!"
echo ""
echo "  Next steps:"
echo "  1. Edit ~/.claude/skills/_shared/owner-profile.md with your info"
echo "  2. Merge hook config into settings.json if it wasn't auto-installed"
echo "  3. Start using the pipeline:"
echo ""
echo "     /scout    — research before planning"
echo "     /plan     — generate phases.md from a design doc"
echo "     /dev N    — implement phase N"
echo "     /qa N     — validate phase N"
echo "     /fix      — targeted bug fixes"
echo ""
