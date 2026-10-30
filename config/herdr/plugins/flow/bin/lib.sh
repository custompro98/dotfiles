# Shared helpers for the flow plugin. Sourced, not executed.

HERDR="${HERDR_BIN_PATH:-herdr}"
FLOW_BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() {
  printf '\033[31m%s\033[0m\n' "$*" >&2
  exit 1
}

# Pause so a popup doesn't vanish before the error can be read.
die_popup() {
  printf '\033[31m%s\033[0m\n' "$*" >&2
  read -r -n 1 -p "press any key to close"
  exit 1
}

# Path of the primary checkout, even when called from inside a linked worktree.
flow_root_path() {
  git -C "$1" worktree list --porcelain | awk '/^worktree /{ print substr($0, 10); exit }'
}

flow_default_branch() {
  local ref
  if ref="$(git -C "$1" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"; then
    echo "${ref#origin/}"
  else
    echo main
  fi
}

# Base ref to diff/branch against: origin/<default> when it exists, else local.
flow_base_ref() {
  local default
  default="$(flow_default_branch "$1")"
  if git -C "$1" rev-parse --verify --quiet "origin/$default" >/dev/null; then
    echo "origin/$default"
  else
    echo "$default"
  fi
}

# Script from conductor.json, preferring the worktree's copy over the root's.
flow_script() {
  local dir="$1" name="$2" file
  for file in "$dir/conductor.json" "$(flow_root_path "$dir")/conductor.json"; do
    if [ -f "$file" ]; then
      jq -r --arg name "$name" '.scripts[$name] // empty' "$file"
      return
    fi
  done
}

# Same variables Conductor exposes, so existing conductor.json scripts work as-is.
flow_export_env() {
  local dir="$1" hash
  hash="$(printf '%s' "$dir" | cksum | cut -d' ' -f1)"
  export CONDUCTOR_WORKSPACE_PATH="$dir"
  export CONDUCTOR_WORKSPACE_NAME="$(basename "$dir")"
  export CONDUCTOR_ROOT_PATH="$(flow_root_path "$dir")"
  export CONDUCTOR_DEFAULT_BRANCH="$(flow_default_branch "$dir")"
  # 10 ports per workspace, stable for a given path.
  export CONDUCTOR_PORT=$((55000 + hash % 1000 * 10))
}

# The flow_export_env variables as KEY=VALUE lines, for herdr --env flags.
flow_env_lines() {
  (flow_export_env "$1" && env | grep '^CONDUCTOR_')
}

# Fuzzy-pick a repo under FLOW_REPO_DIRS (colon-separated, default ~/apps and
# ~/.dotfiles) and print its path.
flow_pick_repo() {
  local roots pick
  IFS=: read -r -a roots <<<"${FLOW_REPO_DIRS:-$HOME/apps:$HOME/.dotfiles}"
  pick="$(fd -H -t d '^\.git$' "${roots[@]}" --max-depth 4 --prune 2>/dev/null |
    sed -e 's#/\.git/*$##' -e "s#^$HOME#~#" | sort |
    fzf --prompt "${1:-repo> }" --height 100% --reverse)" || return 1
  echo "${pick/#\~/$HOME}"
}

# Workspace for a repo's main checkout, opening one if it isn't open yet.
flow_repo_workspace() {
  local root="$1" focus="${2:---no-focus}" ws out
  ws="$("$HERDR" workspace list | jq -r --arg root "$root" '
    [.result.workspaces[] | select(.worktree.checkout_path == $root and (.worktree.is_linked_worktree | not))][0].workspace_id // empty')"
  if [ -z "$ws" ]; then
    out="$("$HERDR" workspace create --cwd "$root" --label "$(basename "$root")" "$focus" 2>&1)" || { echo "$out" >&2; return 1; }
    ws="$(jq -r '.result.workspace.workspace_id' <<<"$out")"
  elif [ "$focus" = --focus ]; then
    "$HERDR" workspace focus "$ws" >/dev/null
  fi
  echo "$ws"
}

# First agent pane in a workspace, e.g. the opencode pane.
flow_agent_pane() {
  "$HERDR" agent list |
    jq -r --arg ws "$1" '[.result.agents[]? | select(.workspace_id == $ws)][0].pane_id // empty'
}
