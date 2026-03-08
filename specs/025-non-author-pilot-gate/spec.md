# Feature Specification: Non-Author Pilot Gate (Phase 7)

**Feature Branch**: `025-non-author-pilot-gate`
**Created**: 2026-03-08
**Status**: Draft
**Input**: Execute backlog P0 from `024-team-rollout-pilot`: run one real non-author docs-only pilot and close rollout gate.

## Summary

Complete one full docs-only run by a non-author teammate, capture structured evidence, and convert findings into a final rollout decision update.

## Target User

- Primary: teammate who did not author or modify the workflow
- Secondary: maintainer deciding broader rollout readiness

## Scope (In/Out)

### In Scope

- One real non-author docs-only run using existing packet and scripts
- Structured logging of step duration, confusion points, and blockers
- Evidence consolidation into a single audit trail
- Update rollout decision after reviewing non-author evidence

### Out of Scope

- Rebuilding team pilot scripts from scratch
- New feature development outside adoption gate closure
- Production deployment automation

## Functional Requirements

- FR1: Provide a fixed, no-assistance execution path for the non-author runner.
- FR2: Capture command-level evidence for preflight, build/package, and smoke checks.
- FR3: Record all friction and map each issue to a mitigation action (doc/script/troubleshooting).
- FR4: Publish a final decision update based on non-author run evidence.

## Non-Functional Requirements

- NFR1: Commands must remain copy-paste runnable in Windows PowerShell.
- NFR2: Evidence must be reproducible and timestamped.
- NFR3: No credentials are committed; only env-var patterns are allowed.

## Acceptance Criteria

- AC1: One non-author teammate completes end-to-end docs-only run with structured log.
- AC2: Evidence file includes commands executed, durations, and pass/fail results.
- AC3: All discovered blockers have an owner and a concrete remediation action.
- AC4: Final rollout recommendation is updated to GO or CONDITIONAL GO with explicit criteria.

## Risks and Mitigations

- Risk: teammate environment differs and fails preflight.
  - Mitigation: enforce preflight first and capture exact environment outputs.
- Risk: data quality is weak due to incomplete logs.
  - Mitigation: use required fields and do not accept partial templates.
- Risk: feedback is ambiguous.
  - Mitigation: force each friction item to include severity and remediation owner.
