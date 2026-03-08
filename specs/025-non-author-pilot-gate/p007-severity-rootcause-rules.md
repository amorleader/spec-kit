# P007 Severity And Root Cause Rules

Use this file to classify each friction item from session logs in a consistent way.

## Severity Rules

### Critical

Apply when any condition is true:
- Blocks completion of a required step with no workaround in-session.
- Causes incorrect or unsafe outcome that invalidates pilot evidence.
- Requires code change before next pilot can continue.

### High

Apply when any condition is true:
- Blocks progress for more than 10 minutes but can be bypassed with maintainer help.
- Causes repeated failure (>2 retries) in core command path.
- Produces ambiguous outcome that requires manual verification to trust results.

### Medium

Apply when any condition is true:
- Causes confusion or one-time retry but run can proceed.
- Documentation is unclear but recoverable via existing troubleshooting guidance.
- Tooling friction increases time but does not threaten completion.

### Low

Apply when any condition is true:
- Cosmetic or wording issues with no operational impact.
- Minor convenience improvements with no effect on correctness.

## Root Cause Taxonomy

Classify each item using one primary root cause code:

- `ENV_PATH`: Java/Maven/PATH environment setup mismatch.
- `DOC_CLARITY`: Docs wording/order unclear for first-time runner.
- `SCRIPT_BEHAVIOR`: Script behavior or output not intuitive.
- `COMMAND_DRIFT`: Runbook command differs from actual required command.
- `SERVICE_STARTUP`: Application startup timing/port/process issues.
- `API_CONTRACT`: Endpoint payload/status differs from expected contract.
- `OBSERVER_PROCESS`: Observer rule not followed or intervention logging missing.

## Classification Table

| Item ID | Symptom | Duration(min) | Retries | Severity | Root Cause Code | Evidence Ref |
|---|---|---:|---:|---|---|---|
| F-001 |  |  |  |  |  |  |
| F-002 |  |  |  |  |  |  |

## Escalation Rules

- Any `Critical` item -> create immediate P0 remediation action.
- Two or more `High` items in one run -> keep recommendation at `CONDITIONAL GO`.
- Any `API_CONTRACT` item -> require explicit re-test after fix before closure.
