# Conductor-style CONDUCTOR_* variables in herdr panes inside a git worktree,
# recomputed on cd. See config/herdr/plugins/flow.
if set -q HERDR_ENV
    function __herdr_flow_env --on-variable PWD
        set -e CONDUCTOR_ROOT_PATH CONDUCTOR_WORKSPACE_PATH CONDUCTOR_WORKSPACE_NAME CONDUCTOR_DEFAULT_BRANCH CONDUCTOR_PORT
        for line in (~/.dotfiles/config/herdr/plugins/flow/bin/env-for $PWD)
            set -l kv (string split -m 1 = $line)
            set -gx $kv[1] $kv[2]
        end
    end
    __herdr_flow_env
end
