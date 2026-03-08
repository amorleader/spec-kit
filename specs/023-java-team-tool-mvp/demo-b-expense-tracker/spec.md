# Feature Specification: Demo B - Personal Expense Tracker MVP

## Summary

Build a Java web application for recording expense transactions and returning category-based summaries over a date range. The MVP emphasizes accurate totals, consistent JSON contracts, and reproducible delivery using the same workflow gates proven in Demo A.

## Target User

- Primary: individual users tracking personal expenses
- Secondary: team members validating reproducibility of the workflow

## Scope (In/Out)

### In Scope

- Java 11 + Spring Boot 2.7.x + Maven + PostgreSQL baseline
- Package root: `com.amor.speckit.mvp.expense`
- JSON APIs:
  - `GET /api/v1/categories`
  - `POST /api/v1/transactions`
  - `GET /api/v1/transactions?fromDate=&toDate=`
  - `GET /api/v1/summaries/by-category?fromDate=&toDate=`
- Core entities: ExpenseTransaction, ExpenseCategory, SummaryRequest, SummaryResult
- Basic web page for create/list/summary interactions
- Standardized JSON error output for validation failures

### Out of Scope

- Authentication and multi-user data isolation
- Budget threshold warning and notification features
- CSV import/export
- Advanced charting and analytics dashboards

## Functional Requirements

- FR1: System must create expense transactions with `amount`, `category`, `occurredAt`, and optional `note`.
- FR2: System must list transactions filtered by optional date range (`fromDate`, `toDate`).
- FR3: System must return category summary totals for a date range.
- FR4: Validation must enforce amount > 0, occurredAt not in future, category in allowed set, and fromDate <= toDate.
- FR5: API responses must follow JSON contracts for both success and error paths.
- FR6: Web UI must support transaction create, list refresh, and summary query.

## Non-Functional Requirements

- NFR1: Summary query must respond within 2 seconds on sample dataset.
- NFR2: First page load must be under 5 seconds in local environment.
- NFR3: Validation and unexpected errors must return sanitized JSON without stack trace leaks.
- NFR4: Build must produce runnable jar with Java 11 target.
- NFR5: Design must preserve layer boundaries: controller/service/repository/dto.

## Acceptance Criteria

- AC1: Given valid transaction request, API persists and returns a transaction payload with generated id.
- AC2: Given invalid amount (<= 0), API returns `VALIDATION_ERROR` with detail `field=amount` and `reason=out_of_range`.
- AC3: Given date range filters, list endpoint returns matching transactions only.
- AC4: Given date range filters, summary endpoint returns correct per-category totals and aggregate count.
- AC5: `mvn -q -DskipTests=false test` passes and reports are captured.
- AC6: `mvn -q package` produces runnable jar and runtime smoke checks pass.

## JSON Contract Expectations

### Create Transaction Request

```json
{
  "amount": 48.50,
  "category": "FOOD",
  "occurredAt": "2026-03-08",
  "note": "Dinner"
}
```

### Validation Error Response

```json
{
  "code": "VALIDATION_ERROR",
  "message": "amount must be greater than 0",
  "details": [{"field": "amount", "reason": "out_of_range"}]
}
```

## Risks and Mitigations

- Risk: aggregation logic drifts from list filtering logic.
  - Mitigation: add shared date-range filter helper and summary assertion tests.
- Risk: environment inconsistency causes false build failures.
  - Mitigation: run shell preflight (`mvn -v`, `java -version`) and explicit `JAVA_HOME` fallback.
- Risk: validation contract diverges due to framework defaults.
  - Mitigation: enforce explicit exception mapping for boundary fields and verify via integration tests.
