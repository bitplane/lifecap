# shellcheck shell=sh

. "$(dirname "$0")"/subcmd.sh

# set paths for local collection
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/lifecap"
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/lifecap"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/lifecap"

# ensure dirs exist
mkdir -p "$config_dir/jobs" \
         "$data_dir/topics" \
         "$cache_dir"

# add collectors to the path
PATH="$config_dir/collectors:$PATH"

# A bit of safety around paths
safe_path() {
    path="$1"
        
    # Reject wildcards/globs
    case "$path" in
      *[\*\?]* )
        echo "Wildcards not allowed!"
        exit 1
        ;;
      *\.\.* )
        echo "No traversal, thanks."
        exit 1
        ;;
    esac
}

path_exists() {
    path="$1"
    safe_path "$path"
    real_path=$(cd "$(dirname "$path")" 2>/dev/null && pwd -P)/$(basename "$path")
    [ ! "$real_path" = "$path" ] && echo "Invalid path!" && exit 1
}
