export PATH=$(dirname "$0")/../src:$PATH

export test_tempdir="/tmp/lifecap-tests-$$"
mkdir -p "$test_tempdir"

export HOME="$test_tempdir"
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CACHE_HOME=$HOME/.cache
