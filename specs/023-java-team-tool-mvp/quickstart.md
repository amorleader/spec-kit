# Quickstart: Java Team Tool MVP

## 1) Provide requirement input

Use this minimum input:

- Business goal
- Target user
- Core workflow
- Required outputs
- Constraints (security, performance, delivery date)

## 2) Generate design artifacts

Produce and review in order:

1. `spec.md`
2. `plan.md`
3. `tasks.md`

Do not start coding before tasks are approved.

## 3) Implement with gate checks

Follow tasks sequentially.

Mandatory checks:

- `mvn -q -DskipTests=false test`
- `mvn -q package`

## 4) Verify runnable package

Example run command:

```bash
java -jar target/<app-name>.jar
```

Validate:

- app starts
- health endpoint responds
- key CRUD flow works

## 5) Capture handoff artifacts

- Acceptance summary
- Known limitations
- Follow-up backlog
