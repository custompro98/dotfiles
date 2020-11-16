#!/bin/bash

platform='osx'
unamestr=`uname`
if [[ "$unamestr" == 'Linux'  ]]; then
   platform='linux'
fi

if [[ "$platform" == 'linux' ]]; then
  sudo apt install fish
else
  brew install fish
fi
# initialize config
ln -sfn ~/.dotfiles/config/fish/ ~/.config/fish

# install fisher for plugin support (comes for free in ~/.config/)
# curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish

# add fish to the allowed list of shells
echo /usr/local/bin/fish | sudo tee -a /etc/shells
# set fish as the default shell
chsh -s /usr/local/bin/fish
