# flow: archive on workspace close Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Closing a linked-worktree workspace in herdr runs the Conductor archive script, stashes dirty work, and deletes the checkout (branch kept).

**Architecture:** A new `workspace.closed` event hook in the flow plugin does all archiving. `bin/archive` (prefix+shift+a) shrinks to a confirm step that calls `herdr workspace close`, so every close goes through the hook exactly once.

**Tech Stack:** bash, git, jq, herdr 0.9.5 CLI (`HERDR_BIN_PATH`), existing `bin/lib.sh` / `bin/script`.

**Spec:** `docs/superpowers/specs/2026-10-30-flow-archive-on-close-design.md`

## Global Constraints

- Plugin lives at `config/herdr/plugins/flow/`; scripts are bash with `set -euo pipefail` and `source "$(dirname "$0")/lib.sh"`, matching `bin/on-worktree-created`.
- Call herdr only through `$HERDR` (from `lib.sh`, honors `HERDR_BIN_PATH`) so tests can stub it.
- Branch is always kept; only the checkout is deleted.
- Repo workspaces (`is_linked_worktree` false) are never touched.
- Hook stdout/stderr already lands in `herdr plugin log list --plugin custompro98.flow`; no extra log file.
- herdr caches the manifest in `~/.config/herdr/plugins.json`; after editing `herdr-plugin.toml`, run `herdr plugin link ~/.dotfiles/config/herdr/plugins/flow`.

## Review Focus

- Event with no `.workspace` object (schema marks it optional) → hook exits 0 and does nothing. Test: `test_no_workspace_in_event` (Task 1).
- Checkout already gone (closed after a manual `git worktree remove`) → exit 0, archive script not run. Test: `test_missing_checkout` (Task 1).
- Detached HEAD in the checkout → stash message uses `detached` instead of an empty branch name. Test: `test_detached_dirty` (Task 1).
- Dirty checkout with only untracked files → still stashed (needs `-u`), not lost. Covered by `test_dirty_checkout` using an untracked file plus a tracked edit (Task 1).
- Answering anything but `y` in the popup → workspace stays open. Test: `test_archive_declined` (Task 2).

---

### Task 1: `workspace.closed` hook

**Files:**
- Create: `config/herdr/plugins/flow/bin/on-workspace-closed`
- Create: `config/herdr/plugins/flow/test/helpers.sh`
- Create: `config/herdr/plugins/flow/test/on-workspace-closed.sh`
- Modify: `config/herdr/plugins/flow/herdr-plugin.toml` (add event, refresh description)

**Interfaces:**
- Produces: `bin/on-workspace-closed` — reads `HERDR_PLUGIN_EVENT_JSON`, uses `.workspace.worktree.{checkout_path,is_linked_worktree}` (search with `[.. | objects | .worktree? ...]` like `on-worktree-created` if the payload nests under `.data`). Exit 0 on skip and success; non-zero only if `git worktree remove` fails.
- Produces (test helpers, `test/helpers.sh`): `make_repo` → sets `ROOT` (temp git repo with one commit and `.conductor/settings.toml` whose `scripts.archive` appends `$CONDUCTOR_WORKSPACE_NAME` to `$CONDUCTOR_ROOT_PATH/archived.log`), `make_worktree <branch>` → echoes new worktree path, `stub_herdr` → exports `HERDR_BIN_PATH` to a stub that appends its argv (one line per call) to `$HERDR_CALLS` and prints `{"result":{}}`, and canned JSON for `workspace get` (from `$STUB_WORKSPACE_JSON`). `closed_event <path> <linked:true|false>` → echoes event JSON `{"event":"workspace.closed","data":{"type":"workspace_closed","workspace_id":"w1","workspace":{"workspace_id":"w1","label":"x","worktree":{"repo_key":"k","repo_name":"repo","repo_root":ROOT,"checkout_path":<path>,"is_linked_worktree":<linked>}}}}`. `assert <desc> <cmd...>` prints `ok`/`FAIL` and tracks failures; the test file exits non-zero if any failed. Each test runs in a fresh `mktemp -d`.

- [ ] **Step 1: Write the failing tests** in `test/on-workspace-closed.sh`, one function per case, each running `HERDR_PLUGIN_EVENT_JSON="$(closed_event …)" bin/on-workspace-closed`:
  - `test_clean_checkout`: exit 0; checkout dir gone; `git -C "$ROOT" rev-parse --verify feat` succeeds; `archived.log` contains the worktree's basename; `git -C "$ROOT" stash list` empty; `$HERDR_CALLS` has no `notification` line.
  - `test_dirty_checkout`: edit a tracked file and add untracked `new.txt`; exit 0; checkout gone; `git stash list` has one entry containing `flow archive feat`; `git -C "$ROOT" show --name-only 'stash@{0}^3'` lists `new.txt`; `$HERDR_CALLS` has a `notification show` line containing `stashed`.
  - `test_archive_script_fails`: settings archive = `exit 1`; exit 0; checkout gone; `$HERDR_CALLS` has a `notification show` line containing `archive script failed`.
  - `test_repo_workspace_ignored`: event for `$ROOT` with linked `false`; `$ROOT` still exists, `archived.log` absent, no herdr calls.
  - `test_missing_checkout`: event for a nonexistent path, linked `true`; exit 0, no `archived.log`.
  - `test_no_workspace_in_event`: `{"event":"workspace.closed","data":{"type":"workspace_closed","workspace_id":"w1"}}`; exit 0.
  - `test_detached_dirty`: `git -C "$wt" checkout --detach` then dirty it; stash message contains `flow archive detached`; checkout gone.

- [ ] **Step 2: Run to verify failure**
  Run: `bash config/herdr/plugins/flow/test/on-workspace-closed.sh`
  Expected: FAIL lines (hook does not exist), non-zero exit.

- [ ] **Step 3: Implement `bin/on-workspace-closed`**
  Order: parse event → skip unless linked and dir exists → `branch="$(git -C "$path" branch --show-current)"`, default `detached` → `root="$(flow_root_path "$path")"` (before removal) → `"$FLOW_BIN/script" archive "$path"` in a subshell; on failure, notify → if `git -C "$path" status --porcelain` is non-empty, `git -C "$path" stash push -u -m "flow archive $branch"` and notify → `git -C "$root" worktree remove --force "$path"`; on failure, notify and exit 1.
  Notifications are `"$HERDR" notification show <title> --body <body>` with exact copy:
  - archive failure: title `flow: archive script failed for $branch`, body `herdr plugin log list --plugin custompro98.flow`
  - stash: title `flow: stashed changes from $branch`, body `git stash list in $(basename "$root"): flow archive $branch`
  - remove failure: title `flow: couldn't remove $path`, body = git's stderr
  Header comment in the style of `on-worktree-created` (what it does, branch kept, dirty work stashed).

- [ ] **Step 4: Register the hook**
  In `herdr-plugin.toml` add, after the `worktree.created` block, a comment line and:
  ```toml
  [[events]]
  on = "workspace.closed"
  command = ["bin/on-workspace-closed"]
  ```
  `chmod +x bin/on-workspace-closed`.

- [ ] **Step 5: Run tests to verify pass**
  Run: `bash config/herdr/plugins/flow/test/on-workspace-closed.sh`
  Expected: all `ok`, exit 0.

- [ ] **Step 6: Commit**
  ```bash
  git add config/herdr/plugins/flow
  git commit -m "herdr flow: archive worktree on workspace close"
  ```

### Task 2: `bin/archive` becomes confirm + close

**Files:**
- Modify: `config/herdr/plugins/flow/bin/archive`
- Modify: `config/herdr/config.toml:72-78` (prefix+shift+a description → `"archive workspace (close; removes worktree)"`)
- Create: `config/herdr/plugins/flow/test/archive.sh`

**Interfaces:**
- Consumes: `test/helpers.sh` (`make_repo`, `make_worktree`, `stub_herdr` with `STUB_WORKSPACE_JSON`); the Task 1 hook does the real work, so `bin/archive` only needs to call `"$HERDR" workspace close "$ws"`.

- [ ] **Step 1: Write failing tests** in `test/archive.sh` (`HERDR_ACTIVE_WORKSPACE_ID=w1`, `STUB_WORKSPACE_JSON` = `{"result":{"workspace":{"label":"feat","worktree":{"is_linked_worktree":true,"checkout_path":<wt>}}}}`):
  - `test_archive_confirmed`: `echo y | bin/archive`; `$HERDR_CALLS` contains `workspace close w1`; checkout still exists (the script no longer removes it itself); `archived.log` absent (no script run in the popup).
  - `test_archive_declined`: `echo n | bin/archive`; no `workspace close` line.

- [ ] **Step 2: Run to verify failure**
  Run: `bash config/herdr/plugins/flow/test/archive.sh`
  Expected: `test_archive_confirmed` FAILs (current script calls `worktree remove`, runs archive script).

- [ ] **Step 3: Rewrite `bin/archive`**
  Keep the linked-worktree check, label/path header and `git status --short`. Prompt copy: `close and archive? this is final; branch $branch is kept, uncommitted changes are stashed [y/N] `. On `y`: `"$HERDR" workspace close "$ws" >/dev/null || die_popup "workspace close failed"`. Remove the archive-script call and force-remove prompt. Update the header comment to say the `workspace.closed` hook does the archiving.

- [ ] **Step 4: Update the keybinding description** in `config/herdr/config.toml` as listed above.

- [ ] **Step 5: Run both test files**
  Run: `bash config/herdr/plugins/flow/test/archive.sh && bash config/herdr/plugins/flow/test/on-workspace-closed.sh`
  Expected: all `ok`, exit 0.

- [ ] **Step 6: Commit**
  ```bash
  git add config/herdr/plugins/flow config/herdr/config.toml
  git commit -m "herdr flow: prefix+shift+a closes the workspace, hook archives"
  ```

### Task 3: Live check in herdr

- [ ] **Step 1: Relink and reload**
  Run: `herdr plugin link ~/.dotfiles/config/herdr/plugins/flow && herdr server reload-config`
  Expected: `jq '.[] | select(.plugin_id=="custompro98.flow") | .events[].on' ~/.config/herdr/plugins.json` prints `worktree.created` and `workspace.closed`.

- [ ] **Step 2: Close a throwaway worktree**
  Run: `ws=$(herdr worktree create --cwd ~/.dotfiles --branch flow-close-check --no-focus | jq -r .result.workspace.workspace_id)`, wait for `on-worktree-created` to finish (`herdr plugin log list --plugin custompro98.flow` shows it succeeded), then `herdr workspace close "$ws"`.
  Expected: plugin log shows `bin/on-workspace-closed` `succeeded`; `git -C ~/.dotfiles worktree list` no longer lists `flow-close-check`; `git -C ~/.dotfiles branch --list flow-close-check` still prints it. Note the hook duration from the log (confirms herdr ran it to completion with no timeout).

- [ ] **Step 3: Clean up**
  Run: `git -C ~/.dotfiles branch -D flow-close-check`
