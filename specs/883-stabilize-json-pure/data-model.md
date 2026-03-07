# Data Model: JSON Purity Contract

## Entity: JsonCommandResult
- ScriptName: string
- Status: string
- Payload: object
- Error: object|null

## Entity: JsonErrorPayload
- Code: string
- Message: string
- Details: string|null

## Entity: JsonPurityCheckResult
- IsPureJson: bool
- ParseSucceeded: bool
- ContaminationSource: string|null

Rule: 当 `-Json` 启用时，stdout 必须仅包含 `JsonCommandResult` JSON 文档。