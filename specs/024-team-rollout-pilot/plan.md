# Implementation Plan: Team Rollout Pilot (Phase 6)

**Branch**: `024-team-rollout-pilot`
**Date**: 2026-03-08
**Spec**: `specs/024-team-rollout-pilot/spec.md`

## Goal

Validate team adoption readiness with one real teammate docs-only run and remove the largest technical limitation by adding a DB-backed reference implementation for expense flow.

## Workflow Architecture

1. Pilot Prep
- Freeze current docs and scripts from 023.
- Prepare teammate-run packet and run log template.

2. Pilot Execution
- Teammate executes preflight/build/package/smoke sequence using docs only.
- Capture times, questions, and blockers live in template.

3. Troubleshooting Hardening
- Convert encountered blockers into deterministic fix recipes.
- Append recipes to shared troubleshooting appendix.

4. DB-Backed Reference
- Replace expense in-memory repository with DB-backed implementation path.
- Keep DTO and API contracts unchanged.

5. Verification and Recommendation
- Run tests/package/smoke with DB-backed mode.
- Publish rollout recommendation and next actions.

## Technical Decisions

- Keep stack baseline: Java 11 target, Spring Boot 2.7.x, Maven, PostgreSQL.
- Keep existing endpoint contracts unchanged.
- Prefer simple JDBC/JPA path with clear repository boundary.
- Preserve script-first teammate operation for pilot repeatability.

## Deliverables

- `specs/024-team-rollout-pilot/spec.md`
- `specs/024-team-rollout-pilot/plan.md`
- `specs/024-team-rollout-pilot/tasks.md`
- `specs/024-team-rollout-pilot/teammate-run-packet.md`
- `specs/024-team-rollout-pilot/teammate-run-log-template.md`
- `specs/024-team-rollout-pilot/pilot-success-metrics.md`
- `specs/024-team-rollout-pilot/troubleshooting-appendix.md`
- `specs/024-team-rollout-pilot/pilot-result-report.md`

## Quality Gates

- Gate 1: Pilot readiness gate
  - Teammate packet and logging template are complete.

- Gate 2: Pilot execution gate
  - One non-author teammate run completed with structured evidence.

- Gate 3: Engineering gate
  - DB-backed implementation passes test and package commands.

- Gate 4: Rollout decision gate
  - Final recommendation and prioritized backlog are documented.

## Rollout Strategy

1. Execute one teammate pilot run.
2. Resolve blockers into docs/scripts.
3. Validate DB-backed reference path.
4. Decide go/no-go for broader team rollout.
