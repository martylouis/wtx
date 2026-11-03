# wtx

Manage git worktrees from one place: create, list, jump to, and remove them. Each worktree goes in its own repo, at `<repo>/.worktrees/<branch>`, so direnv loads the repo's `.envrc` in the worktree too.

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
wtx move NAME [DEST]   # Move a worktree (default: to <repo>/.worktrees/<branch>); reinstalls deps unless --no-install
wtx push [TARGET]      # Send this worktree's config to TARGET (default: primary)
wtx pull [SOURCE]      # Bring SOURCE's config into this worktree (default: primary)
```

## Configuration

**Worktree folder**
- New worktrees go to `<repo>/.worktrees/<branch>`. There is no setting.
- Add `.worktrees/` to your global gitignore (`git config --global core.excludesfile`), so `git status` in the main checkout does not show it.
- `WTX_ROOT` and `WORKTREE_ROOT` are no longer read. To move an old worktree into the repo, run `wtx move NAME`.
- `wtx move NAME DEST` can still put a worktree outside the repo.

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
