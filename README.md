# Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/). Supports macOS and Arch Linux.

## Quick Start

```sh
chezmoi init https://github.com/<user>/dotfiles.git
chezmoi diff
chezmoi apply
```

## Prerequisites

### macOS

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile

brew install chezmoi neovim ripgrep node tmux zellij font-meslo-lg-nerd-font
brew install --cask ghostty
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
```

### Arch Linux

```sh
pacman -S chezmoi neovim ripgrep nodejs tmux zellij ttf-meslo-nerd ghostty atuin
```

### TPM (tmux plugin manager)

```sh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

After first tmux launch, press `Ctrl+s I` to install plugins.

## Usage

```sh
chezmoi edit ~/.config/tmux/tmux.conf   # edit source, apply on save
chezmoi apply                            # apply all changes
chezmoi update                           # pull remote + apply (secondary machine)
```

## Structure

```
dot_config/          → ~/.config/
  atuin/             static
  ghostty/           config.tmpl (macOS titlebar conditional)
  nvim/              static
  tmux/              tmux.conf.tmpl (clipboard: pbcopy vs wl-copy)
  zellij/            static
```
