# Data Model: Regression Context Binding

## Entity: RegressionContext
- PreviousSpecifyFeature: string/null
- TargetFeature: string (`004-improve-check-prerequisites`)

Rule: 执行结束后，`SPECIFY_FEATURE` 必须恢复为 `PreviousSpecifyFeature`。

## Entity: FailureAssertions
- MissingPlanExitCode: non-zero
- MissingPlanMessage: contains `plan.md not found`
- MissingTasksExitCode: non-zero
- MissingTasksMessage: contains `tasks.md not found`
