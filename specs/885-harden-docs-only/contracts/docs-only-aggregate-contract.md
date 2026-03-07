# Contract: Docs-Only Aggregate Execution

## Scope
- `tests/run_all_quality_checks.ps1` with `-IncludeDocsOnly`

## Input Contract
- Existing flags remain unchanged (`-Json`, `-IncludeDocsOnly`, `-PerScriptTimeoutSec`).

## Output Contract
- JSON mode keeps stable top-level fields:
  - `TOTAL_SCRIPTS`, `FAILED_SCRIPTS`, `PASSED_SCRIPTS`, `TIMED_OUT_SCRIPTS`
  - `RECOVERED_TRACKED_CHANGES`, `DELETED_TEMP_FILES`
  - `INCLUDE_DOCS_ONLY`, `PER_SCRIPT_TIMEOUT_SEC`, `ORIGINAL_BRANCH`
  - `RESULTS`, `STATUS`
- `RESULTS` contains only docs validator entries in docs-only mode.

## Failure Propagation Contract
- Any failing docs validator sets aggregate `STATUS` to `FAILED`.
- Failure counts and per-item statuses remain consistent.