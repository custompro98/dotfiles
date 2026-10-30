# Conductor-style CONDUCTOR_* and [environment_variables] in herdr panes inside
# a git worktree, recomputed on cd. See config/herdr/plugins/flow.
if set -q HERDR_ENV
    function __herdr_flow_env --on-variable PWD
        set -q __herdr_flow_vars[1]; and set -e $__herdr_flow_vars
        set -g __herdr_flow_vars
        for line in (~/.dotfiles/config/herdr/plugins/flow/bin/env-for $PWD)
            set -l kv (string split -m 1 = $line)
            set -gx $kv[1] $kv[2]
            set -a __herdr_flow_vars $kv[1]
        end
    end
    __herdr_flow_env
end
