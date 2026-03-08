# Implementation Plan: Demo A - Monster Hunter Rise Build Planner MVP

## Goal

Implement Demo A end-to-end using the standardized workflow artifacts, producing a runnable jar that serves JSON APIs and a simple web page for build generation.

## Workflow Architecture

1. Input normalization
- Source requirement file: `specs/023-java-team-tool-mvp/demo-a-mhr-build-planner/request.md`
- Confirm scope and acceptance criteria before coding.

2. Service design
- Layers under package root `com.amor.speckit.mvp.mhr`:
  - `controller`: REST endpoints
  - `service`: build generation and validation logic
  - `repository`: equipment/skill lookup and optional result persistence
  - `dto`: request/response objects
  - `domain`: entities and enums
  - `exception`: business and validation exception mapping

3. Data design
- PostgreSQL tables (MVP sample scale):
  - `skills`
  - `equipments`
  - `equipment_skill_points`
  - optional `build_results` if result persistence is enabled
- Migration strategy: manual SQL scripts for MVP baseline.

4. Build generation flow
- Validate request (`weaponType`, target skill range, `maxResults`).
- Query candidate equipment by weapon type and part.
- Compose candidate sets by unique armor part constraint.
- Aggregate skill totals + slot summary.
- Filter by minimum skill targets.
- Score and sort results.
- Return top N by `maxResults`.

5. Presentation flow
- Simple web page with request form and result table/details.
- Frontend calls `POST /api/v1/builds/generate` and renders JSON response.

6. Verification and packaging
- Run unit and integration tests.
- Run Maven package and jar smoke startup.

## Technical Decisions

- Java: 11
- Spring Boot: 2.7.x
- Build tool: Maven
- Database: PostgreSQL
- JSON strategy: Jackson default mapping with explicit DTO validation annotations
- Error handling strategy: global exception handler with standardized JSON error body
- Test strategy: JUnit 5 + Spring Boot Test + focused service tests for generator rules
- External integrations: none; all data local to MVP database seed scripts

## Deliverables

- `specs/023-java-team-tool-mvp/demo-a-mhr-build-planner/request.md`
- `specs/023-java-team-tool-mvp/demo-a-mhr-build-planner/spec.md`
- `specs/023-java-team-tool-mvp/demo-a-mhr-build-planner/plan.md`
- `specs/023-java-team-tool-mvp/demo-a-mhr-build-planner/tasks.md`
- `specs/023-java-team-tool-mvp/demo-a-mhr-build-planner/acceptance-notes.md`
- `specs/023-java-team-tool-mvp/demo-a-mhr-build-planner/reproducibility-notes.md`
- `specs/023-java-team-tool-mvp/demo-a-mhr-build-planner/template-refinements.md`
- Source code under `src/main/java/com/amor/speckit/mvp/mhr/**`
- SQL baseline under `src/main/resources/db/migration` or `docs/sql`
- Test evidence summary in demo acceptance notes

## Quality Gates

- Gate 1: Artifact gate
  - `request/spec/plan/tasks` are complete, coherent, and aligned.

- Gate 2: JSON contract gate
  - Endpoints return expected JSON structure including validation errors.

- Gate 3: Test gate
  - `mvn -q -DskipTests=false test` exits 0 with report evidence.

- Gate 4: Packaging gate
  - `mvn -q package` exits 0 and produces runnable jar.

- Gate 5: Runtime gate
  - `java -jar target/<artifact>.jar` starts and serves UI + APIs.

## Rollout Strategy

1. Implement Demo A using sample dataset and deterministic scoring.
2. Capture evidence for UAT and known limitations.
3. Feed lessons learned into template/checklist updates before Demo B.
