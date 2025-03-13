#!/bin/bash

function set_brew_path() {
  BREW_PATH=$(brew --prefix)
}

set_brew_path

if command -v fish
then
  $BREW_PATH/bin/brew install fish

  # initialize config
  ln -sFfn ~/.dotfiles/config/fish/ ~/.config/fish

  # install fisher for plugin support
  $BREW_PATH/bin/fish -c '[ ! -f ~/.dotfiles/config/fish/fish_plugins ]; and curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'

  # add fish to the allowed list of shells
  echo $BREW_PATH/bin/fish | sudo tee -a /etc/shells
  # set fish as the default shell
  chsh -s $BREW_PATH/bin/fish
  $BREW_PATH/bin/fish -c "set -U fish_user_paths $BREW_PATH/bin $fish_user_paths"
fi

# Install or update fish plugins
$BREW_PATH/bin/fish -c 'fisher update'
$BREW_PATH/bin/fish -c '_nvm_install' # make sure nvm is configured
