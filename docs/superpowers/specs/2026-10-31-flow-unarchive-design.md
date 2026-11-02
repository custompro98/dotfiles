# flow: unarchive a workspace

## Intent

Mimic Conductor's History pane: an archived flow workspace can be brought back,
jcode and opencode conversation included. Today closing a worktree workspace
archives it (`2026-10-30-flow-archive-on-close-design.md`) but there's no way
back: uncommitted work goes to the repo's shared `git stash` list, nothing
records which workspace it came from, and nothing reopens the conversation.

The opencode conversation matters as much as the code. Disk space matters too,
so archived checkouts stay deleted.

## Goals

- Every archived worktree workspace can be restored from a popup: same branch,
  same path, uncommitted work (tracked and untracked) back in place, and its
  opencode session resumed.
- Restore works when the branch has moved or been deleted since archiving.
- Archiving keeps deleting the checkout (no disk cost per archive beyond git
  objects).

## Non-goals

- Restoring gitignored files beyond what new workspaces already get (the
  `.worktreeinclude` / `file_include_globs` / `.env*` copy). Build caches,
  `node_modules` etc. come back by re-running the setup script.
- Listing archives across repos. The list shows the current repo only.
- Migrating archives made before this change (entries in `git stash list`
  named `flow archive <branch>`). They stay where they are.
- Pushing archives to a remote. `refs/flow/*` stays local.

## Anti-goals

- Losing work. A failed restore must leave the archive intact; a failed
  archive must leave the checkout in place (as today).
- Resuming the wrong conversation. `opencode --continue` picks the repo's last
  session, which may belong to another workspace; never rely on it.

## Constraints and facts

- opencode 2.2.5 keeps sessions in `~/.local/share/opencode/opencode.db`, keyed
  by project (the repo; all its worktrees share one `projectId`), each with a
  `directory`. Sessions survive the checkout being deleted (e.g. the deleted
  `bergen` worktree's session is still listed). `opencode session list --format
  json`, run anywhere in the repo, lists them with `id`, `title`, `updated`,
  `directory`. `opencode -s <id>` resumes a specific session.
- City-named paths aren't reused while their branch exists, and archiving keeps
  the branch, so a restored workspace can reuse its original path.
- `herdr worktree open` on an existing worktree emits only `worktree.opened`,
  not `worktree.created` (verified 2026-11-02 on herdr 0.9.5 with a probe
  plugin listening to both; flow's `on-worktree-created` didn't run). So
  `bin/unarchive` owns the restore layout.
- Refs under `refs/flow/` live in the repo's common git dir, so they're visible
  from the main checkout and every worktree, and keep their commits reachable
  even if the branch is deleted.
- The flow plugin is currently disabled in herdr, only to see what worked
  without it (no known hook bug). The `workspace.closed` hook only runs when
  it's enabled, so the last step of this work is `herdr plugin enable
  custompro98.flow` and an end-to-end check: create a throwaway workspace,
  dirty it, close it, restore it with `prefix+shift+o`, and confirm the code
  and opencode conversation came back.

## Approaches

- **A. Snapshot to a git ref, delete the checkout (chosen).** Archive saves
  uncommitted work and metadata under `refs/flow/archive/<name>`, then removes
  the checkout as today. Restore recreates the worktree, re-runs file copy and
  setup, resumes opencode. Matches Conductor and the earlier decision to stop
  leaving checkouts on disk. Costs a full setup on restore and loses ignored
  files outside the include patterns. Chosen to conserve disk space.
- **B. Park the checkout.** Close the workspace, leave the directory; restore is
  `herdr worktree open`. Instant and lossless, but every archive keeps its
  `node_modules`, the branch stays checked out, and it reverses the
  archive-on-close decision. Rejected for disk use.
- Hybrid (park, prune to snapshot after N days): both code paths plus a cleanup
  job. Dropped as not worth it.

## Design

### Archive (`bin/on-workspace-closed`)

Replace the stash step and the detached-HEAD branch pinning with one archive
ref per workspace, written before the checkout is removed:

- **Ref:** `refs/flow/archive/<name>-<unix-time>`, where `<name>` is the
  checkout's basename (e.g. `bogota`). One ref per archive event, never
  overwritten: a city name can be reused once its branch is deleted, and
  hand-typed branches can share a basename, so the name alone isn't unique.
  *(Builder's call, settled in review.)*
- **Contents:** enough to restore exactly:
  - the checkout's `HEAD` commit (kept reachable by the ref, which replaces the
    `flow-archive/<name>` branch for detached HEADs),
  - uncommitted tracked and untracked (not ignored) changes, if any,
  - metadata: branch (empty if detached), path, herdr label, opencode session
    id, archived-at time.
- **Session id:** newest session from `opencode session list --format json`
  whose `directory` equals the checkout path; empty if none or if opencode
  fails (don't block the archive on opencode).
- Order: archive script → write ref → `git worktree remove --force`. If
  writing the ref fails, notify and keep the checkout (same as today's stash
  failure). Notify on success with the workspace name and "restore with
  prefix+shift+o", replacing today's "stashed changes" notification.
- **How it's triggered:** any close of a linked-worktree workspace, normally
  herdr's native `close_workspace` (`prefix+shift+d`). The `bin/archive` popup
  and its `prefix+shift+a` binding were removed; with restore, close isn't
  final, so herdr's own close confirmation is enough.

### Restore (`bin/unarchive`, keybinding `prefix+shift+o`)

- **Keybinding:** `[[keys.command]]` popup on `prefix+shift+o`, description
  "restore archived workspace". (`prefix+shift+h` is herdr's swap-pane-left.)
- **Which repo:** the repo of `HERDR_ACTIVE_PANE_CWD` (main checkout or any
  worktree, via `flow_root_path`). Outside a repo, pick one with
  `flow_pick_repo`, like `new-workspace`.
- **List:** one fzf row per `refs/flow/archive/*` in that repo, newest first:
  workspace name, opencode session title (joined from one `opencode session
  list` call; blank if missing), branch, archived-at. Nothing archived → popup
  message and exit.
- **On pick:**
  1. Recreate the worktree at the recorded path:
     - branch exists and isn't checked out elsewhere → check it out at its
       current tip;
     - branch deleted → recreate it at the archived `HEAD`;
     - detached archive → detached at the archived `HEAD`;
     - branch checked out in another worktree, or path already exists → popup
       error, archive untouched.
  2. Re-apply the uncommitted changes. If the branch moved since archiving and
     they don't apply cleanly, leave the conflicts in the worktree, keep the
     archive ref, and say so in the popup.
  3. `flow_copy_files`, then open it in herdr with `herdr worktree open --cwd
     <root> --path … --label … --focus` (`--cwd` groups it under the repo's
     workspace, as `new-workspace` and `open-repo` now do).
  4. Same layout as a new workspace: opencode pane on top, terminal below
     (70/30), setup script in the terminal (then default run action if
     `auto_run_after_setup`).
  5. Top pane: start opencode the way `on-worktree-created` does, `herdr agent
     start "$(flow_agent_name "$ws")" --kind opencode --pane …`, passing
     `-- -s <session-id>` so the conversation resumes (and `create-pr` /
     `review` can still find the agent by name). No session args if there's
     no session: if the recorded id is empty, look up the newest session for
     the path at restore time first.
  6. Delete the archive ref, unless step 2 left conflicts, or the branch's
     current tip doesn't contain the archived `HEAD` (rebased, reset or
     force-updated while archived). In that case the ref is the only thing
     keeping those commits reachable: keep it and say so in the popup.
     *(Builder's call, settled in review.)*
- `bin/unarchive <name>` does the same without the picker, for scripting;
  with several archives for one name it takes the newest.

### Shared code

The new-workspace layout in `on-worktree-created` (split, rename the terminal
pane, setup, run, `agent start`) should be shared with restore rather than
copied, with the opencode session args as the difference.

### Tests

Extend `test/on-workspace-closed.sh` (archive ref written with metadata and
uncommitted state, no stash, detached HEAD reachable) and add
`test/unarchive.sh` against a temp repo and the stub herdr: clean restore,
dirty restore, branch moved, branch deleted, detached, conflict keeps the ref,
branch rewritten keeps the ref, two archives with the same name both listed,
branch checked out elsewhere refuses. Stub `opencode` the same way as herdr.

## Left to the builder

- How the archive is encoded in git (e.g. a stash-style commit plus metadata in
  the commit message as trailers, or a wrapper commit), as long as one ref
  holds everything above and `git for-each-ref` can list it cheaply.
- Whether staged vs unstaged is preserved on restore (nice to have).
- Exact fzf row formatting and time display.
- Updating the plugin README/comments to describe restore.
