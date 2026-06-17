#!/bin/bash
# Claude Code <-> tmux integration
# Changes the tmux window tab color based on Claude's state.
# Uses format strings with colour palette numbers for bg (hex bg doesn't render in Ghostty+tmux).

[ -z "$TMUX" ] && exit 0

STATE="${1:-reset}"
PANE="${TMUX_PANE}"
[ -z "$PANE" ] && exit 0

WIN_FMT=" #I#{?#{!=:#{window_name},Window},: #W,} "

case "$STATE" in
  idle)
    # Focused: normal green (fall back to global catppuccin defaults)
    tmux set-window-option -u -t "$PANE" window-status-current-format 2>/dev/null
    tmux set-window-option -u -t "$PANE" window-status-current-style 2>/dev/null
    # Not focused: dimmed italic
    tmux set-window-option -t "$PANE" window-status-format "#[fg=#A5ADCB,italics]${WIN_FMT}#[default]"
    tmux set-window-option -u -t "$PANE" window-status-style 2>/dev/null
    ;;
  attention)
    # Orange bg — needs user action
    tmux set-window-option -t "$PANE" window-status-current-format "#[bg=colour208,fg=colour0,bold]${WIN_FMT}#[default]"
    tmux set-window-option -t "$PANE" window-status-format "#[bg=colour208,fg=colour0,bold]${WIN_FMT}#[default]"
    ;;
  error)
    # Red bg — something failed
    tmux set-window-option -t "$PANE" window-status-current-format "#[bg=colour204,fg=colour0,bold]${WIN_FMT}#[default]"
    tmux set-window-option -t "$PANE" window-status-format "#[bg=colour204,fg=colour0,bold]${WIN_FMT}#[default]"
    ;;
  reset)
    # Unset all per-window overrides, fall back to global catppuccin styles
    tmux set-window-option -u -t "$PANE" window-status-current-format 2>/dev/null
    tmux set-window-option -u -t "$PANE" window-status-format 2>/dev/null
    tmux set-window-option -u -t "$PANE" window-status-current-style 2>/dev/null
    tmux set-window-option -u -t "$PANE" window-status-style 2>/dev/null
    ;;
esac
