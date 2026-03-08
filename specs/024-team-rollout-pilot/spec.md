# Feature Specification: Team Rollout Pilot (Phase 6)

**Feature Branch**: `024-team-rollout-pilot`
**Created**: 2026-03-08
**Status**: Draft
**Input**: Continue from `023-java-team-tool-mvp` completed MVP and execute real teammate rollout validation.

## Summary

Run one real teammate docs-only pilot on a clean machine context, collect measurable friction data, and harden the workflow with a DB-backed reference path and troubleshooting guidance.

## Target User

- Primary: teammate who did not author the workflow
- Secondary: tech lead validating rollout readiness

## Scope (In/Out)

### In Scope

- One real teammate pilot run using existing docs and `scripts/team-pilot/*`
- Solo-proxy pilot mode when teammate is unavailable (author runs strictly docs-only with no ad-hoc shortcuts)
- Structured capture of timing, blockers, and clarifying questions
- Troubleshooting appendix for Windows setup issues (execution policy, PATH, JAVA_HOME, Maven command resolution)
- One DB-backed reference implementation for Demo B expense flow (JPA/Jdbc)
- Pilot report and go/no-go recommendation

### Out of Scope

- Full company-wide rollout
- Multi-team governance process
- Performance benchmarking at production scale
- Multi-environment deployment automation

## Functional Requirements

- FR1: Workflow must provide a teammate-run checklist that can be executed without live assistance.
- FR2: Pilot run must capture per-step time, success/failure, and blocker details.
- FR3: Troubleshooting appendix must include command-level fixes for known environment issues.
- FR4: Expense demo must have a DB-backed repository path validated by tests.
- FR5: Pilot report must include adoption decision and prioritized next actions.

## Non-Functional Requirements

- NFR1: Teammate pilot completion target is <= 90 minutes for first run.
- NFR2: All documented commands must be copy-paste runnable on Windows PowerShell.
- NFR3: Sensitive credentials must not be committed; only env-var patterns are allowed.
- NFR4: DB-backed path must keep current JSON API contracts stable.

## Acceptance Criteria

- AC1: At least one non-author teammate completes the full docs-only run; if unavailable, one solo-proxy docs-only run is completed with explicit constraints and evidence.
- AC2: Pilot log includes step durations, confusion points, and exact blockers.
- AC3: Troubleshooting appendix resolves all encountered blockers in the same session.
- AC4: DB-backed expense path passes `mvn -q -DskipTests=false test` and `mvn -q package`.
- AC5: Final rollout recommendation document exists with clear go/no-go and next-phase actions.

## Risks and Mitigations

- Risk: teammate machine setup differs significantly from author machine.
  - Mitigation: enforce preflight and provide absolute-path fallback commands.
- Risk: DB-backed implementation changes API behavior.
  - Mitigation: contract tests for key endpoints and boundary errors.
- Risk: pilot feedback is incomplete or anecdotal.
  - Mitigation: use structured template with mandatory fields and timestamps.
