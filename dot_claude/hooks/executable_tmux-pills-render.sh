#!/bin/bash
# Claude Code <-> tmux status pills — RENDERER (bash 3.2 safe; no assoc arrays).
#
# Reads ccmux's already-correct per-session state and paints ONE worst-of pill
# per tmux window. This replaces the old per-event push model (tmux-state.sh),
# which had two bugs: (a) orange stuck after an Esc-dismissed permission prompt
# (no hook fires on dismissal), and (b) multiple sessions in one window clobbered
# each other (window-status-format is a window-scoped option).
#
# Why this fixes both: ccmux keys state by Claude session UUID (not pane) and
# runs a pane-scan reconciler that flips a dismissed prompt back to idle. We just
# render its truth, taking the most-urgent state across all sessions in a window,
# so no session's alert can be masked and dismissals self-heal on the next poll.
#
# Invoked with NO arguments, from two places (hybrid):
#   * Claude hooks (via tmux-pills-hook.sh) — instant repaint on transitions.
#   * tmux status-interval #() poll — continuous, catches hookless changes.
#
# State source: ccmux daemon HTTP (fast) with `ccmux show --json` fallback.

command -v tmux >/dev/null 2>&1 || exit 0
command -v jq   >/dev/null 2>&1 || exit 0

PORT="${CCMUX_PORT:-2269}"
ERRDIR="/tmp/claude-pill-err"

# --- 1. Fetch ccmux session state ------------------------------------------
# Fast path: hit the daemon directly (no bun/node startup). Fall back to the
# stable CLI. If neither yields a JSON array, leave existing pills untouched.
JSON="$(curl -s --max-time 2 "http://127.0.0.1:${PORT}/sessions" 2>/dev/null)"
if ! printf '%s' "$JSON" | jq -e '(.sessions? // .) | type=="array"' >/dev/null 2>&1; then
  JSON="$(ccmux show --json 2>/dev/null)"
fi
if ! printf '%s' "$JSON" | jq -e '(.sessions? // .) | type=="array"' >/dev/null 2>&1; then
  exit 0
fi

# --- 2. Error overlay (optional) -------------------------------------------
# ccmux has no error state; keep the red pill by tracking StopFailure per UUID.
# Build a JSON array of UUIDs that currently have a marker, and GC dead ones.
ERR_JSON="[]"
if [ -d "$ERRDIR" ]; then
  LIVE="$(printf '%s' "$JSON" | jq -r '(.sessions? // .)[].nativeSessionId // empty')"
  for f in "$ERRDIR"/*; do
    [ -e "$f" ] || continue
    id="$(basename "$f")"
    printf '%s\n' "$LIVE" | grep -qxF "$id" || rm -f "$f"
  done
  ERR_JSON="$(ls -1 "$ERRDIR" 2>/dev/null | jq -R . | jq -s .)"
  [ -n "$ERR_JSON" ] || ERR_JSON="[]"
fi

# --- 3. Reduce to per-window worst-of level + session count ----------------
# tmuxTarget is "session:window.pane"; strip ".pane" to key by window.
# level: 5 error > 4 permission > 3 question/plan/plan-mode > 2 working > 1 idle
ROWS="$(printf '%s' "$JSON" | jq -r --argjson errs "$ERR_JSON" '
  (.sessions? // .)
  | map(select(.tmuxTarget != null))
  | map({
      win: (.tmuxTarget | sub("\\.[0-9]+$"; "")),
      level: (
        if ((.nativeSessionId // "") as $id | ($errs | index($id)) != null) then 5
        elif (.status=="waiting" and .attentionType=="permission") then 4
        elif (.status=="waiting" and (.attentionType=="question" or .attentionType=="plan_approval")) then 3
        elif (.inPlanMode==true) then 3
        elif (.status=="working") then 2
        else 1 end)
    })
  | group_by(.win)
  | map({win: .[0].win, level: (map(.level) | max), count: length})
  | .[] | "\(.win)\t\(.level)\t\(.count)"
')"

# --- 4. Rendering helpers (ported verbatim from tmux-state.sh) --------------
# nerd-font half-circle caps for rounded pill ends (U+E0B6 / U+E0B4).
CAP_L="$(printf '\356\202\266')"
CAP_R="$(printf '\356\202\264')"
LABEL='#I#{?#{!=:#{window_name},Window},: #W,}'   # e.g. "6: aive"

# $WIN and $LBL are set by the loop before calling these.
active_pill() { # $1 = dot/accent color — dim pill, colored dot, green label
  tmux set-window-option -t "$WIN" window-status-current-format \
    "#[bg=default,fg=#{@thm_bg}]${CAP_L}#[bg=#{@thm_bg},fg=$1,bold] ●#[fg=#{@thm_green}] ${LBL} #[bg=default,fg=#{@thm_bg}]${CAP_R}#[default]"
}
fill_pill() {  # $1 = fill color — solid pill for inactive windows
  tmux set-window-option -t "$WIN" window-status-format \
    "#[bg=default,fg=$1]${CAP_L}#[bg=$1,fg=colour0,bold] ${LBL} #[bg=default,fg=$1]${CAP_R}#[default]"
}
idle_paint() { # finished: active back to normal green, inactive dim italic
  tmux set-window-option -u -t "$WIN" window-status-current-format 2>/dev/null
  tmux set-window-option -u -t "$WIN" window-status-current-style  2>/dev/null
  tmux set-window-option    -t "$WIN" window-status-format "#[fg=#A5ADCB,italics] ${LBL} #[default]"
  tmux set-window-option -u -t "$WIN" window-status-style 2>/dev/null
}
clear_window() { # no sessions left: restore global catppuccin defaults
  tmux set-window-option -u -t "$WIN" window-status-current-format 2>/dev/null
  tmux set-window-option -u -t "$WIN" window-status-current-style  2>/dev/null
  tmux set-window-option -u -t "$WIN" window-status-format 2>/dev/null
  tmux set-window-option -u -t "$WIN" window-status-style  2>/dev/null
  tmux set-window-option -u -t "$WIN" @claude_pill 2>/dev/null
}

# --- 5. Paint each window with sessions -------------------------------------
SEEN=""   # space-delimited set of "session:window" keys we painted this run
while IFS="$(printf '\t')" read -r WIN LEVEL COUNT; do
  [ -n "$WIN" ] || continue
  SEEN="$SEEN $WIN"

  LBL="$LABEL"

  # Skip if nothing changed since last paint (flicker-free, cheap poll).
  # Signature is the level only — session count no longer affects the label.
  SIG="$LEVEL"
  PREV="$(tmux show-window-options -v -t "$WIN" @claude_pill 2>/dev/null)"
  [ "$PREV" = "$SIG" ] && continue

  case "$LEVEL" in
    5) active_pill colour204; fill_pill colour204 ;;   # error  — red
    4) active_pill colour208; fill_pill colour208 ;;   # perm   — orange
    3) active_pill colour39;  fill_pill colour39  ;;   # ask    — blue
    2) active_pill colour245; fill_pill colour245 ;;   # working— subtle grey
    *) idle_paint ;;                                    # idle
  esac
  tmux set-window-option -t "$WIN" @claude_pill "$SIG" 2>/dev/null
done <<EOF
$ROWS
EOF

# --- 6. Sweep windows that no longer have any session ----------------------
# Any window still carrying @claude_pill but absent from SEEN gets restored.
while read -r WKEY WSIG; do
  [ -n "$WKEY" ] || continue
  [ -n "$WSIG" ] || continue            # option unset -> not ours, skip
  case " $SEEN " in
    *" $WKEY "*) : ;;                    # still active
    *) WIN="$WKEY"; clear_window ;;
  esac
done <<EOF
$(tmux list-windows -a -F '#{session_name}:#{window_index} #{@claude_pill}')
EOF

exit 0
