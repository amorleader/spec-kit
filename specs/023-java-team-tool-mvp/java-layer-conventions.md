# Java Layer Conventions (MVP)

## Package Structure

Use one root package and fixed layer folders:

- `com.<org>.<app>.controller`
- `com.<org>.<app>.service`
- `com.<org>.<app>.repository`
- `com.<org>.<app>.domain` (entity/aggregate)
- `com.<org>.<app>.dto`
- `com.<org>.<app>.mapper` (if mapping logic grows)
- `com.<org>.<app>.config`
- `com.<org>.<app>.exception`

## Layer Responsibilities

- Controller:
  - Handle HTTP contract, validation annotations, response mapping.
  - No business logic.
- Service:
  - Orchestrate business rules and transaction boundaries.
  - Return domain result or DTO per module guideline.
- Repository:
  - Data access only.
  - No business branching logic.
- DTO:
  - External API request/response contracts.
  - Avoid exposing entity internals.

## Naming Rules

- Controller: `<Resource>Controller`
- Service interface: `<Resource>Service`
- Service impl: `<Resource>ServiceImpl`
- Repository: `<Resource>Repository`
- Request DTO: `<Action><Resource>Request`
- Response DTO: `<Resource>Response`

## API Conventions

- REST path style: `/api/v1/<resources>`
- Return object uses consistent envelope in team phase (MVP can keep direct payload with clear error schema).
- Validation uses `jakarta.validation` annotations and `@Valid`.

## Transaction Rules

- Writes: annotate service methods with `@Transactional`.
- Reads: use `@Transactional(readOnly = true)` when needed.

## Test Placement

- Unit tests mirror package path under `src/test/java`.
- Integration tests suffixed with `IT` or explicit category label.
