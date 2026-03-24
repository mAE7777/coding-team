#!/bin/bash
# PostToolUse Edit hook (recommended, project-specific): TypeScript check on .ts/.tsx files
# Walks up to find nearest tsconfig.json, runs tsc --noEmit, filters errors to edited file

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [ -z "$FILE_PATH" ]; then
  FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
fi

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only check TypeScript files
case "$FILE_PATH" in
  *.ts|*.tsx)
    ;;
  *)
    exit 0
    ;;
esac

# Walk up to find nearest tsconfig.json
DIR=$(dirname "$FILE_PATH")
TSCONFIG=""
while [ "$DIR" != "/" ]; do
  if [ -f "$DIR/tsconfig.json" ]; then
    TSCONFIG="$DIR/tsconfig.json"
    break
  fi
  DIR=$(dirname "$DIR")
done

if [ -z "$TSCONFIG" ]; then
  exit 0
fi

TSCONFIG_DIR=$(dirname "$TSCONFIG")

# Convert to relative path for matching tsc output
REL_PATH="${FILE_PATH#$TSCONFIG_DIR/}"

# Run tsc and filter to edited file only
# Use timeout to prevent hanging on large projects
ERRORS=$(cd "$TSCONFIG_DIR" && timeout 30 npx tsc --noEmit --pretty false 2>&1 | grep -F "$REL_PATH" | head -10)

if [ -n "$ERRORS" ]; then
  echo "TypeScript errors in edited file:"
  echo "$ERRORS"
fi

exit 0
