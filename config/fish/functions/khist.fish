function khist -d 'View the history for a kube deployment' -a deployment rev
  # this isn't working yet
  # still getting "unknown flag "revision"
  set -l revision (if set -q rev; echo -n "--revision $rev"; end)

  echo $deployment
  echo $revision

  kubectl rollout history deployment/$deployment $revision
end
