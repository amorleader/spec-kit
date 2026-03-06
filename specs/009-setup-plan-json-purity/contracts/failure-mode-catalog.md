# Failure Mode Catalog: setup-plan JSON purity

## Case A: JSON mode mixed output
- Trigger: JSON mode contains non-JSON lines.
- Expected: parser failure and regression test failure.

## Case B: text mode missing ACTION
- Trigger: text mode no longer prints action.
- Expected: regression failure.
