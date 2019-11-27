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
  brew install nvim
  brew install ag
  brew install ctags
  brew install tree
fi

(cd ~/.dotfiles/vim; git submodule update --init)

ln -s ~/.dotfiles/bash ~/.bash
ln -s ~/.dotfiles/vim ~/.vim

if [[ "$platform" == 'osx' ]]; then
  ln -sf ~/.dotfiles/iterm2_profiles/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
fi

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

mkdir -p ~/.config/nvim

ln -s ~/.dotfiles/config/nvim/init.vim ~/.config/nvim/init.vim
ln -s ~/.dotfiles/vim/vimrc ~/.vimrc
ln -s ~/.dotfiles/agignore ~/.agignore
ln -s ~/.dotfiles/ctags ~/.ctags
ln -s ~/.dotfiles/reveal.js ~/reveal.js
ln -s ~/.dotfiles/bash_profile ~/.bash_profile
ln -s ~/.dotfiles/bashrc ~/.bashrc
ln -s ~/.dotfiles/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/gitignore ~/.gitignore
ln -s ~/.dotfiles/profile ~/.profile
ln -s ~/.dotfiles/psqlrc ~/.psqlrc
ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/git/contrib/completion/git-completion.bash ~/.git-completion.bash

# Install NVM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.9/install.sh | bash
if [[ "$platform" == 'Linux' ]]; then
  echo "Please restart the shell and run the following: "
  echo "nvm install --lts"
  echo "nvm use --lts"
  echo "npm install -g prettier"
  echo "vim +PluginInstall +qall"
else
  nvm install --lts
  nvm use --lts
  npm install -g prettier
  vim +PluginInstall +qall
fi
