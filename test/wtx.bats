load test_helper

@test "new BRANCH creates the worktree, prints only its path on stdout" {
  out="$("$WTX" new feat-a --no-install 2>/dev/null)"
  [ "$out" = "$WTX_ROOT/repo/feat-a" ]
  [ -d "$out" ]
  git rev-parse --verify --quiet refs/heads/feat-a
}

@test "new with no name makes an auto-named worktree" {
  out="$("$WTX" new --no-install 2>/dev/null)"
  [ -d "$out" ]
  [ "$(dirname "$out")" = "$WTX_ROOT/repo" ]
  name="$(basename "$out")"
  [[ "$name" =~ ^[0-9]{2}-[0-9]{2}-[0-9]{2}-[a-z]+-[a-z]+$ ]]
  git rev-parse --verify --quiet "refs/heads/$name"
}

@test "new refuses a root inside the repo" {
  export WTX_ROOT="$REPO/.worktrees"
  run "$WTX" new feat-b --no-install
  [ "$status" -eq 1 ]
  [[ "$output" == *"inside the main checkout"* ]]
  [ ! -e "$REPO/.worktrees" ]
}

@test "WORKTREE_ROOT is used when WTX_ROOT is unset" {
  unset WTX_ROOT
  export WORKTREE_ROOT="$TEST_TMP/old-root"
  out="$("$WTX" new feat-c --no-install 2>/dev/null)"
  [ "$out" = "$WORKTREE_ROOT/repo/feat-c" ]
  [ -d "$out" ]
}

@test "list shows the primary and the new worktree" {
  "$WTX" new feat-d --no-install >/dev/null 2>&1
  run "$WTX" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"main"*"primary"* ]]
  [[ "$output" == *"feat-d"* ]]
  [[ "$output" == *"$WTX_ROOT/repo/feat-d"* ]]
}

@test "rm NAME -y removes a clean merged worktree and its branch" {
  wt="$("$WTX" new feat-e --no-install 2>/dev/null)"
  run "$WTX" rm feat-e -y
  [ "$status" -eq 0 ]
  [ ! -e "$wt" ]
  ! git rev-parse --verify --quiet refs/heads/feat-e
}

@test "new seeds a gitignored .env listed in .worktreeinclude" {
  printf '.env\n.worktreeinclude\n' > .gitignore
  git add .gitignore
  git commit -q -m "ignore config"
  echo "SECRET=1" > .env
  echo ".env" > .worktreeinclude
  echo "OTHER=1" > other.local   # untracked-but-not-ignored: not seeded
  wt="$("$WTX" new feat-f --no-install 2>/dev/null)"
  [ -f "$wt/.env" ]
  [ "$(cat "$wt/.env")" = "SECRET=1" ]
  [ -f "$wt/.worktreeinclude" ]
  [ ! -e "$wt/other.local" ]
}

@test "help exits 0 and mentions wtx" {
  run "$WTX" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"wtx"* ]]
}

@test "new seeds nothing when there is no .worktreeinclude (ignored files exist)" {
  printf 'build.log\n' > .gitignore
  git add .gitignore
  git commit -q -m "ignore log"
  echo "log" > build.log
  run "$WTX" new feat-g --no-install
  [ "$status" -eq 0 ]
  [ -d "$WTX_ROOT/repo/feat-g" ]
  [ ! -e "$WTX_ROOT/repo/feat-g/build.log" ]
}

@test "new --dry-run prints nothing on stdout and changes nothing" {
  out="$("$WTX" new feat-h --dry-run 2>/dev/null)"
  [ -z "$out" ]
  [ ! -e "$WTX_ROOT/repo/feat-h" ]
  ! git rev-parse --verify --quiet refs/heads/feat-h
}

@test "list shows paths under HOME as ~ (and only real HOME prefixes)" {
  export WTX_ROOT="$HOME/wt"
  "$WTX" new feat-i --no-install >/dev/null 2>&1
  export WTX_ROOT="${HOME}x/wt"
  "$WTX" new feat-j --no-install >/dev/null 2>&1
  run "$WTX" list
  [ "$status" -eq 0 ]
  [[ "$output" == *" ~/wt/repo/feat-i"* ]]
  [[ "$output" == *" ${HOME}x/wt/repo/feat-j"* ]]
  [[ "$output" != *"'~'"* ]]
}

@test "pull copies new listed config from the primary, without overwriting" {
  printf '.env*\n.worktreeinclude\n' > .gitignore
  git add .gitignore
  git commit -q -m "ignore config"
  echo ".env*" > .worktreeinclude
  wt="$("$WTX" new feat-k --no-install --no-seed 2>/dev/null)"
  echo "A=primary" > .env
  echo "B=primary" > .env.local
  echo "B=mine" > "$wt/.env.local"
  cd "$wt"
  run "$WTX" pull
  [ "$status" -eq 0 ]
  [ "$(cat "$wt/.env")" = "A=primary" ]
  [ "$(cat "$wt/.env.local")" = "B=mine" ]
}
