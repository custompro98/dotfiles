function ksh -d "SSH into a running pod for app" -a app
  kexec sh $app
end
