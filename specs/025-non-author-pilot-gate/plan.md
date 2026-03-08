# Implementation Plan: Non-Author Pilot Gate (Phase 7)

**Branch**: `025-non-author-pilot-gate`
**Date**: 2026-03-08
**Spec**: `specs/025-non-author-pilot-gate/spec.md`

## Goal

Close the last rollout gate by obtaining one complete non-author teammate run with high-quality evidence and converting that evidence into a final rollout decision update.

## Workflow Architecture

1. Pilot Readiness Freeze
- Reuse existing packet/templates from 024 without workflow drift.
- Lock command sequence for the run session.

2. Non-Author Execution
- Teammate executes preflight, package, and smoke sequence docs-only.
- Maintainer observes silently and only logs intervention requests.

3. Evidence Consolidation
- Collect timings, failures, retries, and confusion points in one file.
- Attach command snippets and exact error text where present.

4. Hardening and Decision Update
- Convert friction into remediation backlog with owners and priorities.
- Update rollout recommendation with explicit GO criteria.

## Technical Decisions

- Keep existing scripts and docs as the source of truth.
- Keep MHR validation path as validated baseline from 024.
- Prioritize evidence quality over speed of run completion.

## Deliverables

- `specs/025-non-author-pilot-gate/spec.md`
- `specs/025-non-author-pilot-gate/plan.md`
- `specs/025-non-author-pilot-gate/tasks.md`
- `specs/025-non-author-pilot-gate/non-author-run-log.md`
- `specs/025-non-author-pilot-gate/non-author-pilot-report.md`

## Quality Gates

- Gate 1: Readiness gate
  - Runner packet and log template are finalized and unchanged during run.

- Gate 2: Execution gate
  - Non-author completes docs-only run with full evidence fields.

- Gate 3: Decision gate
  - Recommendation updated with GO/CONDITIONAL GO and unresolved risks.

## Rollout Strategy

1. Schedule and execute one non-author session.
2. Resolve highest-severity friction immediately in docs/scripts.
3. Publish final recommendation and next backlog.
