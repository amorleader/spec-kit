# Data Model: Branch Restore State

## Entity: BranchSnapshot
- HasGitRepo: bool
- OriginalBranch: string|null

## Entity: RestoreResult
- Attempted: bool
- Restored: bool
- Message: string

Rule: `OriginalBranch` 非空且当前分支变化时必须尝试恢复。
