# Force .bashrc to load
case $- in
   *i*) source ~/.bashrc
esac

platform='osx'
unamestr=`uname`
if [[ "$unamestr" == 'Linux'  ]]; then
   platform='linux'
fi

export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"

export ES_HOME=/usr/local/Cellar/elasticsearch@2.4/2.4.6
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home/
export PATH=$ES_HOME/bin:$JAVA_HOME/bin:$PATH

export NVM_DIR="$HOME/.nvm"
if [[ "$platform" == 'linux' ]]; then
  [ -s "$NVM_DIR/nvm.sh"  ] && . "$NVM_DIR/nvm.sh" # This loads nvm
else
  source /usr/local/opt/nvm/nvm.sh
fi

nvm use 6.9.1
