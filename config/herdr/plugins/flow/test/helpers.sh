# Shared helpers for flow's bash tests. Sourced, not executed.

FLOW="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILURES=0

# A temp git repo with one commit and an archive script that appends the
# workspace name to $ROOT/archived.log. Sets TMP and ROOT, and points
# FLOW_WORKTREES_DIR at $TMP/worktrees.
make_repo() {
  TMP="$(cd "$(mktemp -d)" && pwd -P)"
  ROOT="$TMP/repo"
  export FLOW_WORKTREES_DIR="$TMP/worktrees"
  mkdir -p "$ROOT/.conductor"
  git -C "$ROOT" init -q -b main
  git -C "$ROOT" config user.email test@example.com
  git -C "$ROOT" config user.name test
  echo one >"$ROOT/file.txt"
  printf 'archived.log\n.conductor/settings.local.toml\n' >"$ROOT/.gitignore"
  cat >"$ROOT/.conductor/settings.toml" <<'EOF'
[scripts]
archive = 'echo "$CONDUCTOR_WORKSPACE_NAME" >> "$CONDUCTOR_ROOT_PATH/archived.log"'
EOF
  git -C "$ROOT" add -A
  git -C "$ROOT" commit -q -m init
}

# A worktree on a new branch <name>, where herdr would put it. Prints its path.
make_worktree() {
  local path="$FLOW_WORKTREES_DIR/repo/${1//\//-}"
  git -C "$ROOT" worktree add -q -b "$1" "$path"
  echo "$path"
}

# Fake herdr that records each call's argv as a line in $HERDR_CALLS. Answers
# `workspace get` with $STUB_WORKSPACE_JSON, `worktree list` with
# $STUB_WORKTREE_LIST_JSON (default: none), and gives canned ids (workspace w9,
# panes w9:p1/w9:p2) to `worktree open`, `pane list` and `pane split`.
stub_herdr() {
  export HERDR_CALLS="$TMP/herdr-calls"
  export HERDR_BIN_PATH="$TMP/herdr"
  unset STUB_WORKSPACE_JSON STUB_WORKTREE_LIST_JSON
  : >"$HERDR_CALLS"
  cat >"$HERDR_BIN_PATH" <<'EOF'
#!/usr/bin/env bash
echo "$*" >>"$HERDR_CALLS"
case "$1 $2" in
  "workspace get") printf '%s\n' "$STUB_WORKSPACE_JSON" ;;
  "worktree list") none='{"result":{"worktrees":[]}}'; printf '%s\n' "${STUB_WORKTREE_LIST_JSON:-$none}" ;;
  "worktree open") echo '{"result":{"workspace":{"workspace_id":"w9"}}}' ;;
  "pane list") echo '{"result":{"panes":[{"pane_id":"w9:p1"}]}}' ;;
  "pane split") echo '{"result":{"pane":{"pane_id":"w9:p2"}}}' ;;
  *) echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$HERDR_BIN_PATH"
}

# Fake opencode that records "$PWD $*" per call in $OPENCODE_CALLS, prints
# ${STUB_SESSIONS_JSON:-[]} and exits ${STUB_OPENCODE_EXIT:-0}.
stub_opencode() {
  export OPENCODE_CALLS="$TMP/opencode-calls"
  export FLOW_OPENCODE_BIN="$TMP/opencode"
  unset STUB_SESSIONS_JSON STUB_OPENCODE_EXIT
  : >"$OPENCODE_CALLS"
  cat >"$FLOW_OPENCODE_BIN" <<'EOF'
#!/usr/bin/env bash
echo "$PWD $*" >>"$OPENCODE_CALLS"
printf '%s\n' "${STUB_SESSIONS_JSON:-[]}"
exit "${STUB_OPENCODE_EXIT:-0}"
EOF
  chmod +x "$FLOW_OPENCODE_BIN"
}

# Succeeds when the command fails, for assert.
fails() { ! "$@"; }

called() { grep -q -- "$1" "$HERDR_CALLS"; }
not_called() { ! grep -q -- "$1" "$HERDR_CALLS"; }

created_event() {
  jq -nc --arg ws "$1" --arg path "$2" '
    {event: "worktree.created", data: {workspace: {workspace_id: $ws}, worktree: {path: $path}}}'
}

closed_event() {
  jq -nc --arg root "$ROOT" --arg path "$1" --argjson linked "$2" '
    {event: "workspace.closed", data: {type: "workspace_closed", workspace_id: "w1",
      workspace: {workspace_id: "w1", label: "x",
        worktree: {repo_key: "k", repo_name: "repo", repo_root: $root,
          checkout_path: $path, is_linked_worktree: $linked}}}}'
}

# Close a worktree's workspace the way herdr's workspace.closed hook sees it.
close_wt() {
  HERDR_PLUGIN_EVENT_JSON="$(closed_event "$1" true)" "$FLOW/bin/on-workspace-closed"
}

assert() {
  local desc="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "ok   $desc"
  else
    echo "FAIL $desc"
    FAILURES=$((FAILURES + 1))
  fi
}

# Run every test_* function, each against a fresh repo and herdr/opencode stubs.
run_tests() {
  local t
  for t in $(declare -F | awk '$3 ~ /^test_/ { print $3 }'); do
    echo "# $t"
    make_repo
    stub_herdr
    stub_opencode
    "$t"
    rm -rf "$TMP"
  done
  [ "$FAILURES" -eq 0 ] || { echo "$FAILURES failed"; exit 1; }
}
