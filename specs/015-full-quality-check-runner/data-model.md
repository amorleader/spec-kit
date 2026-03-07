# Data Model: Quality Check Aggregate Result

## Entity: ScriptExecutionResult
- Script: string
- ExitCode: int
- Status: PASS|FAIL

## Entity: AggregateSummary
- TotalScripts: int
- FailedCount: int
- FailureList: ScriptExecutionResult[]

Rule: `FailedCount > 0` 时聚合脚本返回非 0。
