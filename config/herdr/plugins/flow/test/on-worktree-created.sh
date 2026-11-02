#!/usr/bin/env bash
# Tests for bin/on-worktree-created and flow_layout against a temp repo and a
# stub herdr.
set -uo pipefail
source "$(dirname "$0")/helpers.sh"

created() {
  HERDR_PLUGIN_EVENT_JSON="$(created_event w9 "$1")" "$FLOW/bin/on-worktree-created"
}

test_layout() {
  local wt
  wt="$(make_worktree feat)"
  assert "exits 0" created "$wt"
  assert "terminal split below the agent pane" called "pane split w9:p1 --direction down --ratio 0.7 --cwd $wt --no-focus"
  assert "terminal pane renamed" called "pane rename w9:p2 terminal"
  assert "setup runs in the terminal" called "pane run w9:p2 .*script' setup"
  assert "opencode started as a named agent" called "agent start opencode-w9 --kind opencode --pane w9:p1"
  assert "no session resumed" not_called "--session"
}

test_auto_run() {
  local wt
  wt="$(make_worktree feat)"
  printf '[scripts]\nauto_run_after_setup = true\n' >"$wt/.conductor/settings.local.toml"
  assert "exits 0" created "$wt"
  assert "default run action after setup" called "pane run w9:p2 .*setup && .*run' --default --workspace w9"
}

test_layout_with_session() {
  local wt
  wt="$(make_worktree feat)"
  assert "flow_layout exits 0" bash -c "source '$FLOW/bin/lib.sh' && flow_layout w9 '$wt' ses_abc"
  assert "opencode resumes the session" called "agent start opencode-w9 --kind opencode --pane w9:p1 -- --session ses_abc"
}

run_tests
