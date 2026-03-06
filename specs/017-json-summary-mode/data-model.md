# Data Model: Quality Runner JSON Summary

## Entity: RunnerSummary
- TOTAL_SCRIPTS: int
- FAILED_SCRIPTS: int
- PASSED_SCRIPTS: int
- INCLUDE_DOCS_ONLY: bool
- ORIGINAL_BRANCH: string|null
- STATUS: PASSED|FAILED|NO_SCRIPTS_FOUND
- RESULTS: ScriptResult[]

## Entity: ScriptResult
- SCRIPT: string
- EXIT_CODE: int
- STATUS: PASS|FAIL

Rule: JSON 模式输出必须是单个可解析对象。
