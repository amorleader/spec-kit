# Data Model: Runner Timeout Execution

## Entity: ScriptRunResult
- Script: string
- ExitCode: int
- Status: PASS | FAIL | TIMEOUT
- TimedOut: bool
- DurationSec: number
- Output: string

## Entity: TimeoutSummary
- TotalScripts: int
- FailedScripts: int
- PassedScripts: int
- TimedOutScripts: int
- Results: ScriptRunResult[]

Rule: `TimedOut == true` 时，`Status` 必须为 `TIMEOUT` 且 `ExitCode` 视为失败。
