# Failure Mode Catalog: JSON Warning Purity

## Case A: long-name warning pollutes JSON
- Trigger: branch truncation warning in JSON mode.
- Expected after fix: warning suppressed in JSON mode.

## Case B: warning disappears in text mode
- Trigger: non-JSON mode has no warning in truncation scenario.
- Expected after fix: warning remains visible.

## Evidence
- Command: `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_warning_stream_regression.ps1`
- Result: `create_new_feature_warning_stream_regression: PASSED`
- Verified text scenario: output contains both `WARNING:` and `ACTION:` lines.
