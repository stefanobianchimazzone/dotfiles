# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A macOS dotfiles repository storing configuration for Ghostty terminal, Neovim, Atuin shell history, Zellij terminal multiplexer, and tmux. There is no build system, test suite, or linter -- this is purely config files.

## Installation

Configs are installed by copying directories into `~/.config/`:
```sh
cp -r ghostty ~/.config/
cp -r nvim ~/.config/
cp -r atuin ~/.config/
cp -r zellij ~/.config/
cp tmux/tmux.conf ~/.tmux.conf
```

Prerequisites are installed via Homebrew (see README.md for full list).

## Architecture

### Neovim (`nvim/`)
- Entry point: `nvim/init.lua` loads `sbm.core` (options, keymaps) then `sbm.lazy` (plugin manager)
- Plugin manager: lazy.nvim, auto-bootstrapped in `nvim/lua/sbm/lazy.lua`
- Plugins are auto-discovered from `nvim/lua/sbm/plugins/` (each file returns a lazy.nvim plugin spec)
- LSP config lives in `nvim/lua/sbm/plugins/lsp/lspconfig.lua`, uses mason-lspconfig for server management
- Namespace prefix is `sbm` throughout the Lua modules
- Indentation: 2 spaces (tabs expanded), matching the Neovim `tabstop`/`shiftwidth` options set in `core/options.lua`

### Ghostty (`ghostty/config`)
Single config file. Uses Tokyo Night theme, MesloLGM Nerd Font Mono, translucent background with blur.

### Zellij (`zellij/config.kdl`)
KDL format. Keybinds use `clear-defaults=true` with custom bindings. Default mode is `locked` (unlock with Ctrl+g). Tokyo Night Storm theme.

### tmux (`tmux/tmux.conf`)
Prefix key is `Ctrl+s`. Uses TPM for plugin management. Catppuccin Macchiato theme. Vi copy-mode bindings. Installed to `~/.tmux.conf` (not `~/.config/`).

### Atuin (`atuin/config.toml`)
TOML format. Mostly defaults with `update_check = false`, `enter_accept = true`, sync v2 records enabled.
