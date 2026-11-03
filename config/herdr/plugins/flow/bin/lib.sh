# Shared helpers for the flow plugin. Sourced, not executed.

HERDR="${HERDR_BIN_PATH:-herdr}"
OPENCODE="${FLOW_OPENCODE_BIN:-opencode}"
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

# Conductor's Files to copy patterns: .worktreeinclude at the repo root, else
# file_include_globs, else .env*.
flow_include_patterns() {
  local root
  root="$(flow_root_path "$1")"
  if [ -f "$root/.worktreeinclude" ]; then
    cat "$root/.worktreeinclude"
  else
    flow_settings "$1" | jq -r 'if has("file_include_globs") then .file_include_globs else ".env*" end'
  fi
}

# Copy gitignored files matching the include patterns (gitignore syntax) from
# the main checkout into a new worktree at the same relative paths.
flow_copy_files() {
  local worktree="$1" root patterns file status=0
  root="$(flow_root_path "$worktree")"
  [ "$root" != "$worktree" ] || return 0
  # A real file: git sizes --exclude-from with fstat, which misreads pipes.
  patterns="$(mktemp)"
  flow_include_patterns "$worktree" >"$patterns"
  while IFS= read -r -d '' file; do
    mkdir -p "$worktree/$(dirname "$file")" && cp -p "$root/$file" "$worktree/$file" || status=1
  done < <(git -C "$root" ls-files -z --others --ignored --exclude-from="$patterns" |
    git -C "$root" check-ignore -z --stdin)
  rm -f "$patterns"
  return "$status"
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

# Herdr agent name for a workspace's opencode, set by `agent start` in
# on-worktree-created. Names must match [a-z][a-z0-9_-]{0,31}.
flow_agent_name() {
  local ws
  ws="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_-' '-')"
  printf 'opencode-%s\n' "${ws:0:23}"
}

# The repo's opencode sessions (all worktrees share one project) as a JSON
# array, run from <dir>; [] if opencode isn't available or fails.
flow_sessions_json() {
  local out
  out="$(cd "$1" && "$OPENCODE" session list --format json -n 1000 2>/dev/null)" &&
    jq -e 'type == "array"' >/dev/null 2>&1 <<<"$out" && printf '%s\n' "$out" || echo '[]'
}

# Newest opencode session whose directory is exactly <path>, or nothing.
flow_session_for() {
  flow_sessions_json "$1" |
    jq -r --arg d "$2" '[.[] | select(.directory == $d)] | max_by(.updated) // {} | .id // empty'
}

# Where herdr puts a branch's worktree: <worktrees.directory>/<repo>/<branch
# with / as ->. Reopening there finds the branch's opencode sessions again.
flow_worktrees_dir() {
  echo "${FLOW_WORKTREES_DIR:-$HOME/.herdr/worktrees}"
}

flow_worktree_path() {
  printf '%s/%s/%s\n' "$(flow_worktrees_dir)" "$(basename "$1")" "${2//\//-}"
}

# What deleting the checkout at <path> would lose, one line each; nothing when
# it's safe: uncommitted or untracked (not ignored) files, an operation in
# progress, or a detached HEAD that no branch contains. Commits on a branch are
# safe: the branch outlives the checkout.
flow_pending_changes() {
  local path="$1" out op
  out="$(git -C "$path" status --short 2>&1)" || { echo "git status failed: $out"; return 0; }
  [ -z "$out" ] || printf '%s\n' "$out"
  for op in MERGE_HEAD:merge rebase-merge:rebase rebase-apply:rebase CHERRY_PICK_HEAD:cherry-pick REVERT_HEAD:revert; do
    if [ -e "$(git -C "$path" rev-parse --path-format=absolute --git-path "${op%%:*}")" ]; then
      echo "a ${op#*:} is in progress"
      break
    fi
  done
  if ! git -C "$path" symbolic-ref -q HEAD >/dev/null &&
    [ -z "$(git -C "$path" for-each-ref --contains HEAD --count=1 refs/heads refs/remotes)" ]; then
    echo "detached HEAD $(git -C "$path" rev-parse --short HEAD) isn't on any branch"
  fi
}

# Lay out a fresh worktree workspace: opencode on top, a terminal below running
# the setup script (then the default run action when auto_run_after_setup is
# set). With a session id, opencode resumes that session.
flow_layout() {
  local ws="$1" path="$2" session="${3:-}" agent_pane term_pane setup
  agent_pane="$("$HERDR" pane list --workspace "$ws" | jq -r '.result.panes[0].pane_id')"

  term_pane="$("$HERDR" pane split "$agent_pane" --direction down --ratio 0.7 --cwd "$path" --no-focus |
    jq -r '.result.pane.pane_id // .result.pane_id // empty')"

  if [ -n "$term_pane" ]; then
    "$HERDR" pane rename "$term_pane" terminal >/dev/null
    setup="'$FLOW_BIN/script' setup"
    if [ "$(flow_settings "$path" | jq -r '.scripts.auto_run_after_setup // false')" = true ]; then
      setup+=" && '$FLOW_BIN/run' --default --workspace $ws"
    fi
    "$HERDR" pane run "$term_pane" "$setup" >/dev/null
  fi

  # Named so create-pr and review can target it; returns once opencode is ready.
  local start=("$HERDR" agent start "$(flow_agent_name "$ws")" --kind opencode --pane "$agent_pane")
  [ -z "$session" ] || start+=(-- --session "$session")
  "${start[@]}" >/dev/null
}
