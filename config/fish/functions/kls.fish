function kls -d 'List kubernetes pods for the given app' -a app
  kget pods $app
end
