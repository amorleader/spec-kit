# Traceability Matrix

## User Story to Requirement Mapping

| User Story | Priority | Functional Requirements | Constitution Alignment | Planned Deliverables |
|---|---|---|---|---|
| US1: 完成可执行规格基线 | P1 | FR-001, FR-002, FR-003, FR-004 | CA-001, CA-003 | `spec.md` 完整化（故事/验收/需求/成功标准） |
| US2: 固化 CLI 契约与校验路径 | P2 | FR-005, FR-006 | CA-002, CA-004 | `contracts/*` 契约细化与映射矩阵 |
| US3: 交付可复现指南与证据 | P3 | FR-007 | CA-005 | `quickstart.md` + `evidence/*` 验收证据 |

## Artifact to Story Mapping

| Artifact | Story | Notes |
|---|---|---|
| specs/002-initialize-first-sample/spec.md | US1 | MVP 关键输入 |
| specs/002-initialize-first-sample/contracts/plan-cli-contract.md | US2 | 主契约文档 |
| specs/002-initialize-first-sample/contracts/prerequisite-check-contract.md | US2 | 前置检查契约 |
| specs/002-initialize-first-sample/contracts/setup-plan-output-schema.md | US2 | JSON 输出约束 |
| specs/002-initialize-first-sample/contracts/cli-verification-matrix.md | US2 | 命令与契约映射 |
| specs/002-initialize-first-sample/quickstart.md | US3 | 执行步骤与验收 |
| specs/002-initialize-first-sample/evidence/command-log.md | US3 | 执行证据 |
| specs/002-initialize-first-sample/evidence/readiness-report.md | US3 | 最终交付总结 |

## Notes
- 由于当前 `spec.md` 仍为模板，FR 编号在 US1 执行时将与最终内容同步修订。
- 本矩阵用于满足 Constitution 的可追踪性门禁要求。