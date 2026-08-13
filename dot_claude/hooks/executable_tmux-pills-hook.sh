#!/bin/bash
# Claude Code hook entry point for the tmux status pills (fire-and-forget).
#
# Modes (passed as $1):
#   set-error    StopFailure — record an error marker for this session UUID
#   clear-error  Stop / UserPromptSubmit — clear this session's error marker
#   render       any other transition — just repaint
#
# All modes then kick a DELAYED background repaint. The delay lets ccmux's
# daemon settle (it updates its own state ~200ms after the same event) so the
# renderer reads fresh truth. We background + detach so the hook returns
# immediately and never blocks Claude Code.
#
# The error marker is how the red pill survives (ccmux has no error state); the
# renderer reads /tmp/claude-pill-err/<uuid> and garbage-collects dead ones.

MODE="${1:-render}"
ERRDIR="/tmp/claude-pill-err"
RENDER="$HOME/.claude/hooks/tmux-pills-render.sh"

case "$MODE" in
  set-error)
    id="$(jq -r '.session_id // empty' 2>/dev/null)"
    [ -n "$id" ] && { mkdir -p "$ERRDIR"; : > "$ERRDIR/$id"; }
    ;;
  clear-error)
    id="$(jq -r '.session_id // empty' 2>/dev/null)"
    [ -n "$id" ] && rm -f "$ERRDIR/$id"
    ;;
esac

( sleep 0.35; "$RENDER" ) >/dev/null 2>&1 </dev/null &

exit 0
