function kgress -d 'List kubernetes ingress for the given app' -a app
  kget ingress $app
end
