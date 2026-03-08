# P004 Live Execution Runbook (Minute-by-Minute)

Date prepared: 2026-03-08
Applies to: `non-author-pilot-session-01`
Primary references:
- `specs/025-non-author-pilot-gate/run-packet-freeze.md`
- `specs/025-non-author-pilot-gate/non-author-run-log-session-01.md`
- `specs/025-non-author-pilot-gate/session-scheduling-and-observer-rules.md`

## Session Objective

Complete one non-author docs-only run for preflight/build/package/smoke and collect auditable evidence for `P004-P006`.

## Timebox (90 min)

- 00-10 min: kickoff + environment confirmation
- 10-25 min: preflight
- 25-55 min: build and package
- 55-75 min: app start + smoke check
- 75-90 min: evidence consolidation + quick debrief

## Host Script (Observer)

Use these lines verbatim at session start:

1. "今天我们执行非作者 docs-only 试跑，我不会主动指导，除非你明确求助或卡住超过 5 分钟。"
2. "我们只用冻结命令序列，不改脚本、不改文档。"
3. "任何偏离、疑问、报错都要写进 run log，并标注时间。"

## Frozen Commands (Must Use)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
pwsh ./scripts/team-pilot/01_preflight.ps1
pwsh ./scripts/team-pilot/02_build_and_package.ps1
# Start application jar in a new terminal before smoke check
pwsh ./scripts/team-pilot/03_smoke_check.ps1 -Mode mhr -BaseUrl http://localhost:8080
```

## Minute-by-Minute Checklist

### 00-10 min: Kickoff

- Confirm runner/observer names in run log.
- Confirm machine summary (OS/Java/Maven/Git).
- Confirm packet freeze reference and no live edits rule.
- Start screen recording or capture terminal screenshots policy.

### 10-25 min: Preflight

- Runner executes preflight command.
- Observer logs step start/end and pass/fail.
- If command fails, classify severity and wait per threshold before intervention.

Expected evidence:
- java version output
- maven version output
- `[preflight] OK`

### 25-55 min: Build and Package

- Runner executes build/package command.
- Observer logs retries and exact error text if present.
- If blocked >5 min, intervention allowed and must be logged.

Expected evidence:
- test success summary
- package success summary
- `[build] Done`

### 55-75 min: App Start + Smoke

- Runner starts jar in a separate terminal.
- Runner executes smoke check command.
- Observer records whether MHR smoke passes and any contract mismatch behavior.

Observer minimum checklist (must record in run log):

- `GET /api/v1/skills` -> expected HTTP 200 and non-empty list.
- `POST /api/v1/builds/generate` -> expected HTTP 200 and valid build response.
- `GET /` -> expected HTTP 200.
- Smoke output contains `[smoke] OK`.

Expected evidence:
- smoke endpoint calls completed
- `[smoke] OK`

### 75-90 min: Evidence Closure

- Fill run outcome section in session log.
- Ensure blockers table has severity and resolution.
- Capture 3 key snippets: preflight/build/smoke.
- Draft 3 bullet findings for report input.

## Intervention Protocol (Do Not Skip)

- 0-2 min confusion: log only, no guidance.
- 2-5 min no progress: ask runner to restate issue, still no direct fix.
- >5 min blocked: guidance allowed, log timestamp + guidance + outcome.
- Emergency (cannot execute any command): immediate intervention allowed, must log root cause.

## Evidence Quality Gate

Session is not considered complete until all are true:

- Step Log has start/end/duration/result for all 3 steps.
- At least one output snippet per major step.
- Any intervention has complete metadata (time, trigger, guidance, outcome).
- Run outcome section fully filled.

## Quick Debrief Prompts

Ask runner these 4 questions at end:

1. "最不确定的一步是哪个，为什么？"
2. "哪条文档说明最容易误解？"
3. "如果给新人只留一条建议，会是什么？"
4. "这套流程是否可在无人协助下复现？"
