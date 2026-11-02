# flow: unarchive Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Closing a flow worktree workspace saves it under a git ref; `prefix+shift+o` restores it (branch, path, uncommitted work, opencode conversation).

**Architecture:** `on-workspace-closed` writes one wrapper commit per archive to `refs/flow/archive/<name>-<unix>`: tree = archived HEAD's tree, parent 1 = archived HEAD, parent 2 = a `git stash push -u` commit when dirty, metadata as `Flow-*` trailers. New `bin/unarchive` lists those refs, recreates the worktree, `git stash apply`s parent 2, opens it in herdr and lays it out with a layout function shared with `on-worktree-created`, starting opencode with `--session <id>`.

**Tech Stack:** bash, git 2.54 (`for-each-ref` trailers), jq, fzf, herdr 0.9.5 CLI via `$HERDR`, opencode 2.2.5 CLI.

**Spec:** `docs/superpowers/specs/2026-10-31-flow-unarchive-design.md`

## Global Constraints

- Plugin root `config/herdr/plugins/flow/` (paths below are relative to `~/.dotfiles`). Scripts: bash, `set -euo pipefail`, `source "$(dirname "$0")/lib.sh"`.
- Call herdr only via `$HERDR`, opencode only via `$OPENCODE` (add `OPENCODE="${FLOW_OPENCODE_BIN:-opencode}"` to `lib.sh` next to `HERDR`), so tests can stub both.
- Archive ref: `refs/flow/archive/<name>-<unix-time>`, `<name>` = checkout basename. Created with `git update-ref <ref> <commit> ""` (create-only); never overwritten.
- Trailers on the wrapper commit, exact keys: `Flow-Name`, `Flow-Path`, `Flow-Label`, `Flow-Branch` (omitted when detached), `Flow-Session` (omitted when unknown). Subject: `flow archive <name>`. Archived-at = the commit's creator date.
- Never use `opencode --continue`. Sessions: newest (`updated`) entry of `opencode session list --format json -n 1000` whose `directory` equals the checkout path exactly; opencode failing → no session, never an error.
- A failed archive keeps the checkout; a failed or partial restore keeps the ref.
- Keybinding `prefix+shift+o`, description `restore archived workspace`.
- Run all tests with `for t in config/herdr/plugins/flow/test/*.sh; do bash "$t" </dev/null || exit 1; done` (helpers.sh is sourced, not a test; skip it).
- After editing `herdr-plugin.toml`: `herdr plugin link ~/.dotfiles/config/herdr/plugins/flow`. After editing `config.toml`: `herdr config check`, then `herdr server reload-config`.

## Review Focus

- Branch is checked out in the main checkout when you restore → refuse with a popup error, no directory created, archive kept. Test: `test_branch_checked_out_elsewhere` (Task 4).
- Only untracked files changed → still archived (`-u`) and restored. Tests: `test_untracked_only` (Task 3), covered on restore by `test_dirty_restore` (Task 4).
- opencode not running or erroring at archive time → archive still succeeds, no `Flow-Session`; restore looks the session up again. Tests: `test_opencode_fails` (Task 3), `test_session_lookup_at_restore` (Task 4).
- Something already at the recorded path → refuse, archive kept. Test: `test_path_exists` (Task 4).
- A newer session in the main checkout or another worktree must not be picked. Test: `test_session_exact_directory` (Task 3).

---

### Task 1: Probe whether `herdr worktree open` fires `worktree.created`

No product code. The answer decides who owns the restore layout (spec, "Constraints and facts"). Do this while the flow plugin is still disabled.

**Files:**
- Modify: `docs/superpowers/specs/2026-10-31-flow-unarchive-design.md` (record the result)

- [ ] **Step 1: Link a throwaway probe plugin** at `/tmp/flow-probe/herdr-plugin.toml` with `id = "probe.events"`, `min_herdr_version = "0.9.0"`, and two `[[events]]` (`worktree.created`, `worktree.opened`) each running `["sh", "-c", "echo $HERDR_PLUGIN_EVENT_JSON >> /tmp/flow-probe/events.log"]`. Run `herdr plugin link /tmp/flow-probe`.
- [ ] **Step 2: Open an existing worktree through herdr**
  Run: `git -C ~/.dotfiles worktree add -q -b flow-probe /tmp/flow-probe-wt && herdr worktree open --cwd ~/.dotfiles --path /tmp/flow-probe-wt --label flow-probe --no-focus`
  Then: `cat /tmp/flow-probe/events.log` (wait a few seconds; hooks are async).
- [ ] **Step 3: Clean up** — `herdr workspace close <id from step 2's JSON>`, `git -C ~/.dotfiles worktree remove --force /tmp/flow-probe-wt`, `git -C ~/.dotfiles branch -D flow-probe`, `herdr plugin unlink probe.events`, `rm -rf /tmp/flow-probe`. Expected: `herdr plugin list` no longer shows `probe.events`; `git worktree list` has no `/tmp/flow-probe-wt`.
- [ ] **Step 4: Record the result** in the spec's "Constraints and facts" bullet: replace "Verify this early … *(Builder's call, settled in review.)*" with the observed fact. If the log shows only `worktree.opened`, Tasks 2–4 stand as written. If it shows `worktree.created`, stop and apply the spec's fallback before Task 4: `on-worktree-created` passes the session of the newest `refs/flow/archive/*` whose `Flow-Path` equals the event's path to `flow_layout`, and `bin/unarchive` skips its own `flow_copy_files`/`flow_layout` calls.
- [ ] **Step 5: Commit** — `git commit -m "flow: record worktree.open event behavior" -- docs/superpowers/specs/2026-10-31-flow-unarchive-design.md`

---

### Task 2: Shared workspace layout

**Files:**
- Modify: `config/herdr/plugins/flow/bin/lib.sh` (add `OPENCODE`, `flow_layout`)
- Modify: `config/herdr/plugins/flow/bin/on-worktree-created` (use `flow_layout`)
- Modify: `config/herdr/plugins/flow/test/helpers.sh` (stub responses, `created_event`, `stub_opencode`, `called`/`not_called`)
- Modify: `config/herdr/plugins/flow/test/on-workspace-closed.sh` (drop its local `called`/`not_called`)
- Create: `config/herdr/plugins/flow/test/on-worktree-created.sh`

**Interfaces:**
- Produces: `flow_layout <ws> <path> [session-id]` in `lib.sh` — everything `on-worktree-created` does after `flow_copy_files`: first pane of `<ws>` → split down 0.7 with `--cwd <path> --no-focus`, rename new pane `terminal`, `pane run` setup (plus `&& run --default --workspace <ws>` when `auto_run_after_setup`), then `"$HERDR" agent start "$(flow_agent_name "$ws")" --kind opencode --pane <first pane>`, appending `-- --session <id>` only when a session id is given.
- Produces (helpers): stub herdr answers `pane list` with `{"result":{"panes":[{"pane_id":"w9:p1"}]}}`, `pane split` with `{"result":{"pane":{"pane_id":"w9:p2"}}}`, `worktree open` with `{"result":{"workspace":{"workspace_id":"w9"}}}`, `workspace get` with `$STUB_WORKSPACE_JSON`, anything else `{"result":{}}`. `stub_opencode` exports `FLOW_OPENCODE_BIN` to a stub that appends `"$PWD $*"` to `$OPENCODE_CALLS`, prints `${STUB_SESSIONS_JSON:-[]}`, and exits `${STUB_OPENCODE_EXIT:-0}`; `run_tests` calls it for every test. `created_event <ws> <path>` → `{"event":"worktree.created","data":{"workspace":{"workspace_id":<ws>},"worktree":{"path":<path>}}}`. `called <regex>` / `not_called <regex>` grep `$HERDR_CALLS` (moved from `on-workspace-closed.sh`).

- [ ] **Step 1: Write the failing tests** in `test/on-worktree-created.sh` (each runs `HERDR_PLUGIN_EVENT_JSON="$(created_event w9 "$wt")" "$FLOW/bin/on-worktree-created"`):
  - `test_layout`: exit 0; `called "pane split w9:p1 --direction down --ratio 0.7 --cwd $wt --no-focus"`; `called "pane rename w9:p2 terminal"`; `called "pane run w9:p2 .*script' setup"`; `called "agent start opencode-w9 --kind opencode --pane w9:p1"`; `not_called "--session"`.
  - `test_auto_run`: settings `[scripts]\nauto_run_after_setup = true` in the worktree's `.conductor/settings.local.toml`; `called "pane run w9:p2 .*setup && .*run' --default --workspace w9"`.
  - `test_layout_with_session`: in a subshell, `source "$FLOW/bin/lib.sh"; flow_layout w9 "$wt" ses_abc`; `called "agent start opencode-w9 --kind opencode --pane w9:p1 -- --session ses_abc"`.
- [ ] **Step 2: Run to verify failure** — `bash config/herdr/plugins/flow/test/on-worktree-created.sh </dev/null`. Expected: `test_layout_with_session` FAILs (`flow_layout` undefined); others may pass. Non-zero exit.
- [ ] **Step 3: Implement** `flow_layout` and make `on-worktree-created` parse the event, `flow_copy_files`, then `flow_layout "$ws" "$path"`. Add the helpers listed above.
- [ ] **Step 4: Run all tests** (command in Global Constraints). Expected: all `ok`, exit 0.
- [ ] **Step 5: Commit** — `git add config/herdr/plugins/flow && git commit -m "herdr flow: share the workspace layout"`

---

### Task 3: Archive to a ref

**Files:**
- Modify: `config/herdr/plugins/flow/bin/lib.sh` (session and archive helpers)
- Modify: `config/herdr/plugins/flow/bin/on-workspace-closed`
- Modify: `config/herdr/plugins/flow/test/on-workspace-closed.sh`
- Modify: `config/herdr/plugins/flow/test/helpers.sh` (`archive_wt`)

**Interfaces:**
- Consumes: `OPENCODE`, `stub_opencode`, `called`/`not_called` (Task 2).
- Produces, all in `lib.sh`:
  - `flow_sessions_json <dir>` → JSON array from `(cd <dir> && "$OPENCODE" session list --format json -n 1000)`; `[]` on any failure.
  - `flow_session_for <dir> <path>` → id of the newest session whose `directory == <path>`, or empty.
  - `flow_archive_save <path> <label>` → echoes the new ref; returns non-zero (message on stderr) if any step fails, with the checkout left in place. Steps: `head`, `branch`; if `git status --porcelain` is non-empty, `git -C <path> stash push -q -u -m "flow archive <name>"` and take `refs/stash` as parent 2; `git commit-tree "<head>^{tree}" -p <head> [-p <stash>]` with the subject and trailers from Global Constraints; `git update-ref <ref> <commit> ""`; then `git stash drop -q` only if `stash@{0}` still equals the captured stash. If anything fails after the stash push, leave the stash entry (that's where the work is) and say so on stderr.
- Produces (helpers): `archive_wt <path>` → runs the hook on `closed_event <path> true`.

- [ ] **Step 1: Rewrite the tests** in `test/on-workspace-closed.sh`. Keep `test_archive_script_fails`, `test_repo_workspace_ignored`, `test_missing_checkout`, `test_no_workspace_in_event` as is. Replace/add (`ref()` = `git -C "$ROOT" for-each-ref --format='%(refname)' refs/flow/archive/`; `trailer K` = `git -C "$ROOT" log -1 --format="%(trailers:key=K,valueonly,separator=)" "$(ref)"`):
  - `test_clean_checkout`: exit 0; checkout gone; branch `feat` kept; `archived.log` has `wt-feat`; one ref matching `^refs/flow/archive/wt-feat-[0-9]+$`; `"$(ref)^1"` = feat's sha; no `"$(ref)^2"`; trailers `Flow-Name`=`wt-feat`, `Flow-Path`=`$wt`, `Flow-Label`=`x`, `Flow-Branch`=`feat`; `git stash list` empty; `called "notification show flow: archived wt-feat --body restore with prefix+shift+o"`.
  - `test_dirty_checkout`: tracked edit + untracked `new.txt`; ref has `^2`; `git show "$(ref)^2:file.txt"` = `two`; `git show --name-only "$(ref)^2^3"` lists `new.txt`; `git stash list` empty.
  - `test_untracked_only`: only `new.txt`; `"$(ref)^2^3"` lists `new.txt`.
  - `test_detached_dirty`: detached + dirty; no `Flow-Branch` trailer; ref has `^2`.
  - `test_detached_commits_saved`: commit on detached HEAD; `"$(ref)^1"` = that sha; no `flow-archive/*` branch exists.
  - `test_session_recorded`: `STUB_SESSIONS_JSON` with `{"id":"ses_old","updated":1,"directory":"$wt"}`, `{"id":"ses_new","updated":2,"directory":"$wt"}`; `Flow-Session` = `ses_new`.
  - `test_session_exact_directory`: sessions `{"id":"ses_root","updated":9,"directory":"$ROOT"}`, `{"id":"ses_wt","updated":1,"directory":"$wt"}`; `Flow-Session` = `ses_wt`.
  - `test_opencode_fails`: `STUB_OPENCODE_EXIT=1`; exit 0; checkout gone; ref exists; no `Flow-Session` trailer.
  - `test_ref_write_fails`: `touch "$ROOT/.git/refs/flow"` (blocks the ref); dirty checkout; hook exits non-zero; checkout still exists; `git stash list` has `flow archive wt-feat`; `called "notification show flow: couldn't archive wt-feat"`.
- [ ] **Step 2: Run to verify failure** — `bash config/herdr/plugins/flow/test/on-workspace-closed.sh </dev/null`. Expected: FAILs on ref assertions; non-zero exit.
- [ ] **Step 3: Implement** the helpers, then rewrite `on-workspace-closed`: parse → skip (unchanged) → `name`, `root`, label from the event's `.workspace.label` (fallback `name`) → archive script (unchanged, notify on failure) → `flow_archive_save`; on failure notify `flow: couldn't archive $name` with the error as body and exit 1 → `git worktree remove --force` (unchanged failure handling) → notify `flow: archived $name` / `restore with prefix+shift+o`. Delete the stash block, the detached-HEAD branch pinning, and their notifications. Update the header comment.
- [ ] **Step 4: Run all tests.** Expected: all `ok`, exit 0.
- [ ] **Step 5: Commit** — `git add config/herdr/plugins/flow && git commit -m "herdr flow: archive closed workspaces to refs/flow/archive"`

---

### Task 4: `bin/unarchive` and `prefix+shift+o`

**Files:**
- Modify: `config/herdr/plugins/flow/bin/lib.sh` (`flow_archive_list`, `flow_archive_checkout`)
- Create: `config/herdr/plugins/flow/bin/unarchive`
- Create: `config/herdr/plugins/flow/test/unarchive.sh`
- Modify: `config/herdr/config.toml` (keybinding after the `prefix+m` block)

**Interfaces:**
- Consumes: `flow_layout` (Task 2); `flow_session_for`, `flow_sessions_json`, `archive_wt`, ref format and trailers (Task 3).
- Produces, in `lib.sh`:
  - `flow_archive_list <root>` → one TSV line per archive, newest first (`for-each-ref --sort=-creatordate`): `ref name branch path label session unix`. Empty fields stay as empty columns.
  - `flow_archive_checkout <root> <ref>` → recreates the worktree and re-applies changes. Returns 1 with a message on stderr, creating nothing, when the path exists or the branch is checked out in another worktree (`git worktree list --porcelain`). Otherwise returns 0 and prints a keep-reason on stdout, or nothing if the ref can be deleted. Checkout: branch exists → `git worktree add <path> <branch>`; branch gone → `git worktree add -b <branch> <path> <ref>^1`; detached → `git worktree add --detach <path> <ref>^1`. If `<ref>^2` exists: `git -C <path> stash apply --index <ref>^2`, retrying without `--index` only if that failed and left no unmerged paths (`git diff --name-only --diff-filter=U` empty); unmerged paths after either attempt = conflict. Keep-reasons, exact copy: conflict → `changes didn't apply cleanly; resolve them in <path>, then run: git update-ref -d <ref>`; branch tip doesn't contain `<ref>^1` (`merge-base --is-ancestor`) → `<branch> no longer contains the archived commits; they're kept in <ref>`.
- Produces: `bin/unarchive [name]` — repo from `HERDR_ACTIVE_PANE_CWD` via `flow_root_path`, else `flow_pick_repo 'restore in> '`. No archives → `die_popup "no archived workspaces in <repo>"`. With `name`: newest archive with that `Flow-Name`, else `die_popup "no archive named <name>"`. Without: fzf over `ref<TAB>name<TAB>session title<TAB>branch<TAB>date` (`--with-nth 2..`; title from one `flow_sessions_json <root>` call; date via jq `strftime("%b %d %H:%M")` on `localtime`). Then: `flow_archive_checkout` (refusal → `die_popup`) → `flow_copy_files <path>` → `herdr worktree open --cwd <root> --path <path> --label <label> --focus`, ws from `.result.workspace.workspace_id` → `flow_layout <ws> <path> <session>` (session = recorded, else `flow_session_for <root> <path>`) → no keep-reason: `git update-ref -d <ref>`; keep-reason: `notification show "flow: archive kept for <name>" --body "<reason>"`.

- [ ] **Step 1: Write the failing tests** in `test/unarchive.sh`. Each archives with `archive_wt`, then runs `HERDR_ACTIVE_PANE_CWD="$ROOT" "$FLOW/bin/unarchive" wt-feat </dev/null`. `refs()` counts `refs/flow/archive/*`.
  - `test_clean_restore`: sessions stub `{"id":"ses_wt","updated":1,"directory":"$wt"}` during archive; after restore `$wt` exists on branch `feat`; `refs` = 0; `called "worktree open --cwd $ROOT --path $wt --label x --focus"`; `called "agent start opencode-w9 --kind opencode --pane w9:p1 -- --session ses_wt"`.
  - `test_dirty_restore`: tracked edit `two` + untracked `new.txt` before archiving; after restore both are back with that content; `refs` = 0.
  - `test_branch_moved`: dirty with `new.txt`; after archiving, advance `feat` from `$ROOT` (`git commit-tree` on feat's tree + `git branch -f feat <new>`); restore → `$wt` HEAD = the new commit, `new.txt` present, `refs` = 0.
  - `test_branch_deleted`: after archiving, `git branch -D feat`; restore → `feat` exists at the archived HEAD, `$wt` on it.
  - `test_detached_restore`: detached archive; restore → `git -C "$wt" symbolic-ref -q HEAD` fails; HEAD = archived sha.
  - `test_conflict_keeps_ref`: archive with `file.txt` = `two`; move `feat` to a commit setting `file.txt` = `three`; restore → `refs` = 1; `called "notification show flow: archive kept for wt-feat"`.
  - `test_rewritten_keeps_ref`: commit on `feat` in the worktree, archive, `git branch -f feat main`; restore → `refs` = 1; `called "notification show flow: archive kept"`.
  - `test_branch_checked_out_elsewhere`: archive, `git -C "$ROOT" checkout -q feat`; unarchive exits non-zero; `$wt` absent; `refs` = 1.
  - `test_path_exists`: archive, `mkdir "$wt"`; exits non-zero; `refs` = 1; no `worktree open` call.
  - `test_unknown_name`: `unarchive nope` exits non-zero; no herdr calls.
  - `test_no_archives`: no archive; `unarchive` (no arg) exits non-zero; no herdr calls.
  - `test_session_lookup_at_restore`: archive with `STUB_SESSIONS_JSON='[]'`; set it to a `ses_late` session for `$wt` before restoring; `called "-- --session ses_late"`.
  - `test_two_archives_same_name`: archive `wt-feat` (branch `feat`), `sleep 1`, `git -C "$ROOT" worktree add -q -b other "$TMP/wt-feat"`, archive again; `(source "$FLOW/bin/lib.sh"; flow_archive_list "$ROOT") | wc -l` = 2; `unarchive wt-feat` restores the newer one (`$wt` on branch `other`); `refs` = 1.
- [ ] **Step 2: Run to verify failure** — `bash config/herdr/plugins/flow/test/unarchive.sh </dev/null`. Expected: FAILs (`bin/unarchive` missing), non-zero exit.
- [ ] **Step 3: Implement** `flow_archive_list`, `flow_archive_checkout`, `bin/unarchive` (`chmod +x`).
- [ ] **Step 4: Run all tests.** Expected: all `ok`, exit 0.
- [ ] **Step 5: Add the keybinding** to `config/herdr/config.toml` after the `prefix+m` block: `[[keys.command]]`, `key = "prefix+shift+o"`, `type = "popup"`, `command = "~/.dotfiles/config/herdr/plugins/flow/bin/unarchive"`, `width = "70%"`, `height = "40%"`, `description = "restore archived workspace"`. Run `herdr config check`. Expected: `config: ok`.
- [ ] **Step 6: Commit** — `git add config/herdr && git commit -m "herdr flow: restore archived workspaces with prefix+shift+o"`

---

### Task 5: Enable and verify end to end

**Files:**
- Modify: `config/herdr/plugins/flow/herdr-plugin.toml` (description mentions restore; `workspace.closed` comment says close archives and `prefix+shift+o` restores)

- [ ] **Step 1: Update the manifest text**, then `herdr plugin link ~/.dotfiles/config/herdr/plugins/flow`, `herdr plugin enable custompro98.flow`, `herdr server reload-config`. Expected: `herdr plugin list` shows `custompro98.flow` enabled.
- [ ] **Step 2: Archive a throwaway workspace.** `prefix+a` in `~/.dotfiles` with branch `flow-e2e`; in opencode, send one message; in the terminal pane, `echo e2e > e2e.txt`; close with `prefix+shift+d`. Expected: notification `flow: archived flow-e2e`; `git -C ~/.dotfiles for-each-ref refs/flow/archive/` shows one `flow-e2e-*` ref; `~/.herdr/worktrees/.dotfiles/flow-e2e` is gone.
- [ ] **Step 3: Restore it.** `prefix+shift+o` from the dotfiles workspace; pick `flow-e2e`. Expected: workspace reopens focused; `e2e.txt` is back; opencode shows the earlier message; the ref is gone.
- [ ] **Step 4: Clean up** — `rm e2e.txt` in the restored workspace, close it, then `git -C ~/.dotfiles update-ref -d <new flow-e2e ref>` and `git -C ~/.dotfiles branch -D flow-e2e`.
- [ ] **Step 5: Commit** — `git add config/herdr/plugins/flow/herdr-plugin.toml && git commit -m "herdr flow: describe restore in the manifest"`
