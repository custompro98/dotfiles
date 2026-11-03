#!/usr/bin/env bash
# Tests for bin/close against a temp repo and stub herdr/opencode.
set -uo pipefail
source "$(dirname "$0")/helpers.sh"

# Close workspace w1 (the given checkout), answering the prompt with $2.
close_ws() {
  export STUB_WORKSPACE_JSON
  STUB_WORKSPACE_JSON="$(jq -nc --arg root "$ROOT" --arg path "$1" --argjson linked "$([ "$1" = "$ROOT" ] && echo false || echo true)" '
    {result: {workspace: {workspace_id: "w1", label: "x",
      worktree: {repo_root: $root, checkout_path: $path, is_linked_worktree: $linked}}}}')"
  HERDR_ACTIVE_WORKSPACE_ID=w1 "$FLOW/bin/close" <<<"${2:-y}"
}

test_clean_closes() {
  local wt
  wt="$(make_worktree feat)"
  assert "exits 0" close_ws "$wt" y
  assert "workspace closed" called "workspace close w1"
}

test_declined() {
  local wt
  wt="$(make_worktree feat)"
  assert "exits 0" close_ws "$wt" n
  assert "workspace not closed" not_called "workspace close"
}

test_dirty_refused() {
  local wt
  wt="$(make_worktree feat)"
  echo two >"$wt/file.txt"
  assert "exits non-zero" fails close_ws "$wt" y
  assert "workspace not closed" not_called "workspace close"
}

test_untracked_refused() {
  local wt
  wt="$(make_worktree feat)"
  echo new >"$wt/new.txt"
  assert "exits non-zero" fails close_ws "$wt" y
  assert "workspace not closed" not_called "workspace close"
}

test_repo_workspace_not_checked() {
  echo dirty >"$ROOT/file.txt"
  assert "exits 0" close_ws "$ROOT" y
  assert "workspace closed" called "workspace close w1"
}

run_tests
