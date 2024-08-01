if status --is-interactive
  set BREW_PATH (brew --prefix)

  echo "configuring fish"
  # env variables
  ## general
  set -x EDITOR nvim

  ## golang
  set GOPATH $HOME/go
  set GOBIN $GOPATH/bin
  set -x PATH $PATH $GOBIN

  ## rust
  set RUSTPATH $HOME/.cargo/bin
  set -x PATH $PATH $RUSTPATH

  ## fzf
  set -x FZF_DISABLE_KEYBINDINGS 0
  set -x FZF_LEGACY_KEYBINDINGS 0

  # sourcing shell tools
  ## nvm
  set --universal nvm_default_version 20

  ## g
  set -gx GOPATH $HOME/go; set -gx GOROOT $HOME/.go; set -gx PATH $GOPATH/bin $PATH; # g-install: do NOT edit, see https://github.com/stefanmaric/g

  ## autojump
  [ -f $BREW_PATH/share/autojump/autojump.fish ]; and source $BREW_PATH/share/autojump/autojump.fish

  ## krew
  set -q KREW_ROOT; and set -gx PATH $PATH $KREW_ROOT/.krew/bin; or set -gx PATH $PATH $HOME/.krew/bin

  ## bun
  set --export BUN_INSTALL "$HOME/.bun"
  set --export PATH $BUN_INSTALL/bin $PATH

  ## perl
  ### plenv
  if which plenv > /dev/null; plenv init - | source ; end

  ## shell
  ### starship
  if command -q starship; starship init fish | source; end

  # source company-specific aliases
  [ -f ~/.company.fish ]; and source ~/.company.fish
  [ -f ~/.overrides.fish ]; and source ~/.overrides.fish
end
