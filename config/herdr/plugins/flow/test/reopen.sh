#!/usr/bin/env bash
# Tests for bin/reopen against a temp repo and stub herdr/opencode.
set -uo pipefail
source "$(dirname "$0")/helpers.sh"

reopen() {
  HERDR_ACTIVE_PANE_CWD="$ROOT" "$FLOW/bin/reopen" "$@" </dev/null
}

# herdr's view of <path> as an existing worktree that isn't open.
kept_worktree_json() {
  jq -nc --arg p "$1" --arg b "${2:-}" '{result: {worktrees: [
    {path: $p, branch: $b, is_detached: ($b == ""), is_linked_worktree: true, is_prunable: false}]}}'
}

test_reopen_closed_branch() {
  local wt sha
  wt="$(make_worktree feat)"
  echo two >"$wt/file.txt"
  git -C "$wt" commit -q -am "work"
  sha="$(git -C "$wt" rev-parse HEAD)"
  close_wt "$wt"
  export STUB_SESSIONS_JSON="[{\"id\":\"ses_wt\",\"updated\":1,\"directory\":\"$wt\"}]"
  assert "exits 0" reopen feat
  assert "checkout back at the same path" test "$(git -C "$wt" branch --show-current)" = feat
  assert "at the branch tip" test "$(git -C "$wt" rev-parse HEAD)" = "$sha"
  assert "opened in herdr under the repo" called "worktree open --cwd $ROOT --path $wt --label feat --focus"
  assert "opencode resumes the session" called "agent start opencode-w9 --kind opencode --pane w9:p1 -- --session ses_wt"
}

test_slashed_branch() {
  local wt
  wt="$(make_worktree me/feat)"
  close_wt "$wt"
  assert "exits 0" reopen me/feat
  assert "path uses - for /" test "$(git -C "$FLOW_WORKTREES_DIR/repo/me-feat" branch --show-current)" = me/feat
  assert "labelled with the last segment" called "worktree open .* --label feat "
}

test_files_copied() {
  local wt
  echo SECRET=1 >"$ROOT/.env"
  echo .env >>"$ROOT/.gitignore"
  wt="$(make_worktree feat)"
  close_wt "$wt"
  assert "exits 0" reopen feat
  assert ".env copied" test "$(cat "$wt/.env")" = SECRET=1
}

test_reopen_kept_checkout() {
  local wt
  wt="$(make_worktree feat)"
  echo two >"$wt/file.txt"
  close_wt "$wt"
  export STUB_WORKTREE_LIST_JSON="$(kept_worktree_json "$wt" feat)"
  assert "exits 0" reopen feat
  assert "pending changes still there" test "$(cat "$wt/file.txt")" = two
  assert "opened in herdr" called "worktree open --cwd $ROOT --path $wt --label feat --focus"
}

test_open_worktree_not_offered() {
  local wt
  wt="$(make_worktree feat)"
  export STUB_WORKTREE_LIST_JSON="$(kept_worktree_json "$wt" feat | jq -c '.result.worktrees[0].open_workspace_id = "w1"')"
  assert "exits non-zero" fails reopen feat
  assert "not opened again" not_called "worktree open"
}

test_foreign_worktree_not_offered() {
  git -C "$ROOT" worktree add -q -b other "$TMP/elsewhere"
  export STUB_WORKTREE_LIST_JSON="$(kept_worktree_json "$TMP/elsewhere" other)"
  assert "exits non-zero" fails reopen other
}

test_default_branch_not_offered() {
  git -C "$ROOT" checkout -q -b side
  assert "exits non-zero" fails reopen main
}

test_deleted_behind_gits_back() {
  local wt
  wt="$(make_worktree feat)"
  rm -rf "$wt"
  assert "exits 0" reopen feat
  assert "checkout re-created" test "$(git -C "$wt" branch --show-current)" = feat
}

test_path_taken() {
  local wt
  wt="$(make_worktree feat)"
  close_wt "$wt"
  mkdir -p "$wt" && echo stray >"$wt/stray.txt"
  assert "exits non-zero" fails reopen feat
  assert "stray file untouched" test "$(cat "$wt/stray.txt")" = stray
  assert "not opened in herdr" not_called "worktree open"
}

test_unknown_branch() {
  make_worktree feat >/dev/null
  assert "exits non-zero" fails reopen nope
  assert "not opened in herdr" not_called "worktree open"
}

test_nothing_to_reopen() {
  assert "exits non-zero" fails reopen
  assert "not opened in herdr" not_called "worktree open"
}

run_tests
