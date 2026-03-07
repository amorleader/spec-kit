# Contract: Quality Runner Regression Coverage

## Regression Script Contract
- `tests/run_all_quality_checks_regression.ps1` must validate:
  - JSON summary parseability and required fields
  - required summary fields include `TOTAL_SCRIPTS` and `RESULTS`
  - text mode RUN/PASS/final summary compatibility
  - branch stability before/after execution

## Docs Validation Contract
- `tests/validate_run_all_quality_checks_docs.ps1` must validate:
  - quickstart references Json usage
  - contract documents required JSON fields
  - spec mentions branch stability context

## Compatibility
- No behavior change in `tests/run_all_quality_checks.ps1`.
