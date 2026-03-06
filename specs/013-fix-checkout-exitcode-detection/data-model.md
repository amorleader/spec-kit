# Data Model: Checkout Recovery State

## Entity: BranchRecoveryState
- BranchName
- CreateBranchExitCode
- CheckoutExitCode
- Action (`created`, `recovered-current`, `recovered-checkout`)

Rule: 仅当当前 checkout 命令退出码为 0 时，才标记 `recovered-checkout`。

## Entity: FailureInjectionPattern
- TargetExpression: `$null = git checkout $branchName 2>$null`
- InjectedBehavior: `throw "checkout failed"`

Rule: 注入命中后必须导致非 0 退出码。
