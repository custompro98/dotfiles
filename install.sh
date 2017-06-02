#!/bin/bash
mkdir ~/.bash
git clone git://github.com/jimeh/git-aware-prompt.git ~/.bash

brew install ag
brew install ctags
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

brew tap thoughtbot/formulae
brew install rcm
rcup -x Control.cache -x README.md -x Sublime -x install.sh -x iterm2_profiles -x ayu-mirage.itermcolors
cp ~/.dotfiles/iterm2_profiles/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist

vim +PluginInstall +qall
