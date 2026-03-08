# Demo B Request: Personal Expense Tracker (MVP)

## 1. Basic Context

- Request title: Personal Expense Tracker (MVP)
- Request source: Internal demo requirement
- Target release date: 2026-04-15
- Priority: P1

## 2. Business Goal

Provide a simple web app for recording daily expense transactions and showing category-based spending summaries, so users can understand where money goes without manual spreadsheet work.

### Success Metrics

1. User can add one expense record in under 1 minute.
2. Summary endpoint returns category totals accurately for a date range.
3. First page load time is under 5 seconds in local environment.

## 3. Target User and Scenario

### Target User

Individual users tracking personal expenses.

### Main Scenario

1. User opens page and enters amount, category, date, and optional note.
2. User submits transaction.
3. User selects date range and views summary by category.
4. User can list recent transactions for verification.

## 4. Functional Scope

### Must Have (MVP)

1. Transaction create/list APIs.
2. Category summary API by date range.
3. Validation for amount/date/category.
4. Simple web page for add/list/summary.
5. JSON responses with standardized error structure.

### Out of Scope

1. Authentication and multi-user isolation.
2. Budget warning rules and notifications.
3. CSV import/export.
4. Complex analytics charts.

## 5. Data and Domain Rules

### Core Entities

1. ExpenseTransaction
2. ExpenseCategory
3. SummaryRequest
4. SummaryResult

### Required Fields

- ExpenseTransaction: id, amount, category, occurredAt, note
- ExpenseCategory: code, label
- SummaryRequest: fromDate, toDate
- SummaryResult: categoryTotals, totalAmount, transactionCount

### Validation Rules

1. amount must be greater than 0.
2. occurredAt cannot be in the future.
3. category must be from allowed category set.
4. fromDate must be <= toDate.

## 6. API Expectations (JSON)

### Required Endpoints

1. GET /api/v1/categories
2. POST /api/v1/transactions
3. GET /api/v1/transactions?fromDate=&toDate=
4. GET /api/v1/summaries/by-category?fromDate=&toDate=

### Example Request

```json
{
  "amount": 48.50,
  "category": "FOOD",
  "occurredAt": "2026-03-08",
  "note": "Dinner"
}
```

### Example Error Response

```json
{
  "code": "VALIDATION_ERROR",
  "message": "amount must be greater than 0",
  "details": [{"field": "amount", "reason": "out_of_range"}]
}
```

## 7. Non-Functional Constraints

- Performance: summary query response under 2 seconds for sample dataset.
- Security: no auth for MVP, sanitize error output.
- Compatibility: Java 11, Spring Boot 2.7.x, Maven, PostgreSQL.

## 8. Technical Defaults

- Java: 11
- Spring Boot: 2.7.x
- Build: Maven
- Database: PostgreSQL
- Package root: com.amor.speckit.mvp.expense
- Delivery: runnable jar

## 9. Acceptance and Handoff

### UAT Criteria

1. User can create transaction from page and see it in list.
2. Summary endpoint returns correct totals by category.
3. Validation errors follow standardized JSON contract.
4. Packaged jar starts and serves page plus APIs locally.

### Required Evidence

1. Screen recording: create transaction and view summary.
2. API call evidence (Postman or curl).
3. Test report and jar build evidence.

### Risks and Assumptions

1. Sample data only; not production-scale benchmark.
2. Single-user assumptions for MVP.
