# flow: archive on workspace close

## Intent

Closing a flow workspace in herdr (sidebar, keybinding, CLI) should do what
Conductor's archive does: run the archive script, delete the worktree checkout,
keep the branch. Closing is final. Today only the `prefix+shift+a` popup
(`bin/archive`) archives; any other close leaves the checkout on disk
(e.g. `~/.herdr/worktrees/.dotfiles/{dhaka,kyoto,lisbon}`).

## Goals

- Every close of a linked-worktree workspace archives it, exactly once.
- No uncommitted work is silently lost.

## Non-goals

- Reopening closed workspaces.
- Cleaning up worktrees that were closed before this change.
- Archiving repo workspaces (main checkouts opened via `prefix+f`).

## Approaches

- **A. Close is the single archive path (chosen).** A `workspace.closed` hook
  archives; `bin/archive` becomes "show status, confirm, `herdr workspace
  close`". One code path, no double runs. Cost: the popup no longer shows the
  archive script's output live.
- **B. Two paths with a skip marker.** Popup keeps doing the work and leaves a
  marker; the hook skips marked workspaces. Better popup UX, double the code,
  and a marker that can go stale.
- Hooking `worktree.removed` was ruled out: the checkout is gone by then.

## Design

- **Manifest:** add `[[events]] on = "workspace.closed"` →
  `bin/on-workspace-closed`.
- **`bin/on-workspace-closed`:** read `.workspace.worktree` from
  `HERDR_PLUGIN_EVENT_JSON`. Exit quietly unless `is_linked_worktree` is true
  and `checkout_path` still exists. Then, in the checkout:
  1. `script archive <path>` (the existing script runner, so `CONDUCTOR_*` and
     `[environment_variables]` apply).
  2. If the checkout is dirty, `git stash push -u -m "flow archive <branch>"`
     so the work is recoverable via `git stash list` from any checkout.
  3. `git worktree remove --force <path>` (herdr's `worktree remove` needs a
     live workspace, which no longer exists). Branch is kept.
  - Archive script failure doesn't stop removal; it and any stash/remove
    failure raise `herdr notification show`. A successful stash also notifies,
    naming the stash, so it isn't forgotten.
- **`bin/archive`:** keep the linked-worktree check, status display, and
  confirm prompt (reworded: closing is final, branch kept, dirty changes get
  stashed). On yes, `herdr workspace close "$ws"`. Drop the script run and the
  force-remove prompt.

## Left to the builder

- Whether herdr waits on or times out event hooks; if a slow archive script
  could be killed or block the UI, detach the work (e.g. `nohup … &`) and log
  output under `HERDR_PLUGIN_STATE_DIR`.
- Where archive script output goes when it isn't failing (a log file under
  `HERDR_PLUGIN_STATE_DIR` is the suggested default).
- Updating the `prefix+shift+a` description in `config/herdr/config.toml` and
  the comment at the top of `bin/archive`.
