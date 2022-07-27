if status --is-interactive
  echo "configuring fish"
  # env variables
  ## general
  set EDITOR nvim

  ## golang
  set GOPATH $HOME/go
  set GOBIN $GOPATH/bin
  set PATH $PATH $GOBIN

  ## fzf
  set -x FZF_DISABLE_KEYBINDINGS 0
  set -x FZF_LEGACY_KEYBINDINGS 0

  # sourcing shell tools
  ## nvm
  set NODE_VERSION "lts/fermium"
  set NVM_INSTALLED (nvm list $NODE_VERSION)
  [ -z "$NVM_INSTALLED" ]; and nvm install $NODE_VERSION

  set NVM_VSN_SET (nvm current)
  [ -z "$NVM_VSN_SET" ]; and nvm use $NODE_VERSION

  ## g
  set -gx GOPATH $HOME/go; set -gx GOROOT $HOME/.go; set -gx PATH $GOPATH/bin $PATH; # g-install: do NOT edit, see https://github.com/stefanmaric/g

  ## autojump
  [ -f /opt/homebrew/share/autojump/autojump.fish ]; and source /opt/homebrew/share/autojump/autojump.fish

  # source company-specific aliases
  [ -f ~/.company.fish ]; and source ~/.company.fish
end
