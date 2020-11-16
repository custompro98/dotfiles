# source ~/.bashrc_default

platform='osx'
unamestr=`uname`
if [[ "$unamestr" == 'Linux'  ]]; then
   platform='linux'
fi

# Map xdg-open to open
if [[ "$platform" == 'linux' ]]; then
  alias open="xdg-open"
fi

# Set up prompt to (branch) current/working/directory
# $
export PS1='\[$txtgrn\]$git_branch \[$txtcyn\]\w\[$txtrst\]
$ '

# Set up Ruby environment
if [[ "$platform" == 'osx' ]]; then
  source /usr/local/opt/chruby/share/chruby/chruby.sh
  source /usr/local/share/chruby/chruby.sh
else
  source /usr/local/share/chruby/chruby.sh
fi

# Add PostgreSQL server commands to path
# Add any other scripts here into path
export PATH="~/.scripts:$PATH"

# Git Aware Prompt
export GITAWAREPROMPT=~/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"

# Set up go path
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin
export PATH=$PATH:$GOBIN

# Set nvim as EDITOR
export EDITOR=nvim

# Git autocomplete
source ~/.git-completion.bash

# Gogh for Gnome/Pantheon Terminal Colorschemes
alias gogh='sudo apt-get install dconf-cli && wget -O gogh https://git.io/vQgMr && chmod +x gogh && ./gogh && rm gogh'

### Aliases

alias vim=nvim
alias cat=bat

## Git
# git branch mapping
alias gitg='git log --graph --decorate --oneline'
alias add_git_ssh="ssh-add ~/.ssh/id_rsa"
alias gitversion="git tag --sort=-version:refname | head -1"

## Ruby
alias brake='bundle exec rake'
alias be='bundle exec'

## Docker
alias dc=docker-compose
alias de=docker_compose_exec
alias da=docker_compose_attach
alias dk='docker stop $(docker ps -qa)'

## Kube
alias kc='kubectl'

## Misc
alias uuid='uuidgen | tr "[:upper:]" "[:lower:]"'
alias dt='ruby ~/.dotfiles/scripts/open_dev_tools.rb'

### Functions
## Docker
function docker_compose_container {
  dirname=${PWD##*/}
  # basename="${dirname//[ _-]/}"
  container="${dirname}_$1_1"
  echo $container
}

function docker_compose_exec {
  container=$(docker_compose_container $1)
  shift
  echo -e "\nExecuting the provided command within a running container:"
  echo -e "\n\033[1m\033[36mdocker exec -it \033[92m$container \033[33m$@\033[0m\n"
  docker exec -it $container $@
}

function docker_compose_attach {
  container=$(docker_compose_container $1)
  shift
  echo -e "\nAttaching to a running service:"
  echo -e "\n\033[1m\033[36mdocker attach \033[92m$container \033[0m\n"
  docker attach $container
}

## Kube
function kls { kubectl get pods ${1:+-l app=$1}; }
function kgress() { kubectl get ingress ${1:+-l app=$1}; }

function khist {
  app=$1
  rev=$2

  kubectl rollout history deployment/$app ${rev:+--revision $rev}
}

function kname() { kubectl get pods -l app="$1" --field-selector=status.phase=Running --sort-by=".metadata.creationTimestamp" | tail -n +2 | tail -1 | awk '{print $1}'; }
function ksh()   { kubectl exec -it $(kname "$1") -- sh; }
function kbash() { kubectl exec -it $(kname "$1") -- bash; }
function kcp() {
  # Copy a file from local to a Kubernetes pod
  # @param {string} $1 Local file path
  # @param {string} $2 App name
  # @param {string} $3 Remote file path
  # @param {string=default} $4 Cluster name
  kubectl cp $1 ${4:-default}/$(kname "$2"):$3
}
function krcp() {
  # Copy a file from Kubernetes pod to local
  # @param {string} $1 Local file path
  # @param {string} $2 App name
  # @param {string} $3 Remote file path
  # @param {string=default} $4 Cluster name
  kubectl cp ${4:-default}/$(kubename "$2"):$3 $1
}
function kforward() {
  # Open a port forward socket to a remote Kubernetes deployment
  # @param {string} $1 Deployment name
  # @param {number} $2 Local port number
  # @param {number=} $3 Remote port number
  kubectl port-forward "deployment/$1" "$2${3:+:$3}"
}

## Misc
function run_n_times {
  end=$1
  shift

  echo -e "\nRunning: $@\n"

  for run in $(seq 1 $end); do
    $@
  done
}

### Tool settings
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

# Add company specific commands if they exist
COMPANY_COMMANDS=~/.companyrc
if [ -f "$COMPANY_COMMANDS" ]; then
  source $COMPANY_COMMANDS
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
