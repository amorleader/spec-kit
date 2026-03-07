# Contract: setup-plan JSON Output Purity

## JSON Mode
- Command: `setup-plan.ps1 -Json`
- Expected stdout: pure JSON only.
- Required fields: `FEATURE_SPEC`, `IMPL_PLAN`, `SPECS_DIR`, `BRANCH`, `HAS_GIT`.

## Text Mode
- Command: `setup-plan.ps1`
- Expected stdout: includes `ACTION:` text.

## Compatibility
- JSON field names and semantics unchanged.

## Example JSON Output
```json
{"FEATURE_SPEC":"<repo>/specs/009-setup-plan-json-purity/spec.md","IMPL_PLAN":"<repo>/specs/009-setup-plan-json-purity/plan.md","SPECS_DIR":"<repo>/specs/009-setup-plan-json-purity","BRANCH":"009-setup-plan-json-purity","HAS_GIT":true}
```

## Traceability (Docs -> Behavior)
- `quickstart.md` JSON step -> pure JSON parseability
- `quickstart.md` text step -> ACTION line preservation
- `failure-mode-catalog.md` -> mixed-output and text-action regressions

## Final Validation Record
- Command: `powershell -ExecutionPolicy Bypass -File tests/setup_plan_json_output_regression.ps1`
- Exit code: 0
- Result: `setup_plan_json_output_regression: PASSED`
- Command: `powershell -ExecutionPolicy Bypass -File tests/validate_setup_plan_json_output_docs.ps1`
- Exit code: 0
- Result: `validate_setup_plan_json_output_docs: PASSED`
