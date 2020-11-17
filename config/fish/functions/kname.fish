function kname -d "Find the first running pod for app" -a app
  kubectl get pods -l app=$app --field-selector=status.phase=Running --sort-by=".metadata.creationTimestamp" | tail -n +2 | tail -1 | awk '{print $1}'
end
