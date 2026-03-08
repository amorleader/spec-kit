# Contract: MVP Gate Checklist

## Artifact Gate

- [ ] Requirement is clear and testable
- [ ] `spec.md` contains user stories and acceptance criteria
- [ ] `plan.md` contains architecture, data model, and constraints
- [ ] `tasks.md` is dependency-ordered and executable

## Engineering Gate

- [ ] Active shell preflight passed (`mvn -v`, `java -version`)
- [ ] Build is successful
- [ ] Tests are successful
- [ ] No blocking defects in core flow

## Packaging Gate

- [ ] Jar is generated
- [ ] Startup command is validated
- [ ] Runtime configuration is documented
- [ ] Secrets are injected via environment variables (not hardcoded)

## Runtime Smoke Gate

- [ ] Core list/read endpoint passes (feature-specific)
- [ ] Core command/write endpoint passes (feature-specific)
- [ ] Boundary validation request returns expected JSON contract
- [ ] Feature UI route responds HTTP 200

## Reproducibility Gate

- [ ] A second demo run is completed
- [ ] Major drift is captured and reduced

## Team Adoption Gate

- [ ] Quickstart is understandable by a teammate
- [ ] One dry-run can be completed using docs only
