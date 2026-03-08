# Demo B Acceptance Notes

## Current Status

Completed for Demo B MVP baseline.

## Captured Evidence

1. Test reports:
  - `target/surefire-reports/TEST-com.amor.speckit.mvp.expense.controller.ExpenseControllerTest.xml`
  - `target/surefire-reports/TEST-com.amor.speckit.mvp.expense.service.ExpenseServiceTest.xml`
2. Build artifact:
  - `target/mhr-build-planner-0.0.1-SNAPSHOT.jar`
3. Runtime smoke checks:
  - `GET /api/v1/categories` returned 5 categories
  - `POST /api/v1/transactions` created record id=1
  - `GET /api/v1/summaries/by-category?fromDate=2026-03-01&toDate=2026-03-31` returned FOOD total 48.50
  - Boundary validation (`amount=0`) returned:
    - `code=VALIDATION_ERROR`
    - `message=amount must be greater than 0`
    - `details[0]={field:amount, reason:out_of_range}`
  - `GET /expense.html` returned HTTP 200

## Known Gaps

- Repository currently uses in-memory storage for MVP speed; SQL schema/seed is prepared for later DB-backed repository replacement.
