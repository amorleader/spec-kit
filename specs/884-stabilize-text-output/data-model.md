# Data Model: Text Output Stability

## Entity: TextOutputLineSet
- ScriptName: string
- OrderedLines: string[]
- KeyLabels: string[]

## Entity: TextErrorHint
- Prefix: string
- Message: string
- Suggestion: string

## Entity: TextOutputCheckResult
- IsStable: bool
- MissingLabels: string[]
- UnexpectedLines: string[]

Rule: 文本模式输出必须包含并保持关键标签顺序稳定。