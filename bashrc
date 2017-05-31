cd /apps/project_ouroboros

# Set up prompt to <branch>:<path> $ 
export PS1='\[$txtgrn\]$git_branch \[$txtcyn\]\w\[$txtrst\] 
$ '

# Set up Ruby environment
source /usr/local/share/chruby/chruby.sh
chruby 2.3.1

# Add PostgreSQL server commands to path
# Add any other scripts here into path
export PATH="~/.scripts:$PATH"

# Git Aware Prompt
export GITAWAREPROMPT=~/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"

# Git autocomplete
source ~/.git-completion.bash

### Aliases

# git branch mapping
alias gitg='git log --graph --decorate --oneline'

# bundle exec as brake
alias brake='bundle exec rake'
alias be='bundle exec'
alias railss="(cd ~/rc2-vagrant/; vagrant ssh -c 'cd /var/www/current/; rails s')"
alias railsc="(cd ~/rc2-vagrant/; vagrant ssh -c 'cd /var/www/current/; rails c')"
alias psql="(cd ~/rc2-vagrant/; vagrant ssh -c 'cd /var/www/current/; psql -U postgres -d rc_jpmcstaging -x')"

# vagrant
alias vs="(cd ~/rc2-vagrant; vagrant up; vagrant ssh)"
alias vu="(cd ~/rc2-vagrant; vagrant up)"
alias vd="(cd ~/rc2-vagrant; vagrant halt)"

alias vb="(cd ~/rc2-vagrant; vagrant ssh -c 'cd /var/www/current; bundle install')"

function vrake {
  echo -e "\n Executing \033[1m\033[36mrake $1 \033[0mon \033[33mvagrant\033\0m\n"
  (cd ~/rc2-vagrant; vagrant up; vagrant ssh -c "cd /var/www/current; bundle exec rake $1")
}

function vspec {
  echo -e "\n Executing \033[1m\033[36mrspec $1 \033[0mon \033[33mvagrant\033\0m\n"
  (cd ~/rc2-vagrant; vagrant up; vagrant ssh -c "cd /var/www/current; bundle exec rspec $1")
}

# docker
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
  docker attach --sig-proxy=false $container
}

alias dc=docker-compose
alias de=docker_compose_exec
alias da=docker_compose_attach

# alias railss="dc restart web; da web" 
# alias psql="dc run -e PGPASSWORD=password postgres psql -x -d rc_jpmcstaging -U postgres -h postgres"
