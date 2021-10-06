#!/bin/bash

brew install neovim tree bat chrome-cli autojump fzf fd ripgrep

if [[ -n "$(command -v pip3)" ]]; then
  pip3 install pynvim
fi

if [[ -n "$(command -v pip2)" ]]; then
  pip2 install pynvim
fi

ln -s ~/.dotfiles/config/nvim/ ~/.config/nvim
ln -s ~/.dotfiles/rgignore ~/.rgignore
ln -s ~/.dotfiles/bash_profile ~/.bash_profile
ln -s ~/.dotfiles/bashrc ~/.bashrc
ln -s ~/.dotfiles/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/gitignore ~/.gitignore
ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/scripts/templatemux /usr/local/bin/templatemux

# Install NVM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.9/install.sh | bash
nvm install --lts
nvm use --lts

npm install -g prettier
nvim +PackerInstall +qall

./install-fish.sh
