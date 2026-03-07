# Java Stack Baseline (MVP)

## Scope

This baseline defines the default stack for the first runnable MVP demo.

## Runtime

- JDK: 17 (LTS)
- Spring Boot: 3.x
- Build Tool: Maven (wrapper preferred)
- Packaging: executable jar

## Data Layer

- Database: MySQL 8.x
- Migration: Flyway (recommended for team phase)
- Local profile: `local` with standalone DB connection

## Core Dependencies

- `spring-boot-starter-web`
- `spring-boot-starter-validation`
- `spring-boot-starter-data-jpa`
- `mysql-connector-j`
- `spring-boot-starter-test`

## Build and Verification Commands

- Unit/integration tests:
  - `mvn -q -DskipTests=false test`
- Package executable jar:
  - `mvn -q package`
- Run locally:
  - `java -jar target/<artifact>.jar --spring.profiles.active=local`

## Baseline Non-Functional Targets (MVP)

- Startup succeeds under local profile.
- Core CRUD API responds correctly.
- Build + tests + package can run on a clean machine with JDK 17 + Maven.

## Constraints

- Do not add distributed components in MVP (no Kafka/Redis required by default).
- Keep module structure single-service for first demo.
- External integrations should be mocked unless explicitly required.
