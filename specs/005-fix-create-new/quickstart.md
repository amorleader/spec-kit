# Quickstart: create-new-feature Argument Parsing

## Goal
验证 `create-new-feature.ps1` 在常见参数顺序下均可稳定解析并输出一致契约。

## Scenarios

1. 参数在前
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/create-new-feature.ps1 -Json "demo feature description"`
   - 期望：成功返回 JSON，包含 `BRANCH_NAME/SPEC_FILE/FEATURE_NUM/HAS_GIT`，且不输出 usage 错误。

2. 描述在前
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/create-new-feature.ps1 "demo feature description" -Json`
   - 期望：成功返回 JSON，字段与语义一致。

3. ShortName + Number 组合
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/create-new-feature.ps1 -Json -ShortName demo -Number 200 "demo feature description"`
   - 期望：使用指定编号与 shortName，生成分支前缀 `200-`，输出契约保持兼容。

4. 缺失描述文本
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/create-new-feature.ps1 -Json`
   - 期望：non-zero 退出并输出明确 usage/错误提示。

## Done Criteria
- 参数顺序不再触发误报 usage
- JSON 输出字段兼容
- 帮助与契约文档一致
