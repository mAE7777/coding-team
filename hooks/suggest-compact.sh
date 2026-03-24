#!/bin/bash
# PostToolUse Edit|Write hook (optional): Tool call counter, suggest /compact at 50 calls
# Tracks call count per session via temp file

INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
if [ -z "$SESSION_ID" ]; then
  SESSION_ID=$(echo "$INPUT" | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"session_id"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
fi

if [ -z "$SESSION_ID" ]; then
  exit 0
fi

COUNTER_FILE="/tmp/claude-toolcount-${SESSION_ID}"

# Increment counter
if [ -f "$COUNTER_FILE" ]; then
  COUNT=$(cat "$COUNTER_FILE" 2>/dev/null)
  COUNT=$((COUNT + 1))
else
  COUNT=1
fi
echo "$COUNT" > "$COUNTER_FILE"

# Suggest compact at 50, remind every 25 after
if [ "$COUNT" -eq 50 ]; then
  echo "NOTE: 50 tool calls in this session. Consider running /compact to free up context window."
elif [ "$COUNT" -gt 50 ] && [ $(( (COUNT - 50) % 25 )) -eq 0 ]; then
  echo "NOTE: ${COUNT} tool calls in this session. Consider running /compact if context feels stale."
fi

exit 0
