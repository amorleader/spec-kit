# Session Handoff - 2026-03-09

## Scope Clarification

- Goal is to productize `spec-kit` workflow capability, not deploy the MHR sample as business output.
- Target usage model:
  - Teammates use Web UI + chat-like interaction.
  - They can create their own projects from Web.
  - Each project/session must run in an isolated directory.
- Current phase is PoC/trial for internal recognition, not full enterprise governance.

## Key Decisions Agreed

1. Keep current `spec-kit` conventions and templates as default baseline.
2. Web side should expose a terminal/chat style interaction.
3. Backend does the heavy work on server:
   - Receive conversation input.
   - Drive `specify -> plan -> tasks` (then later `implement`).
   - Persist and visualize artifacts.
4. No strict auth/RBAC for first PoC round (internal-only usage).
5. Isolation is mandatory even in PoC:
   - Auto-allocate per-project/per-session workspace.
   - Never allow arbitrary path from frontend.

## Infrastructure Decisions

- Cloud server selected for PoC and external model access capability.
- Purchased server details:
  - Provider: Tencent Cloud
  - OS: Ubuntu 22.04 LTS
  - Public IP: `159.75.114.169`
  - Spec: 2 vCPU / 2 GB RAM / 50 GB SSD
- Service is reachable from local browser:
  - `http://159.75.114.169`

## Repository State Relevant to This Plan

- Active branch: `feature/portable-offline-bundle`
- Important existing commit on this branch:
  - `cd3032a` - embedded catalog + portable bundle scripts
- Tag already pushed for packaging baseline:
  - `portable-zip-v1`

## Suggested Next Implementation Milestones (PoC)

1. Session and workspace foundation:
   - `POST /api/sessions`
   - Create workspace root: `/srv/spec-kit/workspaces/{sessionId}`
2. Minimal chat-driven stage execution:
   - `POST /api/sessions/{id}/specify`
   - `POST /api/sessions/{id}/plan`
   - `POST /api/sessions/{id}/tasks`
3. Artifact read API:
   - `GET /api/sessions/{id}/artifacts`
4. Minimal frontend:
   - One input box (chat/terminal style)
   - Stage timeline panel
   - Artifact viewer (`spec.md`, `plan.md`, `tasks.md`)

## Operational Constraints for Next Iteration

- Keep all command execution pinned to workspace directory.
- Deny path traversal (`..`) and symbolic link escapes.
- Start with read + doc generation actions; gate code mutation actions behind confirmation.

## Fast Start Checklist for Company Laptop Tomorrow

1. Pull latest branch:
   - `git checkout feature/portable-offline-bundle`
   - `git pull`
2. Verify baseline service reachability:
   - Open `http://159.75.114.169`
3. Start implementing session APIs in backend.
4. Build a minimal frontend page for conversation + artifact display.
5. Demo flow target:
   - Input requirement -> produce `spec.md` -> refine -> `plan.md` -> `tasks.md`.
