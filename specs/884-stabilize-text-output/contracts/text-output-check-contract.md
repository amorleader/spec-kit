# Contract: Text Output Check Behavior

## Scope
- `.specify/scripts/powershell/check-prerequisites.ps1`
- `.specify/scripts/powershell/setup-plan.ps1`
- `.specify/scripts/powershell/create-new-feature.ps1`

## Success Text Contract
- Text mode outputs stable key-value labels.
- `ACTION:` and required summary labels remain present when applicable.

## Failure Text Contract
- Failure output includes consistent error heading and actionable hint.
- No unexpected debug/noise prefixes are emitted by default.

## Compatibility Contract
- CLI arguments remain unchanged.
- JSON mode behavior remains unchanged.