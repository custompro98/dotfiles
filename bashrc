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

# Git autocomplete
source ~/.git-completion.bash

# Gogh for Gnome/Pantheon Terminal Colorschemes
alias gogh='sudo apt-get install dconf-cli && wget -O gogh https://git.io/vQgMr && chmod +x gogh && ./gogh && rm gogh'

### Aliases

## Git
# git branch mapping
alias gitg='git log --graph --decorate --oneline'
alias add_git_ssh="ssh-add ~/.ssh/id_rsa"

## Ruby
alias brake='bundle exec rake'
alias be='bundle exec'

## Docker
alias dc=docker-compose
alias de=docker_compose_exec
alias da=docker_compose_attach

## Kube
alias kubestaging='export KUBECONFIG=~/.kube/kubeconfig.kube-user-stage'
alias kubeprod='export KUBECONFIG=~/.kube/kubeconfig.kube-user-prod'

## Misc
alias uuid='uuidgen | tr "[:upper:]" "[:lower:]"'

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
function kubels {
  kubectl get pods -l app=$1
}

function kubehist {
  app=$1
  rev=$2

  if [ -z "$rev" ]; then
    kubectl rollout history deployment/$app
  else
    kubectl rollout history deployment/$app --revision $rev
  fi
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
