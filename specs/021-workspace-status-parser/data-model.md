# Data Model: Parsed Status Entry

## Entity: StatusEntry
- Code: string
- RawPath: string
- NormalizedPath: string
- Kind: Tracked | Untracked

## Entity: ParserRecoverySummary
- ParsedEntries: int
- RenameEntries: int
- RecoveryApplied: int

Rule: `RawPath` 包含 `->` 时，`NormalizedPath` 必须为右侧目标路径。
