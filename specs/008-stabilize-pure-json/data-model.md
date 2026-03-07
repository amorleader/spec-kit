# Data Model: create-new-feature Output Modes

## Entity: CreateFeatureJsonResult
- `BRANCH_NAME` (string)
- `SPEC_FILE` (string)
- `FEATURE_NUM` (string)
- `HAS_GIT` (bool)

Rule: JSON mode stdout must be a single JSON object.

## Entity: CreateFeatureTextOutput
- `ACTION` (string)
- key-value text lines

Rule: text mode preserves action-oriented readability.
