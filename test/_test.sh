###############################################################################
# _test.sh - POSIX shell test harness library
#
# Provides functions:
#   - __test_find_tests:   find 'test_*.sh' under given paths
#   - __test_pushd, __test_popd:   custom push/pop for directory stack in POSIX
#   - __test_run_one:      run a single test file with layered setup/teardown
#   - __test_run_all:      find and run all tests, return highest exit code
#
# USAGE:
#   # In your run.sh (or similar):
#   . "$(dirname "$0")/_test.sh"
#   __test_run_all "$@"
#   status=$?
#   # Then do whatever with 'status' (print "All tests passed!" or so)
###############################################################################

# Keep track of the directory where run.sh is invoked, so we can get back there
RUN_DIR="$(pwd -P)"      
__test_dir_stack=""  # For our custom pushd/popd

###############################################################################
# __test_pushd DIR
#   Emulates pushd in POSIX by storing the current directory in a global stack,
#   then cd to DIR (converted to absolute path if needed).
###############################################################################
__test_pushd() {
  if [ $# -lt 1 ]; then
    echo "__test_pushd: missing directory argument" >&2
    return 1
  fi

  local target="$1"
  local oldpwd newdir

  case "$target" in
    /*)  # already absolute
      ;;
    *)
      oldpwd="$PWD"
      if ! cd "$target" 2>/dev/null; then
        echo "__test_pushd: cannot cd to '$target'" >&2
        return 1
      fi
      newdir="$(pwd -P)"
      cd "$oldpwd" || return 1
      target="$newdir"
      ;;
  esac

  # Push current directory onto stack
  if [ -n "$__test_dir_stack" ]; then
    __test_dir_stack="$PWD:$__test_dir_stack"
  else
    __test_dir_stack="$PWD"
  fi

  # Now cd to 'target'
  if ! cd "$target" 2>/dev/null; then
    echo "__test_pushd: cannot cd to '$target'" >&2
    return 1
  fi
}

###############################################################################
# __test_popd
#   Emulates popd in POSIX by cd-ing back to the topmost dir stored in the stack.
###############################################################################
__test_popd() {
  if [ -z "$__test_dir_stack" ]; then
    echo "__test_popd: directory stack empty" >&2
    return 1
  fi

  local top
  top="${__test_dir_stack%%:*}"

  # If top == entire string, stack becomes empty
  if [ "$top" = "$__test_dir_stack" ]; then
    __test_dir_stack=""
  else
    __test_dir_stack="${__test_dir_stack#*:}"
  fi

  if ! cd "$top" 2>/dev/null; then
    echo "__test_popd: cannot cd to '$top'" >&2
    return 1
  fi
}

###############################################################################
# __test_cleanup_dirs
#   Pops directories until we return to $RUN_DIR, sourcing _teardown.sh if found.
#   (We no longer do global exit code updates here—just cleanup.)
###############################################################################
__test_cleanup_dirs() {
  while [ "$(pwd -P)" != "$RUN_DIR" ]; do
    if [ -f "_teardown.sh" ]; then
      . "./_teardown.sh"
    fi
    __test_popd >/dev/null 2>&1 || break
  done
}

###############################################################################
# __test_run_one FILE
#   Splits FILE into directories + final script, pushd into each, source
#   _setup.sh, run the test, pop back. Returns the test script's exit code.
###############################################################################
__test_run_one() {
  local file="$1"
  local dirpath="$file"
  local script_name=""
  local path_dirs=""
  local test_status=0

  # Decompose path until the last segment is the file name
  while echo "$dirpath" | grep -q '/'; do
    local front="${dirpath%%/*}"
    dirpath="${dirpath#*/}"
    path_dirs="$path_dirs
$front"
  done

  script_name="$dirpath"

  # Start from RUN_DIR
  cd "$RUN_DIR" || return 1

  # Descend directories, sourcing any _setup.sh
  oldIFS="$IFS"
  IFS='
'
  for d in $path_dirs; do
    [ -z "$d" ] && continue
    if ! __test_pushd "$d" >/dev/null; then
      echo "ERROR: cannot push into '$d' (from path $file)" >&2
      __test_cleanup_dirs
      IFS="$oldIFS"
      return 1
    fi

    if [ -f "_setup.sh" ]; then
      . "./_setup.sh"
    fi
  done
  IFS="$oldIFS"

  # Must exist
  if [ ! -f "$script_name" ]; then
    echo "ERROR: test script '$script_name' not found in $(pwd -P)" >&2
    __test_cleanup_dirs
    return 1
  fi

  # Run the test script in the current shell
  . "./$script_name" || test_status=$?

  __test_cleanup_dirs
  return $test_status
}

###############################################################################
# __test_find_tests [PATHS...]
#   Uses `find` to locate all 'test_*.sh' under each path. Sort them externally.
###############################################################################
__test_find_tests() {
  if [ $# -eq 0 ]; then
    set -- "."
  fi

  for p in "$@"; do
    find "$p" -type f -name 'test_*.sh' 2>/dev/null
  done
}

###############################################################################
# __test_run_all [PATHS...]
#   1) Gathers test files
#   2) Runs each test, capturing highest exit code
#   3) Prints "E" for error, "." for success
#   4) Returns the highest exit code
###############################################################################
__test_run_all() {
  local test_files
  local ret=0

  test_files="$(__test_find_tests "$@" | sort)"
  if [ -z "$test_files" ]; then
    echo "No test_*.sh files found under: $*" >&2
    return 1
  fi

  printf "Running tests: "
  count=15

  oldIFS="$IFS"
  IFS='
'
  for f in $test_files; do
    [ -z "$f" ] && continue

    local test_status=0
    __test_run_one "$f" || test_status=$?

    if [ "$test_status" -ne 0 ]; then
      echo "Test failed: $f" >&2
      [ "$test_status" -gt "$ret" ] && ret="$test_status"
      printf "E"
    else
      printf "."
    fi
    count="$(expr "$count" + 1)"
    if [ "$count" -eq 80 ]; then
        count=0
        echo
    fi
  done
  IFS="$oldIFS"

  return $ret
}
