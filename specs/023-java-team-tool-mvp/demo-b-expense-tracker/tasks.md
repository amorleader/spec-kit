# Tasks: Demo B - Personal Expense Tracker MVP

## Phase 1 - Baseline and Artifact Setup

- [ ] B001 Validate active shell preflight (`mvn -v`, `java -version`).
- [ ] B002 Confirm package structure under `com.amor.speckit.mvp.expense`.
- [ ] B003 Finalize `spec.md` and `plan.md` alignment with request.
- [ ] B004 Add SQL schema/seed scripts for categories and transactions.

## Phase 2 - Domain and API Foundation

- [ ] B005 Implement domain model for category and transaction.
- [ ] B006 Implement DTOs and validation rules (amount/date/category/date-range).
- [ ] B007 Implement repository layer for create/list and summary queries.
- [ ] B008 Implement controllers for:
  - `GET /api/v1/categories`
  - `POST /api/v1/transactions`
  - `GET /api/v1/transactions?fromDate=&toDate=`
  - `GET /api/v1/summaries/by-category?fromDate=&toDate=`

## Phase 3 - Summary and Contract Validation

- [ ] B009 Implement summary aggregation by category and totals.
- [ ] B010 Implement global exception mapping for stable JSON contract.
- [ ] B011 Add boundary validation mapping checks (for example `amount <= 0`).
- [ ] B012 Implement simple web page for create/list/summary interactions.

## Phase 4 - Verification and Packaging

- [ ] B013 Add API integration tests for happy path and boundary errors.
- [ ] B014 Add service tests for aggregation correctness.
- [ ] B015 Run `mvn -q -DskipTests=false test` and capture evidence.
- [ ] B016 Run `mvn -q package` and confirm jar output.
- [ ] B017 Run jar smoke checks for categories/transactions/summary/UI.
- [ ] B018 Record Demo B acceptance notes and known gaps.

## Phase 5 - Reproducibility Comparison Input

- [ ] B019 Produce Demo A vs Demo B comparison snapshot inputs for T018.
- [ ] B020 Propose draft template/checklist adjustment candidates for T019.
