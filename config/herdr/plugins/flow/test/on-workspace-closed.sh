#!/usr/bin/env bash
# Tests for bin/on-workspace-closed against a temp repo and stub herdr/opencode.
set -uo pipefail
source "$(dirname "$0")/helpers.sh"

close() {
  HERDR_PLUGIN_EVENT_JSON="$1" "$FLOW/bin/on-workspace-closed"
}

test_clean_checkout() {
  local wt sha
  wt="$(make_worktree feat)"
  sha="$(git -C "$ROOT" rev-parse feat)"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
  assert "branch kept where it was" test "$(git -C "$ROOT" rev-parse feat)" = "$sha"
  assert "archive script ran in the checkout" grep -qx feat "$ROOT/archived.log"
  assert "no notification" not_called "notification show"
}

test_commits_kept_on_branch() {
  local wt sha
  wt="$(make_worktree feat)"
  echo two >"$wt/file.txt"
  git -C "$wt" commit -q -am "unpushed"
  sha="$(git -C "$wt" rev-parse HEAD)"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
  assert "branch has the commit" test "$(git -C "$ROOT" rev-parse feat)" = "$sha"
}

test_ignored_files_dont_block() {
  local wt
  wt="$(make_worktree feat)"
  echo build >"$wt/archived.log"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
}

test_dirty_checkout_kept() {
  local wt
  wt="$(make_worktree feat)"
  echo two >"$wt/file.txt"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout kept" test -d "$wt"
  assert "edit kept" test "$(cat "$wt/file.txt")" = two
  assert "archive script still ran" grep -qx feat "$ROOT/archived.log"
  assert "notified it was kept" called "notification show flow: kept feat --body .*pending changes.*prefix+shift+o"
}

test_untracked_only_kept() {
  local wt
  wt="$(make_worktree feat)"
  echo new >"$wt/new.txt"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout kept" test -f "$wt/new.txt"
}

test_archive_script_output_doesnt_block() {
  local wt
  wt="$(make_worktree feat)"
  printf '[scripts]\narchive = "touch left-behind.txt"\n' >"$wt/.conductor/settings.local.toml"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
}

test_detached_on_branch_removed() {
  local wt
  wt="$(make_worktree feat)"
  git -C "$wt" checkout -q --detach
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
}

test_detached_commits_kept() {
  local wt
  wt="$(make_worktree feat)"
  git -C "$wt" checkout -q --detach
  git -C "$wt" commit -q --allow-empty -m "on detached head"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout kept" test -d "$wt"
  assert "notified it was kept" called "notification show flow: kept"
}

test_merge_in_progress_kept() {
  local wt
  wt="$(make_worktree feat)"
  echo theirs >"$ROOT/file.txt"
  git -C "$ROOT" commit -q -am theirs
  echo ours >"$wt/file.txt"
  git -C "$wt" commit -q -am ours
  git -C "$wt" merge -q main >/dev/null 2>&1
  # Resolved to HEAD's content, so only MERGE_HEAD says anything is pending.
  git -C "$wt" checkout -q --ours file.txt && git -C "$wt" add file.txt
  assert "status is clean" test -z "$(git -C "$wt" status --short)"
  assert "reports the merge" bash -c "source '$FLOW/bin/lib.sh'; flow_pending_changes '$wt' | grep -qx 'a merge is in progress'"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout kept" test -d "$wt"
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

run_tests
