#!/bin/bash

brew install fish
# initialize config
ln -sfn ~/.dotfiles/config/fish/ ~/.config/fish

# install fisher for plugin support
fish -c '[ ! -f ~/.dotfiles/config/fish/fish_plugins ]; and curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
fish -c 'fisher update'
fish -c '_nvm_install' # make sure nvm is configured

# add fish to the allowed list of shells
echo /usr/local/bin/fish | sudo tee -a /etc/shells
# set fish as the default shell
chsh -s /usr/local/bin/fish
