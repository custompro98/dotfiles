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

# Save a worktree checkout as refs/flow/archive/<name>-<unix-time> and echo the
# ref: a commit with the archived HEAD as parent 1, a `git stash -u` commit of
# uncommitted work as parent 2 (when dirty), and Flow-* trailers. Leaves the
# checkout in place; on failure after stashing, the work stays in the stash.
flow_archive_save() {
  local path="$1" label="$2" name head branch session stash="" msg commit ref
  name="$(basename "$path")"
  head="$(git -C "$path" rev-parse HEAD)" || return 1
  branch="$(git -C "$path" branch --show-current)"
  session="$(flow_session_for "$path" "$path")"

  if [ -n "$(git -C "$path" status --porcelain)" ]; then
    git -C "$path" stash push -q -u -m "flow archive $name" || { echo "couldn't stash changes in $path" >&2; return 1; }
    stash="$(git -C "$path" rev-parse refs/stash)"
  fi

  msg="flow archive $name"$'\n\n'"Flow-Name: $name"$'\n'"Flow-Path: $path"$'\n'"Flow-Label: $label"
  [ -z "$branch" ] || msg+=$'\n'"Flow-Branch: $branch"
  [ -z "$session" ] || msg+=$'\n'"Flow-Session: $session"

  ref="refs/flow/archive/$name-$(date +%s)"
  if ! commit="$(git -C "$path" commit-tree "$head^{tree}" -p "$head" ${stash:+-p "$stash"} -m "$msg")" ||
    ! git -C "$path" update-ref "$ref" "$commit" "" 2>&1 >&2; then
    if [ -n "$stash" ]; then
      echo "couldn't write $ref; uncommitted work is in git stash: flow archive $name" >&2
    else
      echo "couldn't write $ref" >&2
    fi
    return 1
  fi

  if [ -n "$stash" ] && [ "$(git -C "$path" rev-parse -q --verify 'stash@{0}')" = "$stash" ]; then
    git -C "$path" stash drop -q
  fi
  echo "$ref"
}

# A repo's archives, newest first, one TSV line each:
# ref, name, branch, path, label, session, archived-at (unix). Empty fields
# stay as empty columns, so split with cut/awk -F'\t', not `read`.
flow_archive_list() {
  local t='%(trailers:key=Flow-KEY,valueonly,separator=)' fmt
  fmt="%(refname)"
  for key in Name Branch Path Label Session; do fmt+="%09${t/KEY/$key}"; done
  git -C "$1" for-each-ref --sort=-creatordate --format="$fmt%09%(creatordate:unix)" refs/flow/archive/
}

# One Flow-* trailer of an archive ref: flow_archive_trailer <root> <ref> <key>.
flow_archive_trailer() {
  git -C "$1" log -1 --format="%(trailers:key=$3,valueonly,separator=)" "$2"
}

# Recreate an archived worktree at its recorded path and re-apply its
# uncommitted work. Refuses (non-zero, message on stderr, nothing created) when
# the path exists or the branch is checked out elsewhere. Otherwise prints why
# the archive ref must be kept (conflicts, rewritten branch), or nothing.
flow_archive_checkout() {
  local root="$1" ref="$2" path branch head reasons=() applied=true
  path="$(flow_archive_trailer "$root" "$ref" Flow-Path)"
  branch="$(flow_archive_trailer "$root" "$ref" Flow-Branch)"
  head="$(git -C "$root" rev-parse "$ref^1")"

  [ ! -e "$path" ] || { echo "$path already exists" >&2; return 1; }
  if [ -n "$branch" ] && git -C "$root" show-ref --verify -q "refs/heads/$branch"; then
    if git -C "$root" worktree list --porcelain | grep -qx "branch refs/heads/$branch"; then
      echo "$branch is checked out in another worktree" >&2
      return 1
    fi
    git -C "$root" worktree add -q "$path" "$branch" || return 1
  elif [ -n "$branch" ]; then
    git -C "$root" worktree add -q -b "$branch" "$path" "$head" || return 1
  else
    git -C "$root" worktree add -q --detach "$path" "$head" || return 1
  fi

  if git -C "$root" rev-parse -q --verify "$ref^2" >/dev/null; then
    if ! git -C "$path" stash apply -q --index "$ref^2" >/dev/null 2>&1; then
      if [ -z "$(git -C "$path" diff --name-only --diff-filter=U)" ]; then
        git -C "$path" stash apply -q "$ref^2" >/dev/null 2>&1 || applied=false
      else
        applied=false
      fi
    fi
    if ! $applied || [ -n "$(git -C "$path" diff --name-only --diff-filter=U)" ]; then
      reasons+=("changes didn't apply cleanly; resolve them in $path, then run: git update-ref -d $ref")
    fi
  fi

  if [ -n "$branch" ] && ! git -C "$root" merge-base --is-ancestor "$head" "refs/heads/$branch"; then
    reasons+=("$branch no longer contains the archived commits; they're kept in $ref")
  fi

  [ ${#reasons[@]} -eq 0 ] || (IFS=$'\n'; echo "${reasons[*]}")
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
