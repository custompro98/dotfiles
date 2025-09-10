if status --is-interactive
  set BREW_PATH (brew --prefix)

  echo "configuring fish"
  # env variables # general
  set -x EDITOR nvim
  fish_add_path $HOME/.local/bin

  ## rust
  set RUSTPATH $HOME/.cargo/bin
  fish_add_path $RUSTPATH

  ## fzf
  fzf --fish | source
  set -x FZF_DISABLE_KEYBINDINGS 0
  set -x FZF_LEGACY_KEYBINDINGS 0
  set -x FZF_DEFAULT_OPTS "--preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}' --height $FZF_TMUX_HEIGHT"

  # sourcing shell tools
  ## mise
  mise activate fish | source

  ## nvm
  set --universal nvm_default_version lts
  __check_nvm

  ## g
  set -gx GOPATH $HOME/go; set -gx GOROOT $HOME/.go; fish_add_path $GOPATH/bin; # g-install: do NOT edit, see https://github.com/stefanmaric/g

  ## autojump
  [ -f $BREW_PATH/share/autojump/autojump.fish ]; and source $BREW_PATH/share/autojump/autojump.fish

  ## krew
  set -q KREW_ROOT; and fish_add_path $KREW_ROOT/.krew/bin; or fish_add_path $HOME/.krew/bin

  ## bun
  set --export BUN_INSTALL "$HOME/.bun"
  fish_add_path $BUN_INSTALL/bin

  ## perl
  ### plenv
  if which plenv > /dev/null; plenv init - | source ; end

  ## shell
  ### starship
  if command -q starship; starship init fish | source; end

  ## php
  fish_add_path "$HOME/.config/herd-lite/bin"

  ## docker
  not test -e "$HOME/.config/fish/completions/docker.fish"; and docker completion fish > ~/.config/fish/completions/docker.fish


  # source company-specific aliases
  [ -f ~/.company.fish ]; and source ~/.company.fish
  [ -f ~/.overrides.fish ]; and source ~/.overrides.fish
end
