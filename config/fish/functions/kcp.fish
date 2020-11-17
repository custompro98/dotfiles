function kcp -d "Copy a file from local to a Kubernetes pod" -a app localPath remotePath clusterPath
  set -l namespace (if [ -n "$clusterPath" ]; echo "$clusterPath"; else; echo "default"; end)

  kubectl cp $localPath $namespace/(kname $app):$remotePath
end
