#!/bin/bash
# PreCompact hook: Save structured summary before context compaction
# Extracts active skill state, task summaries, behavioral modifiers, and modified files from pipeline-state.md

INPUT=$(cat)

CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
if [ -z "$CWD" ]; then
  CWD=$(echo "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
fi

if [ -z "$CWD" ]; then
  exit 0
fi

PIPELINE_STATE="$CWD/pipeline-state.md"
if [ ! -f "$PIPELINE_STATE" ]; then
  exit 0
fi

# Extract active skill
ACTIVE_SKILL=$(grep -E "^Active Skill" "$PIPELINE_STATE" 2>/dev/null | head -1 | sed 's/.*|[[:space:]]*//' | sed 's/[[:space:]]*$//')
if [ -z "$ACTIVE_SKILL" ]; then
  ACTIVE_SKILL=$(grep "Last Skill" "$PIPELINE_STATE" 2>/dev/null | head -1 | sed 's/.*|[[:space:]]*//' | sed 's/[[:space:]]*|.*//' | tr -d '[:space:]')
fi

# Get recently modified files from git
MODIFIED_FILES=$(cd "$CWD" && git diff --name-only HEAD 2>/dev/null | head -20)
if [ -z "$MODIFIED_FILES" ]; then
  MODIFIED_FILES=$(cd "$CWD" && git diff --name-only 2>/dev/null | head -20)
fi

# Build summary
SUMMARY="PRE-COMPACTION STATE SUMMARY\n"
SUMMARY="${SUMMARY}============================\n\n"

if [ -n "$ACTIVE_SKILL" ]; then
  SUMMARY="${SUMMARY}Active Skill: ${ACTIVE_SKILL}\n\n"
fi

# Extract phase info if present
PHASE_INFO=$(grep -E "^(Current Phase|Phase)" "$PIPELINE_STATE" 2>/dev/null | head -1)
if [ -n "$PHASE_INFO" ]; then
  SUMMARY="${SUMMARY}${PHASE_INFO}\n\n"
fi

# Extract task summaries section if present
TASK_SUMMARIES=$(awk '/^## Task Summaries/,/^## [^T]/' "$PIPELINE_STATE" 2>/dev/null | head -30)
if [ -n "$TASK_SUMMARIES" ]; then
  SUMMARY="${SUMMARY}${TASK_SUMMARIES}\n\n"
fi

# Behavioral modifiers
MODIFIERS=$(awk '/^## Behavioral Modifiers/,/^## [^B]/' "$PIPELINE_STATE" 2>/dev/null | head -20)
if [ -n "$MODIFIERS" ]; then
  SUMMARY="${SUMMARY}${MODIFIERS}\n\n"
fi

if [ -n "$MODIFIED_FILES" ]; then
  SUMMARY="${SUMMARY}<modified-files>\n${MODIFIED_FILES}\n</modified-files>\n"
fi

echo -e "$SUMMARY"
exit 0
