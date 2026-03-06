# Quickstart: Recover Missing Specs Directory

## Scenarios
1. 当前分支已存在但 specs 目录缺失
   - 运行：`powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/create-new-feature.ps1 -Json -Number 6 "recover missing specs"`
   - 期望：脚本成功，补齐 `specs/006-.../spec.md`。

2. 当前分支已存在且 spec.md 已存在
   - 重复运行同命令
   - 期望：脚本成功，不覆盖已有 `spec.md`。

3. 目标分支已存在但非当前分支
   - 在其它分支运行同编号命令
   - 期望：脚本切换到目标分支并继续恢复。
