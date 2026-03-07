# Java Layer Conventions (MVP)

## Package Structure

Use one root package and fixed layer folders:

- `com.amor.speckit.mvp.controller`
- `com.amor.speckit.mvp.service`
- `com.amor.speckit.mvp.repository`
- `com.amor.speckit.mvp.domain` (entity/aggregate)
- `com.amor.speckit.mvp.dto`
- `com.amor.speckit.mvp.mapper` (if mapping logic grows)
- `com.amor.speckit.mvp.config`
- `com.amor.speckit.mvp.exception`

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
- Response format is JSON.
- Prefer a consistent JSON envelope for success and error responses.
- Validation uses Bean Validation annotations with `@Valid`.

## Transaction Rules

- Writes: annotate service methods with `@Transactional`.
- Reads: use `@Transactional(readOnly = true)` when needed.

## Test Placement

- Unit tests mirror package path under `src/test/java`.
- Integration tests suffixed with `IT` or explicit category label.
