function kbash -d "SSH into a running pod for app" -a app
  kexec bash $app
end
