#!/bin/bash

if ! command -v brew &> /dev/null
then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
cd .. && rm -rf fonts

brew install iterm2 neovim tree bat chrome-cli autojump fzf fd ripgrep

if [[ -n "$(command -v pip3)" ]]; then
  pip3 install pynvim
fi

if [[ -n "$(command -v pip2)" ]]; then
  pip2 install pynvim
fi

ln -sfn ~/.dotfiles/config/nvim/ ~/.config/nvim
ln -sfn ~/.dotfiles/rgignore ~/.rgignore
ln -sfn ~/.dotfiles/bash_profile ~/.bash_profile
ln -sfn ~/.dotfiles/bashrc ~/.bashrc
ln -sfn ~/.dotfiles/gitconfig ~/.gitconfig
ln -sfn ~/.dotfiles/gitignore ~/.gitignore
ln -sfn ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -sfn ~/.dotfiles/scripts/templatemux /usr/local/bin/templatemux

# Install NVM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.9/install.sh | bash
nvm install --lts
nvm use --lts

npm install -g prettier
nvim +PackerInstall +qall

./install-fish.sh
