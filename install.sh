#!/bin/bash

function print_checking() {
  echo -e "\033[0;31m...checking for $1"
}

function print_installing() {
  echo -e "\033[0;33m...installing $1"
}

function print_installed() {
  echo -e "\033[0;32m... $1 installed"
}

function set_brew_path() {
  BREW_PATH=$(brew --prefix)
}

print_checking "brew"
set_brew_path
if ! command -v brew &> /dev/null
then
  print_installing "brew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  set_brew_path

  /bin/bash -c "echo 'eval \"$($BREW_PATH/bin/brew shellenv)\"' >> ~/.profile"
  /bin/bash -c "$($BREW_PATH/bin/brew shellenv)"
else
  set_brew_path
fi

print_installed "brew"


# print_installing "powerline fonts"
# git clone https://github.com/powerline/fonts.git
# cd fonts
# ./install.sh
# cd .. && rm -rf fonts
# print_installed "powerline fonts"

print_installing "applications from brew"
brew tap homebrew/cask-fonts
brew tap yoheimuta/protolint
brew tap heroku/brew
brew install node kitty neovim tree bat chrome-cli autojump fzf fd ripgrep font-hack-nerd-font devutils yarn protolint tfenv heroku hadolint chruby-fish ruby-install coreutils krew protobuf@3 python luarocks
print_installed "applications from brew"

print_checking "pynvim"
if command -v pip3
then
  print_installing "pynvim"
  pip3 install pynvim
fi

if command -v pip2
then
  print_installing "pynvim"
  pip2 install pynvim
fi
print_installed "pynvim"

print_installing "python formatting"
PIP_REQUIRE_VIRTUALENV="0" python -m pip install --upgrade ruff
print_intalled "pyton formatting"

print_installing "dotfiles"
mkdir -p ~/.config
ln -sFfn ~/.dotfiles/config/nvim/ ~/.config/nvim
ln -sFfn ~/.dotfiles/config/kitty/ ~/.config/kitty
ln -sFfn ~/.dotfiles/config/pip/ ~/.config/pip
ln -sFfn ~/.dotfiles/rgignore ~/.rgignore
ln -sFfn ~/.dotfiles/bash_profile ~/.bash_profile
ln -sFfn ~/.dotfiles/bashrc ~/.bashrc
ln -sFfn ~/.dotfiles/gitconfig ~/.gitconfig
ln -sFfn ~/.dotfiles/gitignore ~/.gitignore
ln -sFfn ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -sFfn ~/.dotfiles/scripts/templatemux /usr/local/bin/templatemux
print_installed "dotfiles"

# Install NVM
print_checking "nvm"
if ! command -v nvm &> /dev/null
then
  print_installing "nvm"
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.9/install.sh | bash
fi
print_installed "nvm"

# Install G
print_checking "g"
if ! command -v g &> /dev/null
then
  print_installing "g"
  curl -sSL https://git.io/g-install | sh -s
  source ~/.bash_profile
  g install latest
  g set latest

  # Install bufls for lsp
  go install github.com/bufbuild/buf-language-server/cmd/bufls@latest
fi
print_installed "g"

print_installing "nvim plugins"
nvim --headless "+Lazy! sync" +qa
print_installed "nvim plugins"

print_installing "node2"
./install-node2.sh
print_installed "node2"

print_installing "fish"
./install-fish.sh
print_installed "fish"

print_checking "rust"
if ! command -v rustup &> /dev/null
then
  print_installing "rust"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
print_installed "rust"

print_checking "bun"
if ! command -v bun &> /dev/null
then
  print_installing "bun"
  curl -fsSL https://bun.sh/install | bash
fi
print_installed "bun"
