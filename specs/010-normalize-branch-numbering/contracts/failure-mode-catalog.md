# Failure Mode Catalog: Numbering Rule

## Case A: polluted branch list causes jump
- Trigger: branch list contains `8034-*`.
- Expected after fix: ignored for auto-numbering.

## Case B: polluted specs directory causes jump
- Trigger: specs dir contains `8034-*` folder.
- Expected after fix: ignored for auto-numbering.

## Case C: manual number override breaks
- Trigger: `-Number` ignored.
- Expected: always honored.
