# Data Model: setup-plan Output Modes

## Entity: SetupPlanJsonResult
- FEATURE_SPEC (string)
- IMPL_PLAN (string)
- SPECS_DIR (string)
- BRANCH (string)
- HAS_GIT (bool)

Rule: JSON mode stdout must be single parseable JSON object.

## Entity: SetupPlanTextOutput
- ACTION line
- optional human-readable info lines

Rule: text mode retains ACTION message.
