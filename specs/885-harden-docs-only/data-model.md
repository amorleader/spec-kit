# Data Model: Docs-Only Aggregate

## Entity: DocsOnlySummary
- TotalScripts: int
- PassedScripts: int
- FailedScripts: int
- TimedOutScripts: int
- IncludeDocsOnly: bool
- Status: string

## Entity: DocsOnlyResultItem
- Script: string
- ExitCode: int
- Status: string
- TimedOut: bool

## Entity: DocsOnlyRegressionResult
- JsonParseable: bool
- FieldCompatible: bool
- ScriptCountMatches: bool

Rule: docs-only 模式下 `RESULTS` 必须只包含 docs validators。