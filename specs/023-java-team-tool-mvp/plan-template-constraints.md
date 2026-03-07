# Plan Template Constraints (Java Service MVP)

## Required Sections

- Goal
- Workflow Architecture
- Technical Decisions
- Deliverables
- Quality Gates
- Rollout Strategy

## Mandatory Rules

- Must map directly to spec requirements.
- Must capture architecture choices for Java 11 + Spring Boot 2.7.x.
- Must include JSON API strategy and error-handling approach.
- Must include test gate and packaging gate (`mvn test`, `mvn package`).
- Must include deployment/run command for jar.

## Data and Integration Constraints

- Must document PostgreSQL usage assumptions.
- Must define migration strategy (default/manual SQL for MVP).
- Must identify external integrations and mocking approach.

## Deliverable Constraints

- Must produce artifact list with concrete file paths.
- Must include a team-readable acceptance summary output.

## Quality Checks

- No unresolved "NEEDS CLARIFICATION" placeholders before implementation.
- Technical decisions are compatible with JDK 11.
- All gates have clear pass/fail criteria.
