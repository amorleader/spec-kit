# Demo Comparison: Demo A vs Demo B

## Purpose

Compare artifacts and execution outcomes between Demo A (MHR Build Planner) and Demo B (Expense Tracker) to identify process drift and required template hardening.

## Scope Compared

- Input artifact quality (`request/spec/plan/tasks`)
- Implementation path (layering and package conventions)
- Validation contract consistency
- Test/build/package/runtime evidence
- Environment friction points

## Summary Verdict

- Reproducibility: PASSED
- Major drift: NONE blocking delivery
- Minor drift: 2 items (bootstrap scan strategy, test context discovery)

## Comparison Matrix

1. Artifact completeness
- Demo A: complete (`request/spec/plan/tasks/acceptance/reproducibility/template-refinements`)
- Demo B: complete (`request/spec/plan/tasks/acceptance` + comparison)
- Drift: none

2. Stack and gates
- Demo A: Java 11 target, Spring Boot 2.7.x, Maven, PostgreSQL assumptions; test/package/runtime gates passed
- Demo B: same stack and gates passed
- Drift: none

3. JSON error contract
- Demo A: `maxResults` boundary mapped to stable JSON contract
- Demo B: `amount` boundary mapped to stable JSON contract
- Drift: none (contract mapping pattern validated reusable)

4. Runtime smoke coverage
- Demo A: skills/build generate/UI route checks
- Demo B: categories/transactions/summary/boundary error/UI route checks
- Drift: none

5. Codebase integration
- Demo A package: `com.amor.speckit.mvp.mhr`
- Demo B package: `com.amor.speckit.mvp.expense`
- Observed drift: when adding second feature package, Spring component scanning and test bootstrap assumptions can break if bootstrap class location is too narrow.

## Drift Findings

- D1: Bootstrap package scan coupling
  - Symptom: Expense controller test initially could not discover Spring Boot configuration.
  - Fix applied: widen scan base package to `com.amor.speckit.mvp` and set explicit classes in test where needed.

- D2: Template lacked explicit multi-package bootstrap rule
  - Symptom: second feature addition required ad-hoc scan/test bootstrap correction.
  - Fix direction: codify bootstrap and test-context requirements in quickstart/checklist/plan constraints.

## Evidence Paths

- Demo A acceptance: `specs/023-java-team-tool-mvp/demo-a-mhr-build-planner/acceptance-notes.md`
- Demo B acceptance: `specs/023-java-team-tool-mvp/demo-b-expense-tracker/acceptance-notes.md`
- Demo A reproducibility notes: `specs/023-java-team-tool-mvp/demo-a-mhr-build-planner/reproducibility-notes.md`

## Conclusion

Demo B successfully reproduced the full workflow with a different business case and confirmed the process is transferable. Remaining improvements are template-level hardening, not flow blockers.
