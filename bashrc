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
  chruby 2.3.4
fi

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
alias worker='QUEUE=* bundle exec rake resque:work'

# start resque web
alias watcher='bundle exec resque-web -p 8555 -L -f config/resque-web.rb'

alias add_git_ssh="ssh-add ~/.ssh/id_rsa"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh
