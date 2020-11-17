function khist -d 'View the history for a kube deployment' -a deployment revision
  kubectl rollout history deployment/$deployment (if [ -n "$revision" ]; echo "--revision=$revision"; end)
end
