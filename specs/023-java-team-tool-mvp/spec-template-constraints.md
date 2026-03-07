# Spec Template Constraints (Java Service MVP)

## Required Sections

- Summary
- Target User
- Scope (In/Out)
- Functional Requirements
- Non-Functional Requirements
- Acceptance Criteria
- Risks and Mitigations

## Mandatory Rules

- Must align with `requirement-input-template.md` sections.
- Must include explicit JSON contract expectations.
- Must state stack assumptions: Java 11, Spring Boot 2.7.x, Maven, PostgreSQL.
- Must define at least 3 acceptance criteria that are testable.
- Must separate MVP scope from out-of-scope items.

## Java-Specific Constraints

- Must reference package root `com.amor.speckit.mvp`.
- Must describe layer boundaries (controller/service/repository/dto).
- Must avoid implementation details in spec (no class-level coding plan).

## Quality Checks

- Requirements are atomic and unambiguous.
- No conflicting statements across sections.
- Every acceptance criterion can map to test evidence.
