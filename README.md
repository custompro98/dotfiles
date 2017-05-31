# dotfiles

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
