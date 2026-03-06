# Failure Mode Catalog

## Scope
Covers failure behavior of `setup-plan.ps1` across default and force modes.

## Failure Modes

### 1) Readonly `plan.md`
- Trigger: `plan.md` exists but is not writable.
- Expected (default): preserve if no write needed; if write attempted, fail with actionable message.
- Expected (force): fail with non-zero exit code and permission guidance.

### 1.1) Existing plan without force
- Trigger: `plan.md` exists and command invoked without `-Force`.
- Expected: preserve existing content, action output includes `ACTION: preserved`.

### 1.2) Existing plan with force
- Trigger: `plan.md` exists and command invoked with `-Force`.
- Expected: overwrite from template (or empty fallback), action output includes `ACTION: overwritten`.

### 2) Missing template source
- Trigger: `.specify/templates/plan-template.md` absent in creation/overwrite path.
- Expected: fail with non-zero exit code and path-specific guidance.

### 3) Invalid working directory
- Trigger: repository markers not found or path resolution fails.
- Expected: fail with non-zero exit code and next-step hint.

### 4) JSON parse incompatibility risk
- Trigger: non-JSON noise mixed into JSON mode output.
- Expected: avoid mixed output in `-Json`; keep machine-parse stable.

## Expected Error Message Qualities
- Includes root cause keyword.
- Includes remediation next step.
- Distinguishes preserve/create/overwrite paths.
