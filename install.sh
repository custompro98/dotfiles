#!/bin/bash

platform='osx'
unamestr=`uname`
if [[ "$unamestr" == 'Linux'  ]]; then
   platform='linux'
fi

if [[ "$platform" == 'linux' ]]; then
  sudo apt install silversearcher-ag
  sudo apt install exuberant-ctags
else
  brew install ag
  brew install ctags
fi

(cd ~/.dotfiles/vim; git submodule update --init)

ln -s ~/.dotfiles/bash ~/.bash
ln -s ~/.dotfiles/vim ~/.vim

if [[ "$platform" == 'osx' ]]; then
  ln -sf ~/.dotfiles/iterm2_profiles/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
fi

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

ln -s ~/.dotfiles/vim/vimrc ~/.vimrc
ln -s ~/.dotfiles/reveal.js ~/reveal.js
ln -s ~/.dotfiles/bash_profile ~/.bash_profile
ln -s ~/.dotfiles/bashrc ~/.bashrc
ln -s ~/.dotfiles/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/profile ~/.profile
ln -s ~/.dotfiles/psqlrc ~/.psqlrc
ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/git/contrib/completion/git-completion.bash ~/.git-completion.bash

vim +PluginInstall +qall
