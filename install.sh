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

print_checking "brew"
if ! command -v brew &> /dev/null
then
  print_installing "brew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

print_installed "brew"


print_installing "powerline fonts"
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
cd .. && rm -rf fonts
print_installed "powerline fonts"

print_installing "applications from brew"
brew install iterm2 neovim tree bat chrome-cli autojump fzf fd ripgrep
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

print_installing "dotfiles"
ln -sfn ~/.dotfiles/config/nvim/ ~/.config/nvim
ln -sfn ~/.dotfiles/rgignore ~/.rgignore
ln -sfn ~/.dotfiles/bash_profile ~/.bash_profile
ln -sfn ~/.dotfiles/bashrc ~/.bashrc
ln -sfn ~/.dotfiles/gitconfig ~/.gitconfig
ln -sfn ~/.dotfiles/gitignore ~/.gitignore
ln -sfn ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -sfn ~/.dotfiles/scripts/templatemux /usr/local/bin/templatemux
print_installed "dotfiles"

# Install NVM
print_checking "nvm"
if ! command -v nvm &> /dev/null
then
  print_installing "nvm"
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.9/install.sh | bash
  nvm install --lts
  nvm use --lts
fi
print_installed "nvm"

print_checking "prettier"
if ! command -v prettier &> /dev/null
then
  print_installing "prettier"
  npm install -g prettier
fi
print_installed "prettier"

print_installing "nvim plugins"
nvim +PackerInstall +qall
print_installed "nvim plugins"

print_installing "fish"
./install-fish.sh
print_installed "fish"
