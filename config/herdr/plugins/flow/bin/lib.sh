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

# Merged .conductor/settings[.local].toml for a workspace, as JSON.
flow_settings() {
  PATH="$HOME/.bun/bin:$PATH" "$FLOW_BIN/settings.ts" "$1" "$(flow_root_path "$1")"
}

# A string script from [scripts], e.g. setup or archive.
flow_script() {
  flow_settings "$1" | jq -r --arg name "$2" '.scripts[$name] // empty | strings'
}

# Locally available run actions as JSON lines of {id, command, cwd, default},
# default first. A plain `run = "..."` string becomes a single "run" action.
flow_run_actions() {
  flow_settings "$1" | jq -c '
    .scripts.run // empty
    | if type == "string" then [{id: "run", command: ., default: true}]
      else to_entries
        | map(select(.value.available_in // "local" | if type == "array" then index("local") != null else . == "local" end)
          | (.value.args // [] | map(@sh) | join(" ")) as $args
          | {id: .key,
             command: (.value.command + (if $args == "" then "" else " " + $args end)),
             cwd: .value.options.cwd,
             default: (.value.default // false)})
      end
    | sort_by(.default | not) | .[]'
}

# Conductor's CONDUCTOR_* variables plus [environment_variables] (top level and
# [environment_variables.local]) as KEY=VALUE lines.
flow_env_lines() {
  local dir="$1" hash
  hash="$(printf '%s' "$dir" | cksum | cut -d' ' -f1)"
  echo "CONDUCTOR_WORKSPACE_PATH=$dir"
  echo "CONDUCTOR_WORKSPACE_NAME=$(basename "$dir")"
  echo "CONDUCTOR_ROOT_PATH=$(flow_root_path "$dir")"
  echo "CONDUCTOR_DEFAULT_BRANCH=$(flow_default_branch "$dir")"
  # 10 ports per workspace, stable for a given path.
  echo "CONDUCTOR_PORT=$((55000 + hash % 1000 * 10))"
  flow_settings "$dir" | jq -r '
    .environment_variables // {}
    | with_entries(select(.value | type == "string")) + (.local // {})
    | to_entries[] | "\(.key)=\(.value)"'
}

flow_export_env() {
  local line
  while IFS= read -r line; do export "$line"; done < <(flow_env_lines "$1")
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
