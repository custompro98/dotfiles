# env variables
## general
set EDITOR nvim

## golang
set GOPATH $HOME/go
set GOBIN $GOPATH/bin
set PATH $PATH $GOBIN

# sourcing shell tools
## nvm
nvm use stable

## autojump
[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

# source company-specific aliases
[ -f ~/.company.fish ]; and source ~/.company.fish
