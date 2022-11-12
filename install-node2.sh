#!/bin/bash

if [! -d "~/dev/microsoft/vscode-node-debug2"]; then
  mkdir -p ~/dev/microsoft
  git clone https://github.com/microsoft/vscode-node-debug2.git ~/dev/microsoft/vscode-node-debug2
fi

cd ~/dev/microsoft/vscode-node-debug2
npm install
npm run build
