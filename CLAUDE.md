# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A cross-platform dotfiles repository (macOS + Arch Linux) managed with chezmoi. Stores configuration for Ghostty terminal, Neovim, Atuin shell history, Zellij terminal multiplexer, and tmux. There is no build system, test suite, or linter -- this is purely config files.

## Installation

Managed by chezmoi. Apply configs with:
```sh
chezmoi init --source <path-to-this-repo>
chezmoi apply
```

See README.md for prerequisites per platform.

## Architecture

### chezmoi source layout

All configs live under `dot_config/` which maps to `~/.config/` on the target machine. Files with `.tmpl` suffix are Go templates processed by chezmoi; all others are copied verbatim.

Platform conditionals use `.chezmoi.os` (`"darwin"` for macOS, `"linux"` for Arch).

### Neovim (`dot_config/nvim/`)
- Single-file config: `init.lua` contains options, keymaps, LSP setup, and plugin declarations
- Plugin manager: native `vim.pack` (no lazy.nvim)
- LSP servers configured inline: pyright, lua_ls, gopls
- Indentation: 2 spaces (tabs expanded)

### Ghostty (`dot_config/ghostty/`)
- `config.tmpl` — template with macOS-only `macos-titlebar-style` conditional
- `shaders/` — cursor shader GLSL files
- Uses Tokyo Night theme, MesloLGM Nerd Font Mono, translucent background with blur

### Zellij (`dot_config/zellij/config.kdl`)
KDL format. Keybinds use `clear-defaults=true` with custom bindings. Default mode is `locked` (unlock with Ctrl+g). Tokyo Night Storm theme.

### tmux (`dot_config/tmux/`)
- `tmux.conf.tmpl` — template with clipboard conditional (`pbcopy` on macOS, `wl-copy` on Linux)
- Prefix key is `Ctrl+s`. Uses TPM for plugin management. Catppuccin Macchiato theme. Vi copy-mode bindings.

### Atuin (`dot_config/atuin/config.toml`)
TOML format. Mostly defaults with `update_check = false`, `enter_accept = true`, sync v2 records enabled.
