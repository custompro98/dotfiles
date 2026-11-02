#!/usr/bin/env bash
# Tests for bin/on-workspace-closed against a temp repo and stub herdr/opencode.
set -uo pipefail
source "$(dirname "$0")/helpers.sh"

close() {
  HERDR_PLUGIN_EVENT_JSON="$1" "$FLOW/bin/on-workspace-closed"
}

# The (single) archive ref, and one of its Flow-* trailers.
ref() { git -C "$ROOT" for-each-ref --format='%(refname)' refs/flow/archive/; }
trailer() { git -C "$ROOT" log -1 --format="%(trailers:key=$1,valueonly,separator=)" "$(ref)"; }
has_parent2() { git -C "$ROOT" rev-parse -q --verify "$(ref)^2" >/dev/null; }

test_clean_checkout() {
  local wt sha
  wt="$(make_worktree feat)"
  sha="$(git -C "$ROOT" rev-parse feat)"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
  assert "branch kept" git -C "$ROOT" rev-parse --verify feat
  assert "archive script ran in the checkout" grep -qx wt-feat "$ROOT/archived.log"
  assert "one archive ref named for the checkout" bash -c "[[ \"\$(git -C '$ROOT' for-each-ref --format='%(refname)' refs/flow/archive/)\" =~ ^refs/flow/archive/wt-feat-[0-9]+$ ]]"
  assert "archived HEAD is parent 1" test "$(git -C "$ROOT" rev-parse "$(ref)^1")" = "$sha"
  assert "no uncommitted changes saved" bash -c "! git -C '$ROOT' rev-parse -q --verify '$(ref)^2'"
  assert "Flow-Name" test "$(trailer Flow-Name)" = wt-feat
  assert "Flow-Path" test "$(trailer Flow-Path)" = "$wt"
  assert "Flow-Label" test "$(trailer Flow-Label)" = x
  assert "Flow-Branch" test "$(trailer Flow-Branch)" = feat
  assert "nothing stashed" test -z "$(git -C "$ROOT" stash list)"
  assert "notified how to restore" called "notification show flow: archived wt-feat --body restore with prefix+shift+o"
}

test_dirty_checkout() {
  local wt
  wt="$(make_worktree feat)"
  echo two >"$wt/file.txt"
  echo new >"$wt/new.txt"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
  assert "uncommitted changes saved" has_parent2
  assert "tracked edit saved" test "$(git -C "$ROOT" show "$(ref)^2:file.txt")" = two
  assert "untracked file saved" bash -c "git -C '$ROOT' show --name-only '$(ref)^2^3' | grep -qx new.txt"
  assert "stash list left alone" test -z "$(git -C "$ROOT" stash list)"
}

test_untracked_only() {
  local wt
  wt="$(make_worktree feat)"
  echo new >"$wt/new.txt"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "untracked file saved" bash -c "git -C '$ROOT' show --name-only '$(ref)^2^3' | grep -qx new.txt"
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
  assert "no Flow-Branch when detached" test -z "$(trailer Flow-Branch)"
  assert "uncommitted changes saved" has_parent2
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
  assert "detached commit kept by the archive" test "$(git -C "$ROOT" rev-parse "$(ref)^1")" = "$sha"
  assert "no flow-archive branch" test -z "$(git -C "$ROOT" branch --list 'flow-archive/*')"
}

test_session_recorded() {
  local wt
  wt="$(make_worktree feat)"
  export STUB_SESSIONS_JSON="[{\"id\":\"ses_old\",\"updated\":1,\"directory\":\"$wt\"},{\"id\":\"ses_new\",\"updated\":2,\"directory\":\"$wt\"}]"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "newest session recorded" test "$(trailer Flow-Session)" = ses_new
}

test_session_exact_directory() {
  local wt
  wt="$(make_worktree feat)"
  export STUB_SESSIONS_JSON="[{\"id\":\"ses_root\",\"updated\":9,\"directory\":\"$ROOT\"},{\"id\":\"ses_wt\",\"updated\":1,\"directory\":\"$wt\"}]"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "only this checkout's session" test "$(trailer Flow-Session)" = ses_wt
}

test_opencode_fails() {
  local wt
  wt="$(make_worktree feat)"
  export STUB_OPENCODE_EXIT=1
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "checkout removed" test ! -e "$wt"
  assert "archived anyway" test -n "$(ref)"
  assert "no Flow-Session" test -z "$(trailer Flow-Session)"
}

test_concurrent_closes() {
  local a b ra rb
  a="$(make_worktree alpha)"
  b="$(make_worktree beta)"
  echo alpha-change >"$a/file.txt"
  echo a >"$a/a.txt"
  echo beta-change >"$b/file.txt"
  echo b >"$b/b.txt"
  archive_wt "$a" &
  archive_wt "$b" &
  wait
  ra="$(git -C "$ROOT" for-each-ref --format='%(refname)' 'refs/flow/archive/wt-alpha-*')"
  rb="$(git -C "$ROOT" for-each-ref --format='%(refname)' 'refs/flow/archive/wt-beta-*')"
  assert "alpha keeps its own edit" test "$(git -C "$ROOT" show "$ra^2:file.txt")" = alpha-change
  assert "beta keeps its own edit" test "$(git -C "$ROOT" show "$rb^2:file.txt")" = beta-change
  assert "beta keeps its own untracked file" bash -c "git -C '$ROOT' show --name-only '$rb^2^3' | grep -qx b.txt"
  assert "stash list left alone" test -z "$(git -C "$ROOT" stash list)"
}

test_existing_stash_untouched() {
  local wt
  wt="$(make_worktree feat)"
  echo mine >"$ROOT/file.txt"
  git -C "$ROOT" stash push -q -m "user stash"
  assert "exits 0" close "$(closed_event "$wt" true)"
  assert "clean checkout archives no changes" bash -c "! git -C '$ROOT' rev-parse -q --verify '$(ref)^2'"
  assert "user's stash still there" bash -c "git -C '$ROOT' stash list | grep -q 'user stash'"
}

test_ref_write_fails() {
  local wt
  wt="$(make_worktree feat)"
  echo two >"$wt/file.txt"
  touch "$ROOT/.git/refs/flow"
  assert "exits non-zero" bash -c "! HERDR_PLUGIN_EVENT_JSON='$(closed_event "$wt" true)' '$FLOW/bin/on-workspace-closed'"
  assert "checkout kept" test -d "$wt"
  assert "work left in the stash" bash -c "git -C '$ROOT' stash list | grep -q 'flow archive wt-feat'"
  assert "notified about the failure" called "notification show flow: couldn't archive wt-feat"
}

run_tests
