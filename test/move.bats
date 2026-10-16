load test_helper

@test "move NAME moves the worktree to the current root" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  export WTX_ROOT="$TEST_TMP/other"
  out="$("$WTX" move feat-one 2>/dev/null)"
  [ "$out" = "$TEST_TMP/other/repo/feat-one" ]
  [ -d "$TEST_TMP/other/repo/feat-one" ]
  [ ! -e "$TEST_TMP/worktrees/repo/feat-one" ]
  git worktree list | grep -q "$TEST_TMP/other/repo/feat-one"
}

@test "move removes empty parent dirs at the old path" {
  "$WTX" new feat/nested --no-install >/dev/null 2>&1
  export WTX_ROOT="$TEST_TMP/other"
  "$WTX" move feat/nested >/dev/null 2>&1
  [ -d "$TEST_TMP/other/repo/feat/nested" ]
  [ ! -e "$TEST_TMP/worktrees/repo/feat" ]
}

@test "move NAME DEST moves the worktree to DEST" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  out="$("$WTX" move feat-one "$TEST_TMP/elsewhere/x" 2>/dev/null)"
  [ "$out" = "$TEST_TMP/elsewhere/x" ]
  [ -d "$TEST_TMP/elsewhere/x" ]
}

@test "move --dry-run changes nothing" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  export WTX_ROOT="$TEST_TMP/other"
  run "$WTX" move feat-one --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"plan"* ]]
  [ -d "$TEST_TMP/worktrees/repo/feat-one" ]
  [ ! -e "$TEST_TMP/other" ]
}

@test "move refuses a DEST that exists" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  mkdir -p "$TEST_TMP/taken"
  run "$WTX" move feat-one "$TEST_TMP/taken"
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
  [ -d "$TEST_TMP/worktrees/repo/feat-one" ]
}

@test "move refuses the main checkout" {
  run "$WTX" move main "$TEST_TMP/x"
  [ "$status" -eq 1 ]
  [[ "$output" == *"main checkout"* ]]
}

@test "move refuses a root inside the main checkout" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  export WTX_ROOT="$REPO/.worktrees"
  run "$WTX" move feat-one
  [ "$status" -eq 1 ]
  [[ "$output" == *"inside the main checkout"* ]]
}

@test "move with no match exits 1" {
  run "$WTX" move nomatch-zzz
  [ "$status" -eq 1 ]
}

@test "wtx move cds to the new path when you stood inside the old one" {
  eval "$("$WTX" init bash)"
  wtx new feat-one --no-install 2>/dev/null
  export WTX_ROOT="$TEST_TMP/other"
  wtx move feat-one 2>/dev/null
  [ "$PWD" = "$TEST_TMP/other/repo/feat-one" ]
}

@test "wtx move keeps the directory when you stood outside the worktree" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  eval "$("$WTX" init bash)"
  export WTX_ROOT="$TEST_TMP/other"
  wtx move feat-one 2>/dev/null
  [ "$PWD" = "$REPO" ]
}

@test "move runs the installer from the lockfile, in the new path" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  touch "$TEST_TMP/worktrees/repo/feat-one/package-lock.json"
  mkdir -p "$TEST_TMP/bin"
  printf '#!/bin/sh\npwd > "%s/npm.ran"\n' "$TEST_TMP" > "$TEST_TMP/bin/npm"
  chmod +x "$TEST_TMP/bin/npm"
  export PATH="$TEST_TMP/bin:$PATH"
  export WTX_ROOT="$TEST_TMP/other"
  run "$WTX" move feat-one
  [ "$status" -eq 0 ]
  [ "$(cat "$TEST_TMP/npm.ran")" = "$TEST_TMP/other/repo/feat-one" ]
}

@test "move --no-install does not run the installer" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  touch "$TEST_TMP/worktrees/repo/feat-one/package-lock.json"
  mkdir -p "$TEST_TMP/bin"
  printf '#!/bin/sh\ntouch "%s/npm.ran"\n' "$TEST_TMP" > "$TEST_TMP/bin/npm"
  chmod +x "$TEST_TMP/bin/npm"
  export PATH="$TEST_TMP/bin:$PATH"
  export WTX_ROOT="$TEST_TMP/other"
  run "$WTX" move feat-one --no-install
  [ "$status" -eq 0 ]
  [ ! -e "$TEST_TMP/npm.ran" ]
}

@test "move --dry-run shows the installer and runs nothing" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  touch "$TEST_TMP/worktrees/repo/feat-one/pnpm-lock.yaml"
  export WTX_ROOT="$TEST_TMP/other"
  run "$WTX" move feat-one --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"install: pnpm install"* ]]
  [ -d "$TEST_TMP/worktrees/repo/feat-one" ]
}
