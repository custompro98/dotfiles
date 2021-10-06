#!/bin/bash

platform='osx'
unamestr=`uname`
if [[ "$unamestr" == 'Linux'  ]]; then
   platform='linux'
fi

if [[ "$platform" == 'linux' ]]; then
  sudo apt install nvim tree bat fd rg
else
  brew install neovim tree bat chrome-cli autojump fzf fd ripgrep
fi

if [[ -n "$(command -v pip3)" ]]; then
  pip3 install pynvim
fi

if [[ -n "$(command -v pip2)" ]]; then
  pip2 install pynvim
fi

ln -s ~/.dotfiles/bash ~/.bash

if [[ "$platform" == 'osx' ]]; then
  ln -sf ~/.dotfiles/iterm2_profiles/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
fi

ln -s ~/.dotfiles/config/nvim/ ~/.config/nvim
ln -s ~/.dotfiles/rgignore ~/.rgignore
ln -s ~/.dotfiles/reveal.js ~/reveal.js
ln -s ~/.dotfiles/bash_profile ~/.bash_profile
ln -s ~/.dotfiles/bashrc ~/.bashrc
ln -s ~/.dotfiles/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/gitignore ~/.gitignore
ln -s ~/.dotfiles/profile ~/.profile
ln -s ~/.dotfiles/psqlrc ~/.psqlrc
ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/git/contrib/completion/git-completion.bash ~/.git-completion.bash
ln -s ~/.dotfiles/scripts/templatemux /usr/local/bin/templatemux

# Install NVM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.9/install.sh | bash

if [[ "$platform" == 'linux' ]]; then
  echo "Please restart the shell and run the following: "
  echo "nvm install --lts"
  echo "nvm use --lts"
  echo "npm install -g prettier"
  echo "nvim +PackerInstall +qall"
else
  nvm install --lts
  nvm use --lts
  npm install -g prettier
  nvim +PackerInstall +qall
fi

./install-fish.sh
