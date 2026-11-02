#!/usr/bin/env bash
# Tests for bin/unarchive against a temp repo and stub herdr/opencode.
set -uo pipefail
source "$(dirname "$0")/helpers.sh"

unarchive() {
  HERDR_ACTIVE_PANE_CWD="$ROOT" "$FLOW/bin/unarchive" "$@" </dev/null
}

refs() { git -C "$ROOT" for-each-ref refs/flow/archive/ | wc -l | tr -d ' '; }

# Commit to feat from a scratch checkout, as if work landed while archived.
advance_feat() {
  git -C "$ROOT" worktree add -q "$TMP/mover" feat
  if [ -n "${1:-}" ]; then
    echo "$1" >"$TMP/mover/file.txt"
    git -C "$TMP/mover" commit -q -am "moved"
  else
    git -C "$TMP/mover" commit -q --allow-empty -m "moved"
  fi
  git -C "$ROOT" worktree remove --force "$TMP/mover"
}

test_clean_restore() {
  local wt
  wt="$(make_worktree feat)"
  export STUB_SESSIONS_JSON="[{\"id\":\"ses_wt\",\"updated\":1,\"directory\":\"$wt\"}]"
  archive_wt "$wt"
  assert "exits 0" unarchive wt-feat
  assert "checkout back on its branch" test "$(git -C "$wt" branch --show-current)" = feat
  assert "archive ref deleted" test "$(refs)" = 0
  assert "opened in herdr under the repo" called "worktree open --cwd $ROOT --path $wt --label x --focus"
  assert "opencode resumes the session" called "agent start opencode-w9 --kind opencode --pane w9:p1 -- --session ses_wt"
}

test_dirty_restore() {
  local wt
  wt="$(make_worktree feat)"
  echo two >"$wt/file.txt"
  echo new >"$wt/new.txt"
  archive_wt "$wt"
  assert "exits 0" unarchive wt-feat
  assert "tracked edit back" test "$(cat "$wt/file.txt")" = two
  assert "untracked file back" test "$(cat "$wt/new.txt")" = new
  assert "archive ref deleted" test "$(refs)" = 0
}

test_branch_moved() {
  local wt
  wt="$(make_worktree feat)"
  echo new >"$wt/new.txt"
  archive_wt "$wt"
  advance_feat
  assert "exits 0" unarchive wt-feat
  assert "checkout at the branch's new tip" test "$(git -C "$wt" rev-parse HEAD)" = "$(git -C "$ROOT" rev-parse feat)"
  assert "changes applied on top" test -f "$wt/new.txt"
  assert "archive ref deleted" test "$(refs)" = 0
}

test_branch_deleted() {
  local wt sha
  wt="$(make_worktree feat)"
  sha="$(git -C "$ROOT" rev-parse feat)"
  archive_wt "$wt"
  git -C "$ROOT" branch -q -D feat
  assert "exits 0" unarchive wt-feat
  assert "branch recreated at the archived HEAD" test "$(git -C "$ROOT" rev-parse feat)" = "$sha"
  assert "checkout on it" test "$(git -C "$wt" branch --show-current)" = feat
}

test_detached_restore() {
  local wt sha
  wt="$(make_worktree feat)"
  git -C "$wt" checkout -q --detach
  sha="$(git -C "$wt" rev-parse HEAD)"
  archive_wt "$wt"
  assert "exits 0" unarchive wt-feat
  assert "still detached" bash -c "! git -C '$wt' symbolic-ref -q HEAD"
  assert "at the archived HEAD" test "$(git -C "$wt" rev-parse HEAD)" = "$sha"
}

test_conflict_keeps_ref() {
  local wt
  wt="$(make_worktree feat)"
  echo two >"$wt/file.txt"
  archive_wt "$wt"
  advance_feat three
  unarchive wt-feat
  assert "archive kept" test "$(refs)" = 1
  assert "told why" called "notification show flow: archive kept for wt-feat"
}

test_untracked_now_tracked_keeps_ref() {
  local wt
  wt="$(make_worktree feat)"
  echo two >"$wt/file.txt"
  echo mine >"$wt/notes.txt"
  archive_wt "$wt"
  git -C "$ROOT" worktree add -q "$TMP/mover" feat
  echo theirs >"$TMP/mover/notes.txt"
  git -C "$TMP/mover" add notes.txt
  git -C "$TMP/mover" commit -q -m "track notes"
  git -C "$ROOT" worktree remove --force "$TMP/mover"
  unarchive wt-feat
  assert "archive kept" test "$(refs)" = 1
  assert "says how to recover before deleting" called "notification show flow: archive kept for wt-feat --body .*stash apply refs/flow/archive/wt-feat-[0-9]*^2"
}

test_rewritten_keeps_ref() {
  local wt
  wt="$(make_worktree feat)"
  echo c >"$wt/c.txt"
  git -C "$wt" add c.txt
  git -C "$wt" commit -q -m "only in the checkout"
  archive_wt "$wt"
  git -C "$ROOT" branch -f feat main
  unarchive wt-feat
  assert "archive kept" test "$(refs)" = 1
  assert "told why" called "notification show flow: archive kept"
}

test_branch_checked_out_elsewhere() {
  local wt
  wt="$(make_worktree feat)"
  archive_wt "$wt"
  git -C "$ROOT" checkout -q feat
  assert "exits non-zero" bash -c "! HERDR_ACTIVE_PANE_CWD='$ROOT' '$FLOW/bin/unarchive' wt-feat </dev/null"
  assert "no checkout created" test ! -e "$wt"
  assert "archive kept" test "$(refs)" = 1
}

test_path_exists() {
  local wt
  wt="$(make_worktree feat)"
  archive_wt "$wt"
  mkdir "$wt"
  assert "exits non-zero" bash -c "! HERDR_ACTIVE_PANE_CWD='$ROOT' '$FLOW/bin/unarchive' wt-feat </dev/null"
  assert "archive kept" test "$(refs)" = 1
  assert "not opened in herdr" not_called "worktree open"
}

test_unknown_name() {
  assert "exits non-zero" bash -c "! HERDR_ACTIVE_PANE_CWD='$ROOT' '$FLOW/bin/unarchive' nope </dev/null"
  assert "no herdr calls" test ! -s "$HERDR_CALLS"
}

test_no_archives() {
  assert "exits non-zero" bash -c "! HERDR_ACTIVE_PANE_CWD='$ROOT' '$FLOW/bin/unarchive' </dev/null"
  assert "no herdr calls" test ! -s "$HERDR_CALLS"
}

test_session_lookup_at_restore() {
  local wt
  wt="$(make_worktree feat)"
  export STUB_SESSIONS_JSON='[]'
  archive_wt "$wt"
  export STUB_SESSIONS_JSON="[{\"id\":\"ses_late\",\"updated\":1,\"directory\":\"$wt\"}]"
  assert "exits 0" unarchive wt-feat
  assert "session found at restore time" called "-- --session ses_late"
}

test_two_archives_same_name() {
  local wt
  wt="$(make_worktree feat)"
  archive_wt "$wt"
  sleep 1
  git -C "$ROOT" worktree add -q -b other "$wt"
  archive_wt "$wt"
  assert "both listed" test "$(source "$FLOW/bin/lib.sh"; flow_archive_list "$ROOT" | wc -l | tr -d ' ')" = 2
  assert "exits 0" unarchive wt-feat
  assert "newest restored" test "$(git -C "$wt" branch --show-current)" = other
  assert "older archive kept" test "$(refs)" = 1
}

run_tests
