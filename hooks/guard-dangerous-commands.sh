#!/bin/bash
# PreToolUse Bash hook: Block dangerous commands with safe exceptions
# Deterministic regex matching — never blocks non-shell tools

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
if [ -z "$COMMAND" ]; then
  COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
fi

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Block: rm -rf / or rm -rf /* (but allow rm -rf node_modules, .next, dist, build, coverage, tmp)
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\s+/(\s|$|;|\||&|\*)'; then
  echo "BLOCKED: rm -rf / is not allowed"
  exit 2
fi

# Block: force push to main/master (handles both --force and -f, before or after branch name)
# Allow --force-with-lease (safe force push)
if echo "$COMMAND" | grep -qE 'git\s+push' && echo "$COMMAND" | grep -qE '(--force\b|-f\b)' && ! echo "$COMMAND" | grep -q 'force-with-lease'; then
  if echo "$COMMAND" | grep -qE '\b(main|master)\b'; then
    echo "BLOCKED: force push to main/master is not allowed. Use --force-with-lease if needed."
    exit 2
  fi
fi

# Block: reading common credential files
if echo "$COMMAND" | grep -qE 'cat\s+.*(/\.aws/credentials|/\.ssh/id_|/\.env\.local|/\.env\.production)'; then
  echo "BLOCKED: reading credential files directly. Use environment variables instead."
  exit 2
fi

# Block: git reset --hard without specific ref (too destructive)
if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard\s*$'; then
  echo "BLOCKED: git reset --hard without a specific ref. Specify a commit hash or branch."
  exit 2
fi

exit 0
