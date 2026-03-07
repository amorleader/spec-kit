# Quickstart: Validate setup-plan Regression Mode Separation

1. 运行主回归：
   - `powershell -ExecutionPolicy Bypass -File tests/setup_plan_regression.ps1`
2. 期望：
   - existing/missing/force 三场景全部通过。
3. 运行 JSON 纯净回归：
   - `powershell -ExecutionPolicy Bypass -File tests/setup_plan_json_output_regression.ps1`
4. 期望：
   - JSON 纯净与文本 ACTION 断言均通过。
