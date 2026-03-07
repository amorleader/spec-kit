# Contract: check-prerequisites JSON Output

## Command
`powershell -ExecutionPolicy Bypass -File .specify/scripts/powershell/check-prerequisites.ps1 -Json`

## Success Output (JSON)
- Required fields:
  - `FEATURE_DIR` (string, absolute path)
  - `AVAILABLE_DOCS` (array of string, may be empty)

### Example: Default mode
```json
{"FEATURE_DIR":"E:\\code\\spec-kit\\specs\\004-improve-check-prerequisites","AVAILABLE_DOCS":["research.md","data-model.md","contracts/","quickstart.md","tasks.md"]}
```

### Example: Empty optional docs mode
```json
{"FEATURE_DIR":"E:\\code\\spec-kit\\specs\\004-improve-check-prerequisites","AVAILABLE_DOCS":[]}
```

## Failure Behavior
- Exit code: non-zero
- Error output: human-readable message that identifies missing prerequisite or invalid state.

## Flag Semantics
- `-RequireTasks`: treat missing `tasks.md` as failure.
- `-IncludeTasks`: include `tasks.md` in `AVAILABLE_DOCS` when present.

## Compatibility Rules
- JSON top-level required fields must not be removed.
- `AVAILABLE_DOCS` must remain an array type for backward compatibility.

## US1 Evidence
- Command: `powershell -ExecutionPolicy Bypass -File tests/check_prerequisites_regression.ps1`
- Exit code: 0
- Assertions:
  - required fields present (`FEATURE_DIR`, `AVAILABLE_DOCS`)
  - `AVAILABLE_DOCS` remains array in default and include-tasks modes

## Traceability (Docs -> Behavior)
- `quickstart.md` default scenario -> stable JSON fields (`FEATURE_DIR`, `AVAILABLE_DOCS`)
- `quickstart.md` require-tasks scenario -> deterministic failure semantics for missing `tasks.md`
- `failure-mode-catalog.md` -> actionable errors and non-zero exit expectations

## Command Evidence Matrix
- Case A (default mode): `check-prerequisites.ps1 -Json` -> expected success JSON
- Case B (require tasks mode): `check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks` -> success when tasks exists
- Case C (missing plan): default mode with plan absent -> non-zero + actionable error
- Case D (missing tasks): require tasks mode with tasks absent -> non-zero + actionable error

## Final Validation Record
- Command: `powershell -ExecutionPolicy Bypass -File tests/check_prerequisites_regression.ps1`
- Exit code: 0
- Result: `check_prerequisites_regression: PASSED`
- Command: `powershell -ExecutionPolicy Bypass -File tests/validate_check_prerequisites_docs.ps1`
- Exit code: 0
- Result: `validate_check_prerequisites_docs: PASSED`
