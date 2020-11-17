function krcp -d "Copy a file from a Kubernetes pod to local" -a app localPath remotePath clusterPath
  set -l namespace (if [ -n "$clusterPath" ]; echo "$clusterPath"; else; echo "default"; end)

  kubectl cp $namespace/(kname $app):$remotePath $localPath
end
