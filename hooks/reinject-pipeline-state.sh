#!/bin/bash
# SessionStart hook (matcher: compact)
# After context compaction, re-injects critical context about remaining stages,
# behavioral modifiers, and Task Summaries from pipeline-state.md.

INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)

if [ -z "$SESSION_ID" ]; then
  SESSION_ID=$(echo "$INPUT" | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"session_id"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
fi
if [ -z "$CWD" ]; then
  CWD=$(echo "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
fi

# Check if pipeline-state.md exists in CWD
PIPELINE_STATE="$CWD/pipeline-state.md"
if [ ! -f "$PIPELINE_STATE" ]; then
  exit 0
fi

# Read active skill from pipeline-state.md
ACTIVE_SKILL=$(grep -E "^Active Skill" "$PIPELINE_STATE" 2>/dev/null | head -1 | sed 's/.*|[[:space:]]*//' | sed 's/[[:space:]]*$//')
if [ -z "$ACTIVE_SKILL" ]; then
  ACTIVE_SKILL=$(grep "Last Skill" "$PIPELINE_STATE" 2>/dev/null | head -1 | sed 's/.*|[[:space:]]*//' | sed 's/[[:space:]]*|.*//' | tr -d '[:space:]')
fi

if [ -z "$ACTIVE_SKILL" ]; then
  exit 0
fi

# Build context string
CONTEXT="CONTEXT RECOVERY (post-compaction):\n"
CONTEXT="${CONTEXT}You are running the '${ACTIVE_SKILL}' pipeline skill.\n\n"

case "$ACTIVE_SKILL" in
  dev)
    CONTEXT="${CONTEXT}Remaining stages after task execution:\n"
    CONTEXT="${CONTEXT}- Stage 5: Run validation gates (all gates must pass)\n"
    CONTEXT="${CONTEXT}- Stage 6: Create key-learnings file (key-learnings/key-learnings-{NN}.md)\n"
    CONTEXT="${CONTEXT}- Stage 7: Phase completion (verify checkboxes, verify artifacts, lightweight knowledge capture, final summary)\n"
    ;;
  qa)
    CONTEXT="${CONTEXT}Remaining stages:\n"
    CONTEXT="${CONTEXT}- Stage 7: Compile qa report, calculate verdict, update key-learnings with qa Notes, present verdict\n"
    ;;
  scout)
    CONTEXT="${CONTEXT}Remaining stages:\n"
    CONTEXT="${CONTEXT}- Stage 6: Write discovery report, optionally generate design draft, present summary\n"
    ;;
  plan|feat)
    CONTEXT="${CONTEXT}Remaining stages:\n"
    CONTEXT="${CONTEXT}- Phase 5: Generate phases.md, create pipeline-state.md, create key-learnings dir, present summary\n"
    ;;
  deploy)
    CONTEXT="${CONTEXT}Remaining stages:\n"
    CONTEXT="${CONTEXT}- Stage 5: Post-deploy verification, pipeline archival, port release, final summary\n"
    ;;
  fix|hotfix)
    CONTEXT="${CONTEXT}Remaining stages:\n"
    CONTEXT="${CONTEXT}- Stage 4: Verify (build + typecheck + affected tests)\n"
    CONTEXT="${CONTEXT}- Stage 5: Document (fix-log.md, pipeline-state.md)\n"
    ;;
esac

# Re-inject behavioral modifiers
MODIFIERS=$(awk '/^## Behavioral Modifiers/,/^## [^B]/' "$PIPELINE_STATE" 2>/dev/null | head -20)
if [ -n "$MODIFIERS" ]; then
  CONTEXT="${CONTEXT}\nIDENTITY-DRIVEN BEHAVIORAL MODIFIERS (from pipeline-state.md):\n"
  CONTEXT="${CONTEXT}${MODIFIERS}\n"
  CONTEXT="${CONTEXT}Apply these modifiers throughout your planning and execution.\n"
fi

# Re-inject Task Summaries (critical for dev context recovery)
TASK_SUMMARIES=$(awk '/^## Task Summaries/,/^## [^T]/' "$PIPELINE_STATE" 2>/dev/null | head -30)
if [ -n "$TASK_SUMMARIES" ]; then
  CONTEXT="${CONTEXT}\n${TASK_SUMMARIES}\n"
fi

echo -e "$CONTEXT"
