# Shared helpers for flow's bash tests. Sourced, not executed.

FLOW="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILURES=0

# A temp git repo with one commit and an archive script that appends the
# workspace name to $ROOT/archived.log. Sets TMP and ROOT.
make_repo() {
  TMP="$(cd "$(mktemp -d)" && pwd -P)"
  ROOT="$TMP/repo"
  mkdir -p "$ROOT/.conductor"
  git -C "$ROOT" init -q -b main
  git -C "$ROOT" config user.email test@example.com
  git -C "$ROOT" config user.name test
  echo one >"$ROOT/file.txt"
  echo archived.log >"$ROOT/.gitignore"
  cat >"$ROOT/.conductor/settings.toml" <<'EOF'
[scripts]
archive = 'echo "$CONDUCTOR_WORKSPACE_NAME" >> "$CONDUCTOR_ROOT_PATH/archived.log"'
EOF
  git -C "$ROOT" add -A
  git -C "$ROOT" commit -q -m init
}

make_worktree() {
  git -C "$ROOT" worktree add -q -b "$1" "$TMP/wt-$1"
  echo "$TMP/wt-$1"
}

# Fake herdr that records each call's argv as a line in $HERDR_CALLS and
# answers `workspace get` with $STUB_WORKSPACE_JSON.
stub_herdr() {
  export HERDR_CALLS="$TMP/herdr-calls"
  export HERDR_BIN_PATH="$TMP/herdr"
  : >"$HERDR_CALLS"
  cat >"$HERDR_BIN_PATH" <<'EOF'
#!/usr/bin/env bash
echo "$*" >>"$HERDR_CALLS"
if [ "$1 $2" = "workspace get" ]; then
  printf '%s\n' "$STUB_WORKSPACE_JSON"
else
  echo '{"result":{}}'
fi
EOF
  chmod +x "$HERDR_BIN_PATH"
}

closed_event() {
  jq -nc --arg root "$ROOT" --arg path "$1" --argjson linked "$2" '
    {event: "workspace.closed", data: {type: "workspace_closed", workspace_id: "w1",
      workspace: {workspace_id: "w1", label: "x",
        worktree: {repo_key: "k", repo_name: "repo", repo_root: $root,
          checkout_path: $path, is_linked_worktree: $linked}}}}'
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

# Run every test_* function, each against a fresh repo and herdr stub.
run_tests() {
  local t
  for t in $(declare -F | awk '$3 ~ /^test_/ { print $3 }'); do
    echo "# $t"
    make_repo
    stub_herdr
    "$t"
    rm -rf "$TMP"
  done
  [ "$FAILURES" -eq 0 ] || { echo "$FAILURES failed"; exit 1; }
}
