cd /apps/project_ouroboros

# Set up prompt to <branch>:<path> $
export PS1='\[$txtgrn\]$git_branch \[$txtcyn\]\w\[$txtrst\]
$ '

# Set up Ruby environment
source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/share/chruby/chruby.sh
chruby 2.3.4

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

# start scheduler
alias scheduler='bundle exec rake resque:scheduler'

# start worker
alias work='QUEUE=* bundle exec rake resque:work'


alias add_git_ssh="ssh-add ~/.ssh/id_rsa"
