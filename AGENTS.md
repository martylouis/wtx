# AGENTS.md

`wtx` is one bash script (`bin/wtx`) plus shell glue in `shell/`. Commands to test and lint are in README → Development.

## Bash 3.2

`bin/wtx` and `shell/*.sh` must run on macOS `/bin/bash`, which is bash 3.2. Write only bash 3.2 features: indexed arrays, `[[ ]]`, `$(...)`. Before you finish a change, run the tests with the old bash too:

```bash
WTX_TEST_BASH=/bin/bash bats test/
```

CI runs this on macOS. Your newer local bash will not show these failures.

## Shell glue

- `shell/wt.sh` is the bash wrapper and `shell/_wt.zsh` is the zsh wrapper. The wrapper exists only to `cd` the parent shell; put all other logic in `bin/wtx`.
- shellcheck does not support zsh, so CI skips `_wt.zsh`. Check zsh changes by hand in a zsh shell.

## Releases

release-please makes the versions, tags, and `CHANGELOG.md` from Conventional Commit subjects (`feat` → minor, `fix` → patch). Write each commit subject for the changelog. Let release-please edit `version.txt`, `CHANGELOG.md`, and `.release-please-manifest.json`.
