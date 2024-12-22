. $(dirname $0)/subcmd.sh

# set paths for local collection
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/lifecap"
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/lifecap"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/lifecap"

# ensure dirs exist
mkdir -p "$config_dir/collectors" \
         "$data_dir/topics" \
         "$cache_dir"

# add collectors to the path
PATH="$config_dir/collectors:$PATH"

