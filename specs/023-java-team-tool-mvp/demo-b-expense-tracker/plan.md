# Implementation Plan: Demo B - Personal Expense Tracker MVP

## Goal

Execute the second end-to-end run with a different business case to validate reproducibility of the Java Team Tool workflow while delivering a runnable expense-tracker MVP.

## Workflow Architecture

1. Input normalization
- Source requirement: `specs/023-java-team-tool-mvp/demo-b-expense-tracker/request.md`
- Confirm scope and acceptance criteria from `spec.md` before coding.

2. Service design
- Layers under package root `com.amor.speckit.mvp.expense`:
  - `controller`: category/transaction/summary REST endpoints
  - `service`: validation, list filtering, summary aggregation logic
  - `repository`: transaction and category persistence
  - `dto`: API request/response contracts
  - `domain`: core entities and enums
  - `exception`: unified JSON error mapping

3. Data design
- PostgreSQL tables:
  - `expense_categories`
  - `expense_transactions`
- Migration strategy: MVP manual SQL scripts aligned with Demo A style.

4. Delivery flow
- Build artifacts: `request/spec/plan/tasks`
- Implement endpoints and UI
- Run tests and package gates
- Perform runtime smoke checks with explicit contract boundary verification

## Technical Decisions

- Java: 11 target
- Spring Boot: 2.7.x
- Build tool: Maven
- Database: PostgreSQL
- JSON strategy: DTO-first contracts with validation annotations
- Error handling strategy: global exception handler with stable `code/message/details`
- Test strategy: service and controller tests for validation and aggregation correctness
- External integrations: none

## Deliverables

- `specs/023-java-team-tool-mvp/demo-b-expense-tracker/request.md`
- `specs/023-java-team-tool-mvp/demo-b-expense-tracker/spec.md`
- `specs/023-java-team-tool-mvp/demo-b-expense-tracker/plan.md`
- `specs/023-java-team-tool-mvp/demo-b-expense-tracker/tasks.md`
- `specs/023-java-team-tool-mvp/demo-b-expense-tracker/acceptance-notes.md`
- Source code under `src/main/java/com/amor/speckit/mvp/expense/**`
- SQL scripts under `docs/sql` or `src/main/resources/db/migration`

## Quality Gates

- Gate 1: Artifact gate
  - `request/spec/plan/tasks` complete and coherent.

- Gate 2: Engineering gate
  - Active shell preflight passes (`mvn -v`, `java -version`).
  - `mvn -q -DskipTests=false test` exits 0.

- Gate 3: Packaging gate
  - `mvn -q package` exits 0 and jar is generated.

- Gate 4: Runtime smoke gate
  - `GET /api/v1/categories` responds.
  - `POST /api/v1/transactions` responds and returns created record.
  - `GET /api/v1/summaries/by-category` returns expected aggregation.
  - Boundary validation request returns expected JSON contract.

## Rollout Strategy

1. Produce Demo B artifacts and execute implementation flow.
2. Compare Demo B artifacts and execution evidence against Demo A outputs.
3. Record drift and update reusable templates/checklists for T018/T019.
