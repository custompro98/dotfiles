#!/bin/bash
brew install ag
brew install ctags
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
brew tap thoughtbot/formulae
brew install rcm
rcup -x Control.cache -x README.md -x Sublime -x install.sh
vim +PluginInstall +qall
