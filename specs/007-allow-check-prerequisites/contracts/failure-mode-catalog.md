# Failure Mode Catalog: PathsOnly Branch Validation

## Case A: normal mode on non-feature branch
- Expected: non-zero failure remains unchanged.

## Case B: require-tasks on non-feature branch in normal mode
- Expected: still non-zero failure due branch validation gate.

## Case C: paths-only mode on non-feature branch
- Expected: success with path output.
