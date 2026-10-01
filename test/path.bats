load test_helper

@test "path NAME prints the path on an exact match" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  "$WTX" new feat-two --no-install >/dev/null 2>&1
  out="$("$WTX" path feat-one)"
  [ "$out" = "$WTX_ROOT/repo/feat-one" ]
}

@test "path NAME accepts a substring match" {
  "$WTX" new feat-unique-xyz --no-install >/dev/null 2>&1
  out="$("$WTX" path unique)"
  [ "$out" = "$WTX_ROOT/repo/feat-unique-xyz" ]
}

@test "path with no match exits 1 with an error on stderr" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  status=0
  err="$("$WTX" path nomatch-zzz 2>&1 >/dev/null)" || status=$?
  [ "$status" -eq 1 ]
  [ -n "$err" ]
  out="$("$WTX" path nomatch-zzz 2>/dev/null)" || true
  [ -z "$out" ]
}

@test "path --names lists the worktree names" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  "$WTX" new feat-two --no-install >/dev/null 2>&1
  run "$WTX" path --names
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat-one"* ]]
  [[ "$output" == *"feat-two"* ]]
}

@test "cd NAME equals path NAME" {
  "$WTX" new feat-one --no-install >/dev/null 2>&1
  a="$("$WTX" cd feat-one)"
  b="$("$WTX" path feat-one)"
  [ "$a" = "$b" ]
  [ "$a" = "$WTX_ROOT/repo/feat-one" ]
}
