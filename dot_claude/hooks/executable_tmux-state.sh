#!/bin/bash
# Claude Code <-> tmux integration
# Colors the tmux window tab based on Claude's state, as a rounded "pill".
#
# Detection follows ccmux's model: "input required" is driven by Claude Code's
# first-class Notification event (notification_type = permission_prompt /
# idle_prompt), NOT inferred from tool-lifecycle events. Tool/turn events only
# set terminal states or reset. See settings.json for the wiring.
#
# DISPLAY model — the active tab must stay recognizable even under a state color:
#   * ACTIVE, no state: bold green label on a transparent bg (set globally in
#     tmux.conf) — no background rectangle, so it reads cleanly next to the pills.
#   * ACTIVE, in a state (window-status-current-format): a dim (thm_bg) pill with
#     a small state-colored DOT + green label, never a loud fill.
#   * INACTIVE (window-status-format): a solid colored PILL in the state color —
#     loud, because that's a window you are NOT looking at.
#   Pills are drawn with nerd-font half-circle caps ( U+E0B6 /  U+E0B4) in the
#   fill color on a transparent bg, giving rounded ends. Tab separators
#   (window-status-separator, set in tmux.conf on bg=default) are never touched,
#   so the │ dividers stay visible between pills.
#
# State model (escalating "your turn" signal):
#   reset      default   fall back to global catppuccin styles (working)
#   idle       Stop      Claude just finished — active normal, inactive dim italic
#   waiting    Notification/idle_prompt — idle a while awaiting input — blue
#   attention  Notification/permission_prompt — permission dialog open — orange
#   error      StopFailure — turn ended on an API error — red
#
# Uses colour palette numbers for state bg (hex bg doesn't render in
# Ghostty+tmux; hex fg is fine).

[ -z "$TMUX" ] && exit 0

STATE="${1:-reset}"
PANE="${TMUX_PANE}"
[ -z "$PANE" ] && exit 0

LABEL="#I#{?#{!=:#{window_name},Window},: #W,}"   # e.g. "5: ndrc"
# nerd-font half-circle caps, built from UTF-8 bytes so the private-use
# codepoints survive editing (U+E0B6 = EE 82 B6, U+E0B4 = EE 82 B4).
CAP_L=$(printf '\356\202\266')   # left half-circle — rounds the left end
CAP_R=$(printf '\356\202\264')   # right half-circle — rounds the right end

# Active tab: dim (thm_bg) pill, green label, state-colored dot inside.
active_pill() {
  local dot="$1" body="#{@thm_bg}"
  tmux set-window-option -t "$PANE" window-status-current-format \
    "#[bg=default,fg=${body}]${CAP_L}#[bg=${body},fg=${dot},bold] ●#[fg=#{@thm_green}] ${LABEL} #[bg=default,fg=${body}]${CAP_R}#[default]"
}

# Inactive tab: solid colored pill in the state color.
fill_pill() {
  local c="$1"
  tmux set-window-option -t "$PANE" window-status-format \
    "#[bg=default,fg=${c}]${CAP_L}#[bg=${c},fg=colour0,bold] ${LABEL} #[bg=default,fg=${c}]${CAP_R}#[default]"
}

# Restore the active tab to the global catppuccin current-style.
clear_current() {
  tmux set-window-option -u -t "$PANE" window-status-current-format 2>/dev/null
  tmux set-window-option -u -t "$PANE" window-status-current-style 2>/dev/null
}

# Restore the inactive tab to the global catppuccin style.
clear_plain() {
  tmux set-window-option -u -t "$PANE" window-status-format 2>/dev/null
  tmux set-window-option -u -t "$PANE" window-status-style 2>/dev/null
}

case "$STATE" in
  idle)
    # Just finished: active back to normal green, inactive dimmed italic.
    clear_current
    tmux set-window-option -t "$PANE" window-status-format "#[fg=#A5ADCB,italics] ${LABEL} #[default]"
    tmux set-window-option -u -t "$PANE" window-status-style 2>/dev/null
    ;;
  waiting)
    active_pill colour39
    fill_pill colour39
    ;;
  attention)
    active_pill colour208
    fill_pill colour208
    ;;
  error)
    active_pill colour204
    fill_pill colour204
    ;;
  reset|working)
    clear_current
    clear_plain
    ;;
  *)
    exit 0
    ;;
esac
