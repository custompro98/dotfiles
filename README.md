# dotfiles

## Easy Installation
git clone https://github.com/custompro98/dotfiles.git ~/.dotfiles
cp ~/.dotfiles/iterm2_profiles/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
sh ~/.dotfiles/install.sh

## Installation
- `brew install ag`
- `brew install ctags`
- `git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim`
- `brew tap thoughtbot/formulae`
- `brew install rcm`
- `rcup -x Control.cache -x README.md -x Sublime`
- `ln -s ~/.dotfiles/Sublime/Packages ~/Library/Application\ Support/Sublime\ Text\ 3/Packages`
- Open vim
  - `:PluginInstall`
  - `:Rtags` to generate ctags per project

## Configuration
Set iterm to use installed font (fixes fonts for vim-airline)
