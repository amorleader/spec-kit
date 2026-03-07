# Tasks Template Constraints (Execution Plan)

## Required Structure

- Phase 1: Baseline/Setup
- Phase 2: Artifact Standardization
- Phase 3+: Delivery execution by story or workflow slice
- Final phase: polish and handoff

## Mandatory Rules

- Tasks must be ordered by dependency.
- Tasks must be action-oriented and verifiable.
- Every implementation task must have a validation task nearby.
- Must include explicit test command tasks and packaging task.
- Must include at least one reproducibility task (second run).

## Java-Specific Execution Rules

- Include task to confirm package structure (`com.amor.speckit.mvp.*`).
- Include task to verify JSON response behavior.
- Include task to run `mvn -q -DskipTests=false test`.
- Include task to run `mvn -q package` and jar smoke run.

## Completion Rules

- Task can be checked only when evidence exists (test output, build output, or document diff).
- Any failed task must have follow-up action before phase close.
- Phase cannot close with unchecked blocking tasks.
