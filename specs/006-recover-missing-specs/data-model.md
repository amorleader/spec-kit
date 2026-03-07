# Data Model: Branch Recovery Context

## Entity: BranchRecoveryContext
- `targetBranch` (string)
- `currentBranch` (string)
- `branchExists` (bool)
- `featureDirExists` (bool)
- `specFileExists` (bool)

## Entity: FeatureScaffoldResult
- `branchName` (string)
- `specFile` (string)
- `featureNum` (string)
- `hasGit` (bool)
- `action` (string: created/preserved/recovered)
