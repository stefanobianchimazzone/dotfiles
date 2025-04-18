# Dotfiles & Setup

Install brew:

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
$ echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
$ source ~/.zprofile
```

Install fonts:

```sh
$ brew install font-meslo-lg-nerd-font
```

Install Ghostty:

```sh
brew install --cask ghostty
```

Install Neovim:

```sh
$ brew install neovim
```

Install ripgrep:

```sh
$ brew install ripgrep
```

Install Node:

```sh
$ brew install node
```

Install Atuin:

```sh
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
```

Copy the config files from this repo into the proper directories:

```sh
# Ghostty config files
$ cp -r ghostty ~/.config/
# Neoovim config files
$ cp -r nvim ~/.config/
# Atuin config files
$ cp -r atuin ~/config/
```
