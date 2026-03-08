# P008 Remediation Mapping Template

Use this template to convert classified findings into actionable remediation work.

Input sources:
- `specs/025-non-author-pilot-gate/p007-severity-rootcause-rules.md`
- `specs/025-non-author-pilot-gate/non-author-run-log-session-01.md`
- `specs/025-non-author-pilot-gate/p005-p006-fast-close-template.md`

## Mapping Rules

- `Critical` -> Priority `P0`, due in 24-48h.
- `High` -> Priority `P1`, due in current sprint.
- `Medium` -> Priority `P2`, due next sprint.
- `Low` -> Priority `P3`, backlog candidate.

Owner mapping defaults:
- `ENV_PATH` -> Dev Environment Owner
- `DOC_CLARITY` -> Docs Owner
- `SCRIPT_BEHAVIOR` -> Script Owner
- `COMMAND_DRIFT` -> Docs + Script joint owner
- `SERVICE_STARTUP` -> Runtime Owner
- `API_CONTRACT` -> API Owner
- `OBSERVER_PROCESS` -> Pilot Facilitator

## Action Backlog Table

| Action ID | Source Item ID | Priority | Action Description | Owner | Due Date | Verification Step | Status |
|---|---|---|---|---|---|---|---|
| A-001 | F-001 | P0 |  |  |  |  | Todo |
| A-002 | F-002 | P1 |  |  |  |  | Todo |

## Verification Checklist

- Each action has a measurable verification step.
- Each P0/P1 action has explicit owner and due date.
- Each closed action has evidence link (log, command output, or doc diff).

## Ready-To-Close Criteria For P008

- All findings from P007 are mapped to actions.
- No `Critical`/`High` item is left without owner.
- Report `Remediation Actions` section is updated from this table.
