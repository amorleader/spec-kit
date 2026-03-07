# Failure Mode Catalog: create-new-feature Recovery

## Case A: Existing branch checkout fails
- Trigger: target branch exists but checkout fails
- Expected exit: non-zero
- Expected message: actionable checkout guidance

## Case B: Missing description
- Trigger: no description provided
- Expected exit: non-zero
- Expected message: usage + required description error

## Case C: Invalid repository root
- Trigger: repo root cannot be resolved
- Expected exit: non-zero
- Expected message: explicit repository root error

## US2 Evidence
- Command: `powershell -ExecutionPolicy Bypass -File tests/create_new_feature_recovery_regression.ps1`
- Exit code: 0
- Verified: non-current branch recovery success and checkout-failure path non-zero
