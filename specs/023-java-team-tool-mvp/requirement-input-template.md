# Requirement Input Template (Business Request)

Use this template as the only accepted input format for MVP runs.

## 1. Basic Context

- Request title:
- Request source: (customer / product manager / internal)
- Target release date:
- Priority: (P0/P1/P2)

## 2. Business Goal

- What business outcome is expected?
- How do we measure success? (1-3 measurable metrics)

## 3. Target User and Scenario

- Who will use this feature?
- Main usage scenario (step-by-step, short flow)

## 4. Functional Scope

- Must-have capabilities (MVP):
- Out-of-scope for this iteration:

## 5. Data and Domain Rules

- Core entities involved:
- Required fields:
- Validation/business rules:

## 6. API Expectations (JSON)

- Required endpoints:
- Request/response examples (JSON):
- Error response expectations (JSON):

## 7. Non-Functional Constraints

- Performance constraints:
- Security/compliance constraints:
- Compatibility constraints:

## 8. Technical Defaults (for this project)

- Java: 11
- Spring Boot: 2.7.x
- Build: Maven
- Database: PostgreSQL
- Package root: `com.amor.speckit.mvp`
- Delivery: runnable jar

## 9. Acceptance and Handoff

- UAT acceptance criteria:
- Required demos/evidence:
- Known risks and assumptions:
