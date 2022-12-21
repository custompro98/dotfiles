# Force .bashrc to load
case $- in
   *i*) source ~/.bashrc
esac

export GOPATH="$HOME/go"; export GOROOT="$HOME/.go"; export PATH="$GOPATH/bin:$PATH"; # g-install: do NOT edit, see https://github.com/stefanmaric/g
. "$HOME/.cargo/env"
