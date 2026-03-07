# Contract: Quality Runner Workspace Guard

## Recovery Contract
- Runner captures workspace snapshot before and after each child script.
- Runner reverts only newly introduced tracked modifications from the child script run.
- Runner deletes only newly introduced temp files matching `*.bak` and `*.tmp`.
- Existing pre-run tracked/untracked changes must be preserved.

## Output Contract
- Text mode prints recovery diagnostics when recovery actions are applied.
- JSON mode adds recovery statistics fields:
  - `RECOVERED_TRACKED_CHANGES`
  - `DELETED_TEMP_FILES`

## Compatibility
- Existing exit semantics and script pass/fail rules remain unchanged.
