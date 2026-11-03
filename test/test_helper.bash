# Shared setup for wtx tests.
#
# Every test gets its own temp dir (BATS_TEST_TMPDIR, which bats removes after
# the test), a fake HOME, and no global/system git config, so the tests never
# read or write the real HOME or the real git config.
#
# Set WTX_TEST_BASH to run wtx with a given bash, for example
# WTX_TEST_BASH=/bin/bash on macOS to test with bash 3.2.

WTX_REAL="$(cd "$BATS_TEST_DIRNAME/.." && pwd -P)/bin/wtx"

setup() {
  TEST_TMP="$(cd "$BATS_TEST_TMPDIR" && pwd -P)"
  export HOME="$TEST_TMP/home"
  mkdir -p "$HOME"
  export WTX_ROOT="$TEST_TMP/worktrees"
  unset WORKTREE_ROOT
  export NO_COLOR=1
  export GIT_CONFIG_GLOBAL=/dev/null
  export GIT_CONFIG_SYSTEM=/dev/null
  export GIT_CONFIG_NOSYSTEM=1

  # Put a `wtx` on PATH (the shell wrapper calls `command wtx`). By default it
  # is a symlink, which also tests that `wtx init` follows symlinks.
  mkdir -p "$TEST_TMP/bin"
  if [ -n "${WTX_TEST_BASH:-}" ]; then
    printf '#!/bin/sh\nexec "%s" "%s" "$@"\n' "$WTX_TEST_BASH" "$WTX_REAL" > "$TEST_TMP/bin/wtx"
    chmod +x "$TEST_TMP/bin/wtx"
  else
    ln -s "$WTX_REAL" "$TEST_TMP/bin/wtx"
  fi
  export PATH="$TEST_TMP/bin:$PATH"
  WTX="$TEST_TMP/bin/wtx"

  REPO="$TEST_TMP/repo"
  mkdir -p "$REPO"
  cd "$REPO" || return 1
  git init -q
  git symbolic-ref HEAD refs/heads/main
  git config user.name "Test User"
  git config user.email "test@example.com"
  echo "hello" > README.md
  git add README.md
  git commit -q -m "initial"
}

teardown() {
  cd / || true
}
