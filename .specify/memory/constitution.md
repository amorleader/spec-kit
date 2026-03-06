<!--
Sync Impact Report
- Version change: 0.0.0-template → 1.0.0
- Modified principles:
	- Placeholder Principle 1 → I. Spec-Driven Delivery
	- Placeholder Principle 2 → II. CLI-First Contracts
	- Placeholder Principle 3 → III. Test-First Quality Gates (NON-NEGOTIABLE)
	- Placeholder Principle 4 → IV. Contract & Integration Assurance
	- Placeholder Principle 5 → V. Simplicity, Observability, and Version Discipline
- Added sections:
	- Engineering Standards
	- Workflow & Review Gates
- Removed sections:
	- None
- Templates requiring updates:
	- ✅ updated: .specify/templates/plan-template.md
	- ✅ updated: .specify/templates/spec-template.md
	- ✅ updated: .specify/templates/tasks-template.md
	- ⚠ pending: .specify/templates/commands/*.md (directory not present in this workspace)
- Deferred follow-up TODOs:
	- None
-->

# Spec Kit Constitution

## Core Principles

### I. Spec-Driven Delivery
Every change MUST start from an explicit specification that defines prioritized user
stories, measurable success criteria, and acceptance scenarios. Implementation work
MUST trace back to approved specification artifacts (`spec.md`, `plan.md`, `tasks.md`).
Rationale: clear traceability reduces rework and keeps delivery aligned to user value.

### II. CLI-First Contracts
All automation and tool capabilities MUST be invocable via a deterministic CLI surface.
Commands MUST support non-interactive use, return machine-readable output where needed,
and write errors to stderr with actionable messages. Rationale: CLI contracts preserve
repeatability across local, CI, and agent-driven execution.

### III. Test-First Quality Gates (NON-NEGOTIABLE)
Behavior-changing work MUST begin with failing tests that define expected outcomes
before implementation. Contributors MUST follow a red-green-refactor loop and MUST NOT
merge code that lacks tests for new or changed behavior. Rationale: test-first delivery
prevents regressions and proves requirements are met.

### IV. Contract & Integration Assurance
Any change to interfaces, shared schemas, or cross-component workflows MUST include
contract and integration coverage at the affected boundaries. Unit tests alone are
insufficient for cross-boundary behavior. Rationale: most production failures occur at
integration points, so boundary validation is mandatory.

### V. Simplicity, Observability, and Version Discipline
Designs MUST choose the simplest solution that satisfies current requirements, and any
added complexity MUST be justified in the plan's complexity tracking section. Runtime
flows MUST emit structured diagnostics sufficient to debug failures. Public behavior
changes MUST use semantic versioning with explicit impact notes for breaking changes.
Rationale: simplicity improves maintainability, observability improves operability, and
version discipline prevents unexpected consumer breakage.

## Engineering Standards

- Canonical artifacts are `.specify` templates and generated spec folders; ad hoc
	process documents MUST NOT override constitution rules.
- Feature plans MUST document language, dependencies, constraints, and performance goals
	before implementation begins.
- Security- and data-impacting requirements MUST be explicit in specs, including failure
	modes and edge cases.
- Automation scripts and generated outputs MUST remain cross-environment friendly and
	avoid hidden interactive assumptions.

## Workflow & Review Gates

1. Specification Gate: `spec.md` includes prioritized stories, independent test paths,
	 functional requirements, and measurable success criteria.
2. Planning Gate: `plan.md` passes Constitution Check and records complexity exceptions.
3. Tasking Gate: `tasks.md` maps tasks to user stories, includes test tasks first for
	 behavior changes, and preserves independent story delivery.
4. Implementation Gate: code changes maintain CLI contract behavior and include required
	 unit, contract, and integration coverage.
5. Review Gate: pull request review MUST verify constitutional compliance and version
	 impact notes before approval.

## Governance

This constitution is the highest-priority engineering policy for this repository.
Amendments MUST be proposed in writing, include rationale and migration impact, and be
approved by maintainers before merge.

Versioning policy:
- MAJOR: incompatible principle or governance changes, or removal/redefinition of a
	core principle.
- MINOR: new principle/section or materially expanded mandatory guidance.
- PATCH: clarifications, wording improvements, and non-semantic refinements.

Compliance review expectations:
- Every feature plan and pull request MUST include an explicit constitution check.
- Non-compliant changes MUST be blocked until remediated or formally exempted with
	documented justification.
- Periodic audits MAY be run against templates and automation to ensure continued
	alignment.

**Version**: 1.0.0 | **Ratified**: 2026-03-06 | **Last Amended**: 2026-03-06
