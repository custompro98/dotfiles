#!/bin/bash

brew install fish
# initialize config
ln -sfn ~/.dotfiles/config/fish/ ~/.config/fish

# install fisher for plugin support
/opt/homebrew/bin/fish -c '[ ! -f ~/.dotfiles/config/fish/fish_plugins ]; and curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
/opt/homebrew/bin/fish -c 'fisher update'
/opt/homebrew/bin/fish -c '_nvm_install' # make sure nvm is configured

# add fish to the allowed list of shells
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
# set fish as the default shell
chsh -s /opt/homebrew/bin/fish
/opt/homebrew/bin/fish -c 'set -U fish_user_paths /opt/homebrew/bin $fish_user_paths'
