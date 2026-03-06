# Data Model: Branch Number Selection

## Entity: BranchCandidate
- name (string)
- numericPrefix (string)
- isThreeDigitFeature (bool)

## Entity: NumberingResult
- selectedNumber (int)
- sourceMaxBranch (int)
- sourceMaxSpecDir (int)

Rule: Only candidates matching `^\d{3}-` contribute to automatic numbering.
