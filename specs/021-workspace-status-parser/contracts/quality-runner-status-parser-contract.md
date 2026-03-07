# Contract: Quality Runner Status Parser Hardening

## Parsing Contract
- Runner must normalize porcelain status paths before recovery processing.
- For rename-style entries (`old -> new`), normalized path must be `new`.
- Paths with spaces must remain intact after parsing.

## Recovery Contract
- Parsed tracked entries must feed tracked-recovery flow.
- Existing behavior for untracked temp cleanup remains unchanged.

## Compatibility
- No new CLI arguments.
- Existing JSON and text top-level semantics remain backward-compatible.
