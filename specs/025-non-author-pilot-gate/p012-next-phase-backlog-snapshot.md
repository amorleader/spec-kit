# P012 Next-Phase Backlog Snapshot

Date: 2026-03-08
Source decision: `specs/025-non-author-pilot-gate/p011-rollout-decision-onepager.md`

## Snapshot Rules

- Include only actions not completed in this cycle.
- Prioritize by impact on rollout reliability.
- Keep each action measurable and owner-assigned.

## Priority Table

| Priority | Action | Owner | Due Date | Success Metric | Dependency |
|---|---|---|---|---|---|
| P0 | Complete one true non-author docs-only run with full evidence capture. | project maintainer | 2026-03-31 | Run log + report complete, no unresolved High/Critical blockers | session scheduling |
| P1 | Add non-`pwsh` fallback command examples in team pilot docs. | Docs Owner | 2026-03-10 | Smoke script runs successfully using current PowerShell host instructions | docs update |
| P1 | Make execution-policy bypass step mandatory and prominent across run packet and quickstart. | Docs Owner | 2026-03-10 | First-time runner completes scripts without policy-related stop | docs update |
| P2 | Add preflight host capability check for `pwsh` availability in pilot guidance. | Script Owner | 2026-03-14 | Preflight guidance routes runner to compatible command path automatically | docs/script alignment |
| P3 | Extend onboarding checklist with common Windows PowerShell pitfalls. | Docs Owner | 2026-03-20 | New checklist referenced in pilot packet and troubleshooting appendix | checklist refresh |

## Suggested Default Items

1. Complete unresolved High/Critical pilot findings.
2. Harden script/doc drift checks for MHR command pack.
3. Add regression checks for MHR build contract boundaries.
4. Improve onboarding checklist for first-time teammate execution.

## Publication Checklist

- Backlog entries map to findings in pilot report.
- Every P0/P1 item has owner and due date.
- Snapshot is linked in final team update message.
