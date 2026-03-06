# Contract: Quality Runner Status Parser Z-Mode

## Parser Contract
- Workspace snapshot uses `git status --porcelain -z`.
- Entries are parsed as NUL-separated tokens.
- Rename/copy status parses two paths (old/new).

## Recovery Contract
- Recovery logic can evaluate both old and new paths from rename entries.
- Existing pre-run workspace changes remain preserved.

## Output Contract
- Existing JSON/text output contracts remain compatible.
- No new CLI parameters are introduced by this feature.
