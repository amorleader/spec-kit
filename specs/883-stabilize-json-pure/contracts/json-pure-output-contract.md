# Contract: JSON Pure Output for PowerShell Scripts

## Scope
- `.specify/scripts/powershell/check-prerequisites.ps1`
- `.specify/scripts/powershell/setup-plan.ps1`
- `.specify/scripts/powershell/create-new-feature.ps1`

## Success Path Contract
- `-Json` mode outputs exactly one valid JSON document on stdout.
- No informational or warning text is emitted to stdout in `-Json` mode.

## Failure Path Contract
- `-Json` mode failure returns structured JSON object with stable core fields.
- Exit code remains non-zero for failures.

## Compatibility Contract
- Existing CLI arguments remain unchanged.
- Non-JSON mode behavior remains unchanged.