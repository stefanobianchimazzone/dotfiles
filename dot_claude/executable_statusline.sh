#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
RAW_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
EFFORT=$(echo "$input" | jq -r '.effort.level // "high"')
COMPACT_AT=${CLAUDE_AUTOCOMPACT_PCT_OVERRIDE:-$(jq -r '.env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE // "100"' "/Library/Application Support/ClaudeCode/managed-settings.json" 2>/dev/null || echo 100)}

BRANCH=""
PROJECT=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
fi

PCT=$((RAW_PCT * 100 / COMPACT_AT))
[ "$PCT" -gt 100 ] && PCT=100

GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; PURPLE='\033[35m'; DIM='\033[2m'; RESET='\033[0m'
[ "$PCT" -ge 90 ] && BAR_COLOR="$RED" || { [ "$PCT" -ge 70 ] && BAR_COLOR="$YELLOW" || BAR_COLOR="$GREEN"; }

WIDTH=20
FILLED=$((PCT * WIDTH / 100))
EMPTY=$((WIDTH - FILLED))
printf -v FILL "%${FILLED}s"
printf -v PAD "%${EMPTY}s"
if [ "$FILLED" -eq "$WIDTH" ]; then
    BAR="${BAR_COLOR}${FILL// /━}${RESET}"
elif [ "$FILLED" -eq 0 ]; then
    BAR="${DIM}${PAD// /━}${RESET}"
else
    PAD_LEN=$((EMPTY - 1))
    printf -v PAD2 "%${PAD_LEN}s"
    BAR="${BAR_COLOR}${FILL// /━}╸${RESET}${DIM}${PAD2// /━}${RESET}"
fi
COST_FMT=$(printf '$%.2f' "$COST")

case "$EFFORT" in
    low)   EFFORT_COLOR='\033[34m' ;;
    medium) EFFORT_COLOR='\033[36m' ;;
    high)  EFFORT_COLOR="$GREEN" ;;
    xhigh) EFFORT_COLOR="$YELLOW" ;;
    max)   EFFORT_COLOR="$RED" ;;
    *)     EFFORT_COLOR="$RESET" ;;
esac
echo -e "${BAR} ${PCT}% · ${MODEL} · ${EFFORT_COLOR}⚡${EFFORT}${RESET} · ${COST_FMT}"
if [ -n "$BRANCH" ]; then
    echo -e "${PURPLE}${PROJECT}${RESET} · ⎇ ${BRANCH}"
else
    echo "${DIR}"
fi
