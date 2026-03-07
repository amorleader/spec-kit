# Contract: setup_plan_regression Mode Expectations

## Text Mode Assertions
- existing plan: output must match `ACTION: preserved`
- missing plan: output must match `ACTION: created`
- force overwrite: output must match `ACTION: overwritten`

## JSON Mode Assertions
- output must include parseable JSON payload
- required fields remain:
  - FEATURE_SPEC
  - IMPL_PLAN
  - SPECS_DIR
  - BRANCH
  - HAS_GIT

## Evidence
- `powershell -ExecutionPolicy Bypass -File tests/setup_plan_regression.ps1`
- `powershell -ExecutionPolicy Bypass -File tests/setup_plan_json_output_regression.ps1`
