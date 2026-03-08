# Pilot Success Metrics and Thresholds

## Metrics

1. Docs-only completion
- Definition: teammate finishes full run without live verbal help.
- Threshold: PASS if completed end-to-end once.

2. Total completion time
- Definition: start at first preflight command, end at final smoke check.
- Threshold: PASS if <= 90 minutes.

3. Blocker count
- Definition: issues that stop progress for more than 5 minutes.
- Threshold: PASS if <= 2 blockers.

4. Unresolved blocker count
- Definition: blockers not resolved within same session.
- Threshold: PASS if 0.

5. Script usability
- Definition: team command pack scripts run with documented commands.
- Threshold: PASS if all 3 scripts execute successfully.

6. Contract confidence
- Definition: MHR build/catalog contract check matches documented API behavior.
- Threshold: PASS if MHR smoke checks return expected success payloads and status codes.

## Pilot Decision Rule

- GO: all thresholds pass.
- CONDITIONAL GO: only one non-critical threshold fails and mitigation is documented.
- NO-GO: any unresolved blocker or two or more failed thresholds.

## Required Inputs

- `specs/024-team-rollout-pilot/teammate-run-log-template.md`
- script outputs from `scripts/team-pilot/*`
- troubleshooting notes from run session
