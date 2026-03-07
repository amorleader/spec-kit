# Overwrite Verification Notes

## Scope
Tracks expected behavior for `setup-plan.ps1` overwrite-related paths.

## Verification Targets
- Default mode with existing `plan.md` => preserved
- Default mode with missing `plan.md` => created
- Force mode with existing `plan.md` => overwritten

## Evidence Checklist
- [x] Existing plan fixture prepared (`tests/fixtures/setup-plan/existing-plan.md`)
- [x] Missing plan metadata prepared (`tests/fixtures/setup-plan/missing-plan.json`)
- [x] Command outputs captured in contract evidence file

## Traceability (Docs -> Behavior)
- `quickstart.md` default mode example -> `ACTION: preserved` behavior
- `quickstart.md` force mode example -> `ACTION: overwritten` behavior
- `setup-plan-safe-overwrite-contract.md` table -> missing/existing/readonly state transitions
- `command-evidence-template.md` -> reproducible command/exit/action proof

## Notes
- Any regression where default mode overwrites existing plan is a P1 failure.
