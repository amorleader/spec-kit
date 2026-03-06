# Data Model: setup-plan Regression Invocation Modes

## Entity: TextInvocation
- Args: default or `-Force`
- Expected: contains `ACTION:` line

## Entity: JsonInvocation
- Args: `-Json` (+ optional `-Force`)
- Expected: parseable JSON with fields
  - FEATURE_SPEC
  - IMPL_PLAN
  - SPECS_DIR
  - BRANCH
  - HAS_GIT

Rule: 文本断言与 JSON 断言必须分离执行。
