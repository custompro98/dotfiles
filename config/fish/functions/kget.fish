function kget -d 'List kubernetes resources for the given app' -a resource app
  kubectl get $resource (if set -q app; echo "-l app=$app"; end)
end
