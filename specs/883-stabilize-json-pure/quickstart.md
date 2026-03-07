# Quickstart: Validate JSON Pure Output

1. Run JSON purity regression:
   - `powershell -ExecutionPolicy Bypass -File tests/json_pure_output_regression.ps1`
2. Run docs validator:
   - `powershell -ExecutionPolicy Bypass -File tests/validate_json_pure_output_docs.ps1`
3. Run docs-only aggregate:
   - `powershell -ExecutionPolicy Bypass -File tests/run_all_quality_checks.ps1 -Json -IncludeDocsOnly`
4. Expected:
   - `-Json` outputs are parseable;
   - no stdout contamination in JSON mode;
   - docs validation passes.