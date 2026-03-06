# Data Model: Runner Regression Assertions

## Entity: JsonSummaryAssertion
- RequiredFields: [TOTAL_SCRIPTS, FAILED_SCRIPTS, PASSED_SCRIPTS, INCLUDE_DOCS_ONLY, ORIGINAL_BRANCH, RESULTS, STATUS]
- Parseable: bool

## Entity: TextSummaryAssertion
- HasRunBlock: bool
- HasPassBlock: bool
- HasFinalPassedLine: bool

## Entity: BranchStabilityAssertion
- BeforeBranch: string
- AfterBranch: string
- IsStable: bool

Rule: `IsStable` 必须为 true。
