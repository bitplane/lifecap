#!/bin/sh

# returns all commands we can run
all_commands() {
    prefix="$1"
    filter="^$prefix\-[a-zA-Z0-9_]*$"
    # first get aliases
    alias | \
        sed -n 's/^alias[ \t]\+\([^=]\+\)=.*/\1/p' | \
        grep $filter 2>/dev/null

    # then functions
    set | \
        sed -nE 's/^([[:alpha:]_][[:alnum:]_]*) \(\).*/\1/p' | \
        grep $filter 2>/dev/null

    # then get executables on the path
    printf '%s' "$PATH" | \
        tr ':' '\0' | \
        xargs -0 -I{} \
            find "{}" -maxdepth 1 -type f -perm -111 -name "$prefix-*" \
                2>/dev/null | \
        sed 's|^.*/||' | \
        grep $filter 2>/dev/null
}

prefix="$(basename "$0")"

# If we're running --help
if [ "$1" = "--help" ]; then
    echo "$HELP"
    echo
    echo "Commands:"
    for cmd in $(all_commands "$prefix" | sed "s/^$prefix-//")
    do
        echo "  $cmd"
    done
    exit 0
fi

# If there's at least one argument, and the first arg does NOT start with '-',
# check if "prefix-$1" is recognized by all_commands. If yes, dispatch there.
if [ $# -gt 0 ] && [ "${1#-}" = "$1" ]; then
    subcmd="$1"
    if all_commands "$prefix" | grep -q "^${prefix}-${subcmd}\$"; then
        shift
        exec "${prefix}-${subcmd}" "$@"
        exit $?
    fi
fi

# otherwise, carry on
