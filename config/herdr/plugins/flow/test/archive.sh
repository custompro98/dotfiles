#!/usr/bin/env bash
# Tests for bin/archive (prefix+shift+a) against a temp repo and a stub herdr.
set -uo pipefail
source "$(dirname "$0")/helpers.sh"

export HERDR_ACTIVE_WORKSPACE_ID=w1

archive_with() {
  local wt="$1" answer="$2"
  export STUB_WORKSPACE_JSON
  STUB_WORKSPACE_JSON="$(jq -nc --arg path "$wt" \
    '{result: {workspace: {label: "feat", worktree: {is_linked_worktree: true, checkout_path: $path}}}}')"
  echo "$answer" | "$FLOW/bin/archive"
}

test_archive_confirmed() {
  local wt
  wt="$(make_worktree feat)"
  assert "exits 0" archive_with "$wt" y
  assert "closes the workspace" grep -qx "workspace close w1" "$HERDR_CALLS"
  assert "leaves removal to the hook" test -d "$wt"
  assert "leaves the archive script to the hook" test ! -e "$ROOT/archived.log"
}

test_archive_declined() {
  local wt
  wt="$(make_worktree feat)"
  assert "exits 0" archive_with "$wt" n
  assert "workspace stays open" bash -c "! grep -q 'workspace close' '$HERDR_CALLS'"
  assert "checkout kept" test -d "$wt"
}

run_tests
