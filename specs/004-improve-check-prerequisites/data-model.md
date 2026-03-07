# Data Model: check-prerequisites Output Consistency

## Entity: PrerequisiteResult
- Purpose: 表示一次 `check-prerequisites` 执行的结构化结果。
- Fields:
  - `featureDir` (string): 目标特性目录绝对路径。
  - `availableDocs` (string[]): 可选文档列表，允许为空数组。
  - `exitCode` (int): 进程退出码，成功为 0，失败非 0。
  - `errorMessage` (string|null): 失败时可操作错误信息。
- Invariants:
  - JSON 模式下必须可反序列化。
  - `availableDocs` 不可为 null。

## Entity: CheckInvocation
- Purpose: 描述调用参数上下文。
- Fields:
  - `requireTasks` (bool)
  - `includeTasks` (bool)
  - `cwd` (string)
- Rules:
  - `requireTasks=true` 时，缺失任务文件必须失败。
  - `includeTasks=true` 时，若任务存在需体现在 `availableDocs`。
