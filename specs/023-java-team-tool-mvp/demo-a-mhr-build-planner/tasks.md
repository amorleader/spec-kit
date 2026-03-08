# Tasks: Demo A - Monster Hunter Rise Build Planner MVP

## Phase 1 - Baseline Setup

- [x] A001 Initialize Spring Boot project (Java 11, Maven, PostgreSQL profile).
- [x] A002 Confirm package structure under `com.amor.speckit.mvp.mhr`.
- [x] A003 Add MVP sample schema and seed SQL scripts.
- [x] A004 Add base error model and global exception handler for JSON errors.

## Phase 2 - API and Domain Foundation

- [x] A005 Implement domain entities and enums for Equipment, Skill, Charm, BuildRequest, BuildResult.
- [x] A006 Implement DTOs and validation rules (`maxResults` 1-20, skill range constraints).
- [x] A007 Implement repository queries for `GET /api/v1/skills` and equipment lookup.
- [x] A008 Implement controllers for:
  - `GET /api/v1/skills`
  - `GET /api/v1/equipments?part=&weaponType=`

## Phase 3 - Build Generation Slice

- [x] A009 Implement build generation service with unique part composition and skill aggregation.
- [x] A010 Implement request filtering by target skill minimums and optional charm constraints.
- [x] A011 Implement scoring and sorting strategy, then cap by `maxResults`.
- [x] A012 Implement `POST /api/v1/builds/generate` endpoint.
- [x] A013 Validate JSON response contract against spec examples.

## Phase 4 - Web UI and Validation

- [x] A014 Implement simple web page for input form and result rendering.
- [x] A015 Add build detail section with per-equipment skill contribution and slot summary.
- [x] A016 Add API-level tests for validation errors and happy path generation.
- [x] A017 Add service-level tests for part uniqueness and skill threshold rules.
- [x] A018 Run `mvn -q -DskipTests=false test` and capture evidence.

## Phase 5 - Packaging and Acceptance

- [x] A019 Run `mvn -q package` and confirm jar output.
- [x] A020 Run jar smoke test and verify UI/API availability.
- [x] A021 Record Demo A acceptance outcome and known issues.

## Phase 6 - Reproducibility Follow-Up

- [x] A022 Capture reproducibility notes for reuse in Demo B run.
- [x] A023 Propose template/checklist refinements based on Demo A drift.
