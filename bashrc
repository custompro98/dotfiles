# cd /apps/project_ouroboros

platform='osx'
unamestr=`uname`
if [[ "$unamestr" == 'Linux'  ]]; then
   platform='linux'
fi

# Set up prompt to <branch>:<path> $
export PS1='\[$txtgrn\]$git_branch \[$txtcyn\]\w\[$txtrst\]
$ '

# Set up Ruby environment
if [[ "$platform" == 'osx' ]]; then
  source /usr/local/opt/chruby/share/chruby/chruby.sh
  source /usr/local/share/chruby/chruby.sh
  chruby 2.4.1
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

# git branch mapping
alias gitg='git log --graph --decorate --oneline'

# bundle exec as brake
alias brake='bundle exec rake'
alias be='bundle exec'

# start scheduler
alias scheduler='bundle exec rake resque:scheduler'

# start worker
alias worker='QUEUE=* bundle exec rake resque:work'

# start resque web
alias watcher='bundle exec resque-web -p 8555 -L -f config/resque-web.rb'

alias add_git_ssh="ssh-add ~/.ssh/id_rsa"
alias clear_lonely_jobs="redis-cli KEYS *lonely_job:microsoft-refresh-*-elasticsearch-documents | xargs redis-cli DEL"

alias dc=docker-compose
alias de=docker_compose_exec
alias da=docker_compose_attach
alias rs='dc up -d web && da web'

### Tool settings
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

### DOCKER
function docker_compose_container {
  dirname=${PWD##*/}
  basename="${dirname//[ _-]/}"
  container="${COMPOSE_PROJECT_NAME:-$basename}_$1_1"
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
