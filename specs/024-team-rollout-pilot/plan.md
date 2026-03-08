# Implementation Plan: Team Rollout Pilot (Phase 6)

**Branch**: `024-team-rollout-pilot`
**Date**: 2026-03-08
**Spec**: `specs/024-team-rollout-pilot/spec.md`

## Goal

Validate team adoption readiness with one real teammate docs-only run (or solo-proxy fallback when teammate is unavailable) and lock a repeatable MHR validation path for rollout.

## Workflow Architecture

1. Pilot Prep
- Freeze current docs and scripts from 023.
- Prepare teammate-run packet and run log template.

2. Pilot Execution
- Teammate executes preflight/build/package/smoke sequence using docs only.
- Fallback: author executes strict solo-proxy run with the same command pack and run-log evidence.
- Capture times, questions, and blockers live in template.

3. Troubleshooting Hardening
- Convert encountered blockers into deterministic fix recipes.
- Append recipes to shared troubleshooting appendix.

4. MHR Validation Reference
- Confirm stable MHR contract checks for catalog/build endpoints.
- Keep MHR DTO and API contracts unchanged.

5. Verification and Recommendation
- Run tests/package/smoke with MHR mode.
- Publish rollout recommendation and next actions.

## Technical Decisions

- Keep stack baseline: Java 11 target, Spring Boot 2.7.x, Maven.
- Keep existing endpoint contracts unchanged.
- Prefer explicit smoke and contract checks over ad-hoc manual validation.
- Preserve script-first teammate operation for pilot repeatability.

## Deliverables

- `specs/024-team-rollout-pilot/spec.md`
- `specs/024-team-rollout-pilot/plan.md`
- `specs/024-team-rollout-pilot/tasks.md`
- `specs/024-team-rollout-pilot/teammate-run-packet.md`
- `specs/024-team-rollout-pilot/teammate-run-log-template.md`
- `specs/024-team-rollout-pilot/solo-proxy-run-log.md`
- `specs/024-team-rollout-pilot/pilot-success-metrics.md`
- `specs/024-team-rollout-pilot/troubleshooting-appendix.md`
- `specs/024-team-rollout-pilot/pilot-result-report.md`

## Quality Gates

- Gate 1: Pilot readiness gate
  - Teammate packet and logging template are complete.

- Gate 2: Pilot execution gate
  - One non-author teammate run completed with structured evidence, or one solo-proxy run completed with explicit fallback note.

- Gate 3: Engineering gate
  - MHR validation path passes test, package, and smoke commands.

- Gate 4: Rollout decision gate
  - Final recommendation and prioritized backlog are documented.

## Rollout Strategy

1. Execute one teammate pilot run.
2. Resolve blockers into docs/scripts.
3. Validate MHR reference path.
4. Decide go/no-go for broader team rollout.
