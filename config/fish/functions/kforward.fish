function kforward -d "Open a port forward socket to a remote kubernetes deployment" -a deployment local remote
  kubectl port-forward deployment/$deployment $local:(if [ -n "$remote" ]; echo "$remote"; else; echo "$local"; end)
end
