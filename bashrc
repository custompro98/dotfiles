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
alias psql="(cd ~/rc2-vagrant/; vagrant ssh -c 'cd /var/www/current/; psql -U postgres -d rc_microsoft -x')"

# vagrant
alias vs="(cd ~/rc2-vagrant; vagrant up; vagrant ssh)"
alias vu="(cd ~/rc2-vagrant; vagrant up)"
alias vd="(cd ~/rc2-vagrant; vagrant halt)"
