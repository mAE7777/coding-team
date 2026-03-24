#!/bin/bash
# Stop hook: Warn if pipeline shows work in-progress
# Also audits for console.log/debugger in git-modified files (exclude test/config)

INPUT=$(cat)

CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
if [ -z "$CWD" ]; then
  CWD=$(echo "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
fi

if [ -z "$CWD" ]; then
  exit 0
fi

WARNINGS=""

# Check pipeline-state.md for in-progress work
PIPELINE_STATE="$CWD/pipeline-state.md"
if [ -f "$PIPELINE_STATE" ]; then
  if grep -qiE 'IN.?PROGRESS' "$PIPELINE_STATE" 2>/dev/null; then
    ACTIVE_SKILL=$(grep -E "(Active Skill|Last Skill)" "$PIPELINE_STATE" 2>/dev/null | head -1 | sed 's/.*|[[:space:]]*//' | sed 's/[[:space:]]*|.*//' | tr -d '[:space:]')
    WARNINGS="${WARNINGS}WARNING: Pipeline shows work IN PROGRESS"
    if [ -n "$ACTIVE_SKILL" ]; then
      WARNINGS="${WARNINGS} (skill: ${ACTIVE_SKILL})"
    fi
    WARNINGS="${WARNINGS}. Session may be ending with incomplete pipeline work.\n"
  fi
fi

# Audit git-modified JS/TS files for console.log/debugger
MODIFIED_FILES=$(cd "$CWD" && git diff --name-only HEAD 2>/dev/null; cd "$CWD" && git diff --name-only 2>/dev/null)
if [ -n "$MODIFIED_FILES" ]; then
  for f in $(echo "$MODIFIED_FILES" | sort -u); do
    FULL="$CWD/$f"
    # Skip test/config/type files
    case "$f" in
      *.test.*|*.spec.*|*__tests__/*|*.config.*|*.d.ts|*.json|*.md)
        continue
        ;;
    esac
    # Only check JS/TS files
    case "$f" in
      *.ts|*.tsx|*.js|*.jsx)
        if [ -f "$FULL" ]; then
          CONSOLE_HITS=$(grep -n 'console\.\(log\|debug\)\|debugger' "$FULL" 2>/dev/null | head -5)
          if [ -n "$CONSOLE_HITS" ]; then
            WARNINGS="${WARNINGS}NOTE: console.log/debugger found in ${f}:\n${CONSOLE_HITS}\n\n"
          fi
        fi
        ;;
    esac
  done
fi

if [ -n "$WARNINGS" ]; then
  echo -e "$WARNINGS"
fi

exit 0
