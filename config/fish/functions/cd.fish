function cd --description 'Change directory'
    set -l MAX_DIR_HIST 25
    set -l IS_KITTY (if [ "$TERM" = "xterm-kitty" ]; echo "true"; else; echo ""; end)
    set -l SET_NAME (if [ -n "$IS_KITTY" ]; echo "kitty @ set-tab-title (pwd | xargs basename)"; else; echo ""; end)

    if test (count $argv) -gt (test "$argv[1]" = "--" && echo 2 || echo 1)
        printf "%s\n" (_ "Too many args for cd command")
        return 1
    end

    # Skip history in subshells.
    if status --is-command-substitution
        builtin cd $argv
        eval $SET_NAME
        return $status
    end

    # Avoid set completions.
    set -l previous $PWD

    if test "$argv" = -
        if test "$__fish_cd_direction" = next
            nextd
        else
            prevd
        end
        return $status
    end

    builtin cd $argv eval $SET_NAME
    set -l cd_status $status

    if test $cd_status -eq 0 -a "$PWD" != "$previous"
        set -q dirprev
        or set -l dirprev
        set -q dirprev[$MAX_DIR_HIST]
        and set -e dirprev[1]

        # If dirprev, dirnext, __fish_cd_direction
        # are set as universal variables, honor their scope.

        set -U -q dirprev
        and set -U -a dirprev $previous
        or set -g -a dirprev $previous

        set -U -q dirnext
        and set -U -e dirnext
        or set -e dirnext

        set -U -q __fish_cd_direction
        and set -U __fish_cd_direction prev
        or set -g __fish_cd_direction prev
    end


    eval $SET_NAME
    return $cd_status
end
