# Contract: run_all_quality_checks

## Discovery Scope
- Include all `tests/*_regression.ps1` scripts (unless `-IncludeDocsOnly`).
- Include all `tests/validate_*_docs.ps1` scripts.

## Execution Contract
- Before each script: `--- RUN <script> ---`
- On success: `--- PASS <script> ---`
- On failure: `--- FAIL <script> (exit=<code>) ---`

## Summary Contract
- Success: `run_all_quality_checks: PASSED`
- Failure: `run_all_quality_checks: FAILED` + failure list

## Exit Contract
- Return `0` when all scripts pass.
- Return non-zero when any script fails.
