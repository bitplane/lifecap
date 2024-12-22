#!/bin/sh
#
# run.sh - Minimal entry point for running the test harness
#
# Usage: ./run.sh [PATHS...]
#   If no PATHS are specified, runs tests under the current directory.
#   If one or more PATHS are specified, runs tests found there.

# Source the test harness (which defines __test_run_all, etc.)
. "$(dirname "$0")/_test.sh"

# Create a temporary file to hold stderr
tmp_stderr="/tmp/lifecap_test_stderr.$$"

# 1) Run the tests, capturing ONLY stderr to $tmp_stderr
__test_run_all "$@" 2>"$tmp_stderr"
RES=$?

echo
echo

# 2) Now that the tests have finished, dump all stderr output at once
if [ -s "$tmp_stderr" ]; then
  cat "$tmp_stderr"
fi
rm -f "$tmp_stderr"

echo

if [ "$RES" -eq 0 ]; then
  echo "All tests passed!"
else
  echo "Some tests failed (exit code $RES)."
fi

exit "$RES"
