# Research: Existing Branch Recovery in create-new-feature

## Decision 1: Allow recovery when target branch already exists
- Decision: 若目标分支已存在且当前可切换到该分支，则继续创建缺失 `specs/<branch>/spec.md`。
- Rationale: 解决流程阻断，同时保持幂等恢复。

## Decision 2: Preserve existing spec content
- Decision: 仅在 `spec.md` 不存在时复制模板，存在时不覆盖。
- Rationale: 避免破坏已编辑规格。

## Decision 3: Keep output contract unchanged
- Decision: `-Json` 仍输出 `BRANCH_NAME/SPEC_FILE/FEATURE_NUM/HAS_GIT`。
- Rationale: 兼容现有调用方。

## Finalized After Implementation
- existing branch + current branch: 已支持恢复缺失目录与 `spec.md`。
- existing branch + non-current branch: 已支持 checkout 后恢复。
- existing `spec.md`: 保持内容不覆盖。
