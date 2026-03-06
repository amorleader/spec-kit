# Contract: run_all_quality_checks JSON Summary

## JSON Mode
- Command: `tests/run_all_quality_checks.ps1 -Json`
- Output: single JSON object only.
- Required keys:
  - TOTAL_SCRIPTS
  - FAILED_SCRIPTS
  - PASSED_SCRIPTS
  - INCLUDE_DOCS_ONLY
  - ORIGINAL_BRANCH
  - RESULTS
  - STATUS

## Text Mode Compatibility
- Default output keeps RUN/PASS/FAIL blocks and final summary line.

## Exit Contract
- Return 0 when all scripts pass.
- Return non-zero when any script fails.
