# Data Model: Porcelain-Z Snapshot Entries

## Entity: PorcelainZEntry
- StatusCode: string
- Paths: string[]
- IsUntracked: bool

## Entity: WorkspaceSnapshot
- TrackedPaths: string[]
- UntrackedPaths: string[]

## Entity: RecoveryResult
- RevertedTrackedPaths: string[]
- DeletedTempPaths: string[]

Rule: 当 `StatusCode` 包含 rename/copy 语义时，`Paths` 必须包含 old/new 两个路径。
