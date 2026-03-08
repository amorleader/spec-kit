# Next-Phase Prioritized Backlog

Date: 2026-03-08
Scope: follow-up backlog after Phase 6 pilot (`024-team-rollout-pilot`)

## Priority 0 (Release Gate)

1. Run one non-author teammate docs-only execution and capture structured log evidence.
- Why: this is the only unmet condition for broad rollout.
- Done when: one full run log and one summarized findings section are added under `specs/024-team-rollout-pilot/`.

## Priority 1 (High Impact)

2. Add one-click Windows wrapper for execution-policy bypass + team pilot command chain.
- Why: repeated friction in pilot flow came from command setup steps.
- Done when: wrapper script and docs usage examples are added and validated.

3. Add dedicated MHR smoke script wrapper to command pack.
- Why: MHR path is the primary rollout baseline and should be easy to re-verify.
- Done when: scripted start + API smoke + teardown path is documented and runnable.

## Priority 2 (Stability)

4. Strengthen MHR build API test coverage for edge constraints and max-results boundaries.
- Why: protect core build-generation contract under rollout changes.
- Done when: additional regression tests pass in CI/local runs.

5. Add rollback guidance for quickstart and script-command mismatches.
- Why: safe fallback path reduces pilot interruption when docs drift occurs.
- Done when: docs include exact rollback commands and verification checkpoints.

## Priority 3 (Scale Readiness)

6. Prepare team onboarding checklist for Java/Maven local prerequisites.
- Why: reduce support overhead as pilot audience grows.
- Done when: checklist maps to preflight scripts and common fix recipes.

7. Define lightweight telemetry fields for future pilot runs.
- Why: make adoption blockers quantifiable over time.
- Done when: teammate run log template includes optional telemetry section with 3-5 fields.

## Suggested Execution Order

1. P0 item 1.
2. P1 items 2-3.
3. P2 items 4-5.
4. P3 items 6-7.
