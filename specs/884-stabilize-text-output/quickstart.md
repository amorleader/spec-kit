# Quickstart: Validate Text Output Stability

1. Run text output regression:
   - `powershell -ExecutionPolicy Bypass -File tests/text_output_check_regression.ps1`
2. Run docs validator:
   - `powershell -ExecutionPolicy Bypass -File tests/validate_text_output_check_docs.ps1`
3. Run docs-only aggregate:
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -Json -IncludeDocsOnly`
4. Expected:
   - text key labels remain stable;
   - failure hint style remains consistent;
   - docs validation passes.