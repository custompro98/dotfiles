function krestart -d "Restart the given deployment" -a app
  kubectl rollout restart deployment/$app
end
