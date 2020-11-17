function kexec -d "Run a command on a running pod for app" -a command app
  kubectl exec -it (kname $app) -- "$command"
end
