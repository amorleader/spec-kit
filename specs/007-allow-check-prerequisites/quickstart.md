# Quickstart: PathsOnly on Non-feature Branches

1. 在非 feature 分支运行（例如 `master`）
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -PathsOnly -Json`
   - 期望：成功返回路径 JSON。

2. 同环境运行普通模式
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -Json`
   - 期望：non-zero 失败，提示 feature 分支校验信息。

3. 文本模式验证
   - `powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -PathsOnly`
   - 期望：成功输出 `REPO_ROOT/BRANCH/FEATURE_DIR/...`。
