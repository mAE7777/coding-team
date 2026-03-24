#!/bin/bash
# PostToolUse Write|Edit async hook: Security pattern scan with confidence filtering
# Advisory only — surfaces findings, never blocks
# >80% confidence threshold + false positives list

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [ -z "$FILE_PATH" ]; then
  FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
fi

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip non-code files
case "$FILE_PATH" in
  *.md|*.txt|*.json|*.yaml|*.yml|*.toml|*.lock|*.css|*.scss|*.svg|*.png|*.jpg|*.ico)
    exit 0
    ;;
esac

# Skip known false positive locations
case "$FILE_PATH" in
  *__tests__/*|*__mocks__/*|*__fixtures__/*|*.test.*|*.spec.*|*.test-*|*mock*|*fixture*)
    exit 0
    ;;
  *.env.example|*.env.sample)
    exit 0
    ;;
esac

FINDINGS=""

# Check for hardcoded secrets (high confidence patterns)
if grep -qE '(sk-proj-|sk-[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36})' "$FILE_PATH" 2>/dev/null; then
  MATCH=$(grep -nE '(sk-proj-|sk-[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36})' "$FILE_PATH" 2>/dev/null | head -3)
  FINDINGS="${FINDINGS}CRITICAL: Possible hardcoded API key/secret detected:\n${MATCH}\n\n"
fi

# Check for eval with variables (command injection)
if grep -qE 'eval\s*\(' "$FILE_PATH" 2>/dev/null; then
  MATCH=$(grep -nE 'eval\s*\(' "$FILE_PATH" 2>/dev/null | grep -v '// safe' | head -3)
  FINDINGS="${FINDINGS}HIGH: eval() usage detected (potential code injection):\n${MATCH}\n\n"
fi

# Check for shell exec with template literals or string concat
if grep -qE '(exec|execSync|spawn|spawnSync)\s*\(\s*`' "$FILE_PATH" 2>/dev/null; then
  MATCH=$(grep -nE '(exec|execSync|spawn|spawnSync)\s*\(\s*`' "$FILE_PATH" 2>/dev/null | head -3)
  FINDINGS="${FINDINGS}CRITICAL: Shell command with template literal (command injection risk):\n${MATCH}\n\n"
fi

# Check for innerHTML/dangerouslySetInnerHTML with variables
if grep -qE '(innerHTML\s*=|dangerouslySetInnerHTML)' "$FILE_PATH" 2>/dev/null; then
  MATCH=$(grep -nE '(innerHTML\s*=|dangerouslySetInnerHTML)' "$FILE_PATH" 2>/dev/null | head -3)
  FINDINGS="${FINDINGS}HIGH: innerHTML/dangerouslySetInnerHTML usage (XSS risk):\n${MATCH}\n\n"
fi

# Check for SQL string concatenation
if grep -qE "(query|execute)\s*\(\s*['\"]SELECT.*\+" "$FILE_PATH" 2>/dev/null; then
  MATCH=$(grep -nE "(query|execute)\s*\(\s*['\"]SELECT.*\+" "$FILE_PATH" 2>/dev/null | head -3)
  FINDINGS="${FINDINGS}CRITICAL: SQL query with string concatenation (SQL injection risk):\n${MATCH}\n\n"
fi

if [ -n "$FINDINGS" ]; then
  echo -e "SECURITY SCAN (advisory):\n${FINDINGS}Review these findings. False positives in test/mock files are already filtered."
fi

exit 0
