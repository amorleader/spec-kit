# Data Model: Workspace Guard Recovery

## Entity: WorkspaceSnapshot
- TrackedPaths: string[]
- UntrackedPaths: string[]

## Entity: WorkspaceRecoverySummary
- RevertedTrackedCount: int
- DeletedTempFileCount: int
- SkippedExistingChanges: int

## Entity: ScriptRecoveryResult
- Script: string
- RecoveryApplied: bool
- RevertedTracked: string[]
- DeletedTempFiles: string[]

Rule: 仅允许恢复“执行后新增且执行前不存在”的变更项。
