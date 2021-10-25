# env variables
## general
set EDITOR nvim

## golang
set GOPATH $HOME/go
set GOBIN $GOPATH/bin
set PATH $PATH $GOBIN

# sourcing shell tools
## nvm
### nvm is acting funky and resourcing itself a bunch, just use it when you need it

## g
set -gx GOPATH $HOME/go; set -gx GOROOT $HOME/.go; set -gx PATH $GOPATH/bin $PATH; # g-install: do NOT edit, see https://github.com/stefanmaric/g

## autojump
[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

# source company-specific aliases
[ -f ~/.company.fish ]; and source ~/.company.fish
