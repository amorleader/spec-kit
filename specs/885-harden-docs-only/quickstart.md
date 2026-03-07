# Quickstart: Validate Docs-Only Aggregate Hardening

1. Run docs-only regression:
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks_docs_only_regression.ps1`
2. Run docs validator for this feature:
   - `powershell -ExecutionPolicy Bypass -File tests/validate_docs_only_hardening_docs.ps1`
3. Run docs-only aggregate check:
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -Json -IncludeDocsOnly`
4. Expected:
   - docs-only JSON remains parseable and field-compatible;
   - only docs validators are included in `RESULTS`;
   - aggregate status and counts are consistent.