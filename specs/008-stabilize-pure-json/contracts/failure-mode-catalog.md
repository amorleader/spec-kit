# Failure Mode Catalog: create-new-feature JSON purity

## Case A: JSON mode mixed output
- Trigger: JSON mode prints non-JSON lines.
- Expected: treated as contract violation.

## Case B: text mode loses action line
- Trigger: text mode missing `ACTION:`.
- Expected: treated as readability regression.

## Case C: missing required JSON fields
- Trigger: one or more required fields absent.
- Expected: parser contract failure.
