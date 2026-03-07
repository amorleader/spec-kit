# Contract: Quality Runner Timeout Guard

## CLI Contract
- `tests/run_all_quality_checks.ps1` supports optional `-PerScriptTimeoutSec <int>`.
- Default `0` means timeout guard disabled.
- Invalid timeout values (negative / non-numeric) must fail fast with clear error.

## Execution Contract
- When a child script exceeds timeout:
  - child is terminated,
  - result is marked as `TIMEOUT`,
  - aggregate execution continues for remaining scripts.

## Output Contract
- Text mode must show timeout label and include timeout in summary counts.
- JSON mode must keep existing fields and add timeout-related count field (`TIMED_OUT_SCRIPTS`).
- `RESULTS` entries for timed-out scripts must be machine-identifiable.

## Compatibility
- Existing behavior remains unchanged when timeout guard is disabled (`-PerScriptTimeoutSec 0`).
