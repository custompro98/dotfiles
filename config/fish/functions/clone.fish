function clone -d "Clone a git repository" -a org repo
  echo $org $repo | xargs -n2 sh -c 'git clone "git@github.com:$0/$1.git"'
end
