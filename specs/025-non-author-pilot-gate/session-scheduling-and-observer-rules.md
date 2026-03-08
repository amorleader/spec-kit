# Session Scheduling And Observer Rules

Date: 2026-03-08
Scope: `P003` for `025-non-author-pilot-gate`

## Session Scheduling

- Session ID: `non-author-pilot-session-01`
- Target window: 2026-03-11 14:00-15:30 (UTC+8)
- Buffer window: 2026-03-12 10:00-11:30 (UTC+8)
- Duration budget: 90 minutes
- Location: remote screen share + shared run log editing

## Roles

- Runner (non-author): executes all steps strictly from frozen packet.
- Observer (maintainer): records timestamps/interventions and does not guide unless blocked.
- Optional reviewer: validates evidence completeness after session.

## Pre-Session Checklist

- Runner has repository access and local clone ready.
- Runner can open PowerShell and run local scripts.
- Frozen packet reference confirmed:
  - `specs/025-non-author-pilot-gate/run-packet-freeze.md`
- Run log file prepared:
  - `specs/025-non-author-pilot-gate/non-author-run-log-session-01.md`

## Observer Rules (Strict)

1. Observer must stay silent during normal execution.
2. Observer may intervene only if runner explicitly asks for help or execution is blocked for over 5 minutes.
3. Every intervention must be logged with:
- timestamp
- trigger condition
- exact guidance provided
- outcome
4. Observer cannot modify code/scripts/docs during the session.
5. Any deviation from frozen command sequence must be recorded as friction.

## Intervention Thresholds

- Soft threshold: 2 minutes confusion without command execution progress (log only, no guidance).
- Hard threshold: 5 minutes blocked with no progress (guidance allowed, must log intervention).
- Emergency threshold: environment failure that prevents any command execution (guidance allowed immediately, must log root cause and fallback).

## Session Success Criteria

- All required steps attempted using frozen command sequence.
- Run log fields fully filled, including evidence snippets.
- Pass/fail and blocker severity classification completed by end of session.

## Output Artifacts

- `specs/025-non-author-pilot-gate/non-author-run-log-session-01.md`
- `specs/025-non-author-pilot-gate/non-author-pilot-report.md`
