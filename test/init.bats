load test_helper

@test "init bash prints the wtx function only" {
  run "$WTX" init bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"wtx() {"* ]]
  [[ "$output" != *"compdef"* ]]
}

@test "init zsh prints the wtx function and the completion" {
  run "$WTX" init zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"wtx() {"* ]]
  [[ "$output" == *"compdef _wt wtx"* ]]
}

@test "init with an unknown shell exits 2" {
  run "$WTX" init fish
  [ "$status" -eq 2 ]
}

@test "wtx cd NAME changes the directory of the calling bash" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  eval "$("$WTX" init bash)"
  wtx cd feat-one
  [ "$PWD" = "$WTX_ROOT/repo/feat-one" ]
}

@test "wtx new changes into the new worktree" {
  eval "$("$WTX" init bash)"
  wtx new feat-two --no-install 2>/dev/null
  [ "$PWD" = "$WTX_ROOT/repo/feat-two" ]
}

@test "wtx cd with no match keeps the directory and returns 1" {
  eval "$("$WTX" init bash)"
  status=0
  wtx cd nomatch-zzz 2>/dev/null || status=$?
  [ "$status" -eq 1 ]
  [ "$PWD" = "$REPO" ]
}
