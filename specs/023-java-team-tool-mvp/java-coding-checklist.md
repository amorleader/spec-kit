# Java Coding Checklist (MVP)

## Error Handling

- [ ] Global exception handler exists (`@RestControllerAdvice`).
- [ ] Validation errors return clear field-level messages.
- [ ] Boundary validation fields (for example `maxResults`) map to stable API contract (`code/message/details`).
- [ ] Business exceptions map to explicit HTTP status codes.
- [ ] Unexpected exceptions return sanitized error response (no stack trace leak).
- [ ] API responses are JSON for both success and error paths.

## Logging

- [ ] Use SLF4J (`log.info/warn/error`) with structured key context.
- [ ] Log request correlation id (if present) or generated trace id.
- [ ] Do not log sensitive values (password/token/full personal data).
- [ ] Error logs include actionable context and exception message.

## DTO Boundary

- [ ] Controller input/output uses DTOs, not JPA entities directly.
- [ ] DTO fields are validated with annotations.
- [ ] Mapping logic is isolated (manual mapper or mapper component).
- [ ] API contracts are backward-aware (avoid breaking field renames in MVP demo).

## Build/Test Gate

- [ ] Terminal preflight done in active shell (`mvn -v`, `java -version`).
- [ ] `mvn -q -DskipTests=false test` passed.
- [ ] `mvn -q package` passed.
- [ ] Jar starts with local profile and key endpoint smoke check passed.

## Review Gate

- [ ] New classes follow package/layer conventions.
- [ ] Methods have single clear responsibility.
- [ ] No obvious dead code or placeholder TODO in merged path.
