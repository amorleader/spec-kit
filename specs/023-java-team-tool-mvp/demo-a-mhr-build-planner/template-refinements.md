# Template and Checklist Refinements from Demo A

## Goal

Document concrete refinements discovered from Demo A to reduce quality drift in later runs.

## Refinement 1: Add Environment Preflight Gate

Problem:
- Maven and Java were installed but not available in every shell/task context.

Refinement:
- Quickstart must include an explicit environment preflight section:
  - verify `mvn -v`
  - verify `java -version`
  - provide fallback with explicit `JAVA_HOME` and absolute Maven path

Expected impact:
- Reduces false build failures caused by terminal context mismatch.

## Refinement 2: Strengthen Validation Contract Rule

Problem:
- Bean validation may return generic error text, causing contract mismatch.

Refinement:
- Coding checklist and gate checklist must require explicit mapping for boundary fields (for example `maxResults`) to stable error contract (`code/message/details`).

Expected impact:
- Prevents regressions between controller validation and documented API contract.

## Refinement 3: Enforce Secret-Free Runtime Config

Problem:
- Hardcoded DB credentials are risky for team reuse.

Refinement:
- Local profile examples must use environment variables and avoid committed secrets.

Expected impact:
- Improves safety and makes teammate onboarding repeatable.

## Refinement 4: Runtime Smoke Checklist Granularity

Problem:
- Generic smoke check wording is too broad.

Refinement:
- Require explicit smoke checks:
  - `GET /api/v1/skills`
  - `POST /api/v1/builds/generate`
  - boundary validation request (`maxResults=21`)
  - root UI HTTP 200

Expected impact:
- Converts acceptance from subjective to reproducible command-level checks.

## Adoption Plan

1. Update `quickstart.md` with preflight and explicit smoke sequence.
2. Update `java-coding-checklist.md` with validation-contract boundary rule.
3. Update `contracts/mvp-gate-checklist.md` with preflight and runtime checklist details.
4. Reference this file in Demo B planning as baseline anti-drift guidance.
