#!/usr/bin/env bash
# Tests for bin/on-workspace-closed against a temp repo and a stub herdr.
set -uo pipefail
source "$(dirname "$0")/helpers.sh"

close() {
  HERDR_PLUGIN_EVENT_JSON="$1" "$FLOW/bin/on-workspace-closed"
}

test_clean_checkout() {
  local wt
  wt="$(make_worktree feat)"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
  assert "branch kept" git -C "$ROOT" rev-parse --verify feat
  assert "archive script ran in the checkout" grep -qx wt-feat "$ROOT/archived.log"
  assert "nothing stashed" test -z "$(git -C "$ROOT" stash list)"
  assert "no notification" not_called notification
}

test_dirty_checkout() {
  local wt
  wt="$(make_worktree feat)"
  echo two >"$wt/file.txt"
  echo new >"$wt/new.txt"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
  assert "one stash" test "$(git -C "$ROOT" stash list | wc -l | tr -d ' ')" = 1
  assert "stash named for the branch" bash -c "git -C '$ROOT' stash list | grep -q 'flow archive feat'"
  assert "untracked file stashed" bash -c "git -C '$ROOT' show --name-only 'stash@{0}^3' | grep -qx new.txt"
  assert "notified about the stash" called "notification show.*stashed"
}

test_archive_script_fails() {
  local wt
  wt="$(make_worktree feat)"
  printf '[scripts]\narchive = "exit 1"\n' >"$wt/.conductor/settings.local.toml"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
  assert "notified about the failure" called "notification show.*archive script failed"
}

test_repo_workspace_ignored() {
  assert "exits 0" close "$(closed_event "$ROOT" false)"
  assert "repo kept" test -d "$ROOT/.git"
  assert "archive script not run" test ! -e "$ROOT/archived.log"
  assert "no herdr calls" test ! -s "$HERDR_CALLS"
}

test_missing_checkout() {
  assert "exits 0" close "$(closed_event "$TMP/gone" true)"
  assert "archive script not run" test ! -e "$ROOT/archived.log"
}

test_no_workspace_in_event() {
  assert "exits 0" close '{"event":"workspace.closed","data":{"type":"workspace_closed","workspace_id":"w1"}}'
}

test_detached_dirty() {
  local wt
  wt="$(make_worktree feat)"
  git -C "$wt" checkout -q --detach
  echo two >"$wt/file.txt"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
  assert "stash named detached" bash -c "git -C '$ROOT' stash list | grep -q 'flow archive detached'"
}

test_detached_commits_saved() {
  local wt sha
  wt="$(make_worktree feat)"
  git -C "$wt" checkout -q --detach
  echo two >"$wt/file.txt"
  git -C "$wt" commit -q -am "on detached head"
  sha="$(git -C "$wt" rev-parse HEAD)"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
  assert "commit kept on a branch" test "$(git -C "$ROOT" rev-parse flow-archive/wt-feat)" = "$sha"
  assert "notified about the saved commits" called "notification show.*flow-archive/wt-feat"
}

run_tests
