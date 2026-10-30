#!/bin/bash

function print_checking() {
  echo -e "\033[0;31m...checking for $1"
}

function print_installing() {
  echo -e "\033[0;33m...installing $1"
}

function print_updating() {
  echo -e "\033[0;33m...installing $1"
}

function print_installed() {
  echo -e "\033[0;32m... $1 installed"
}

function set_brew_path() {
  BREW_PATH=$(brew --prefix)
}

set_brew_path

## AGENT HARNESSES - OpenCode, Claude

print_checking "opencode"
if ! command -v opencode &> /dev/null
then
  print_installing "opencode"

  brew install opencode
else
  print_updating "opencode"

  brew upgrade opencode
fi

mkdir -p ~/.config/opencode
ln -sFfn ~/.dotfiles/config/opencode/cli.json ~/.config/opencode/cli.json

print_installed "opencode"

print_checking "claude"
if ! command -v claude &> /dev/null
then
  print_installing "claude"

  brew install --cask claude-code
else
  print_updating "claude"

  brew upgrade claude-code
fi

print_installed "claude"

## REVIEW TOOLING - plannotator

print_checking "plannotator"
if ! command -v plannotator &> /dev/null
then
  print_installing "plannotator"
else
  print_updating "plannotator"
fi

# Binary only; the opencode plugin below provides /plannotator-review.
curl -fsSL https://plannotator.ai/install.sh | bash -s -- --minimal

if ! opencode plugin list | grep -q plannotator
then
  opencode plugin add @plannotator/opencode@latest
fi

print_installed "plannotator"

## AGENT MANAGEMENT - herdr

print_checking "herdr"
if ! command -v herdr &> /dev/null
then
  print_installing "herdr"

  brew install herdr
else
  print_updating "herdr"

  brew upgrade herdr
fi

### Integrations

herdr integration install claude
herdr integration install opencode

### Plugins

herdr plugin install kryptamine/herdr-auto-title
herdr plugin install ChmaraX/herdr-nvim
herdr plugin link ~/.dotfiles/config/herdr/plugins/flow

### Config

mkdir -p ~/.config/herdr
ln -sFfn ~/.dotfiles/config/herdr/config.toml ~/.config/herdr/config.toml

### Skills

npx skills add herdrdev/herdr --skill herdr -g

print_installed "herdr"
