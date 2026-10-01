# wtx

Manage git worktrees from one place: create, list, jump to, and remove them. Works well with direnv, because `WTX_ROOT` can be set per environment.

## Install

Clone the repo to any directory, then link the script into a directory on your `PATH`:

```bash
git clone https://github.com/martylouis/wtx ~/.local/share/wtx
mkdir -p ~/.local/bin
ln -s ~/.local/share/wtx/bin/wtx ~/.local/bin/wtx
```

Make sure `~/.local/bin` is in your `PATH`.

Then add to `~/.zshrc` (or `~/.bashrc`, with `bash` in place of `zsh`):

```bash
eval "$(wtx init zsh)"
```

This defines a shell function that is also named `wtx`. The function is needed because a child process cannot change the directory of the shell. It calls the `wtx` program for all work, and it does the `cd` for `wtx new` and `wtx cd`.

## Usage

```bash
wtx new [BRANCH]       # Create a worktree from current HEAD (or with auto name)
wtx list               # Status table of all worktrees
wtx cd [NAME]          # Jump to a worktree (fzf picker or numbered list)
wtx rm NAME            # Tear down a worktree and delete its branch (if merged)
wtx push [TARGET]      # Send this worktree's config to TARGET (default: primary)
wtx pull [SOURCE]      # Bring SOURCE's config into this worktree (default: primary)
```

## Configuration

**`WTX_ROOT`** (environment variable)
- Default: `~/code/.worktrees`
- `WORKTREE_ROOT` is still read as a fallback for older setups
- Set per-environment via direnv: `export WTX_ROOT="$HOME/code/.worktrees/myproject"`

**`.worktreeinclude`** (gitignored file in repo root)
- One gitignore-style pattern per line (`#` comments ok)
- Leading `/` anchors to repo root; otherwise matches at any depth or basename
- Leading `!` negates a preceding match; last match wins
- Example:
  ```
  .env*
  !.env.example
  .secrets/
  ```
- Add `.worktreeinclude` itself to `.gitignore` so it propagates to new worktrees
- What `.worktreeinclude` lists gets seeded/pushed/pulled; tracked files come across git automatically

**`NO_COLOR`**
- Set to any value to disable colored output: `NO_COLOR=1 wtx list`

## Requirements

- **bash**
- **git**
- **fzf** (optional; numbered list fallback without it)

## Development

```bash
bats test/                      # Run tests
shellcheck bin/wtx shell/*.sh   # Check shell syntax
```

## License

MIT
