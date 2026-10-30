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

# First agent pane in a workspace, e.g. the opencode pane.
flow_agent_pane() {
  "$HERDR" agent list |
    jq -r --arg ws "$1" '[.result.agents[]? | select(.workspace_id == $ws)][0].pane_id // empty'
}
