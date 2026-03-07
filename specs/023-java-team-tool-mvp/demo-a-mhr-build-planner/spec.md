# Feature Specification: Demo A - Monster Hunter Rise Build Planner MVP

## Summary

Build a Java web application that generates usable Monster Hunter Rise equipment builds from user-selected weapon type and target skill constraints. The MVP focuses on fast, explainable, sample-data-driven build generation with JSON APIs and a simple web UI.

## Target User

- Primary: Monster Hunter Rise players (beginner and returning users)
- Secondary: Product owner and team members validating the MVP workflow

## Scope (In/Out)

### In Scope

- Java 11 + Spring Boot 2.7.x + Maven + PostgreSQL baseline
- Package root: `com.amor.speckit.mvp.mhr`
- JSON APIs:
  - `GET /api/v1/skills`
  - `GET /api/v1/equipments?part=&weaponType=`
  - `POST /api/v1/builds/generate`
  - optional `GET /api/v1/builds/{id}` when persistence exists
- Core entities: Equipment, Skill, BuildRequest, BuildResult, Charm(optional)
- Build generation from sample dataset with explainable result details
- Simple web page to submit request and display build results

### Out of Scope

- Full production game dataset coverage
- Login, favorites, sharing
- Chinese localization
- Global optimum solver guarantees

## Functional Requirements

- FR1: System must accept weapon type, target skills, optional charm input, and maxResults.
- FR2: System must validate requested skill levels against skill max levels.
- FR3: System must generate build candidates with unique equipment part usage across head/chest/arms/waist/legs.
- FR4: Returned builds must satisfy minimum target skill constraints.
- FR5: Result list must return 3 to 10 displayable options when available, and support sorting by score.
- FR6: Build detail output must show per-equipment skill contribution and slot summary.
- FR7: API responses must be JSON and include structured validation errors.
- FR8: Web UI must support entering request conditions and showing generated results.

## Non-Functional Requirements

- NFR1: `POST /api/v1/builds/generate` response time < 2s on sample dataset.
- NFR2: First page load time < 5s in local environment.
- NFR3: Invalid input returns sanitized JSON error without stack trace leakage.
- NFR4: Delivery artifact must be a runnable jar produced by Maven on Java 11.
- NFR5: Design must maintain layer boundaries: controller/service/repository/dto.

## Acceptance Criteria

- AC1: Given valid request, API returns at least one build satisfying all minimum skill constraints.
- AC2: Given `maxResults` outside 1-20, API returns `VALIDATION_ERROR` with field detail for `maxResults`.
- AC3: Returned build has no duplicate equipment part across mandatory armor parts.
- AC4: Web page can submit request and display returned build list and detail fields.
- AC5: `mvn -q -DskipTests=false test` passes and evidence is captured.
- AC6: `mvn -q package` produces runnable jar and startup command works locally.

## JSON Contract Expectations

### Build Generate Request

```json
{
  "weaponType": "LONG_SWORD",
  "targetSkills": [
    {"skillCode": "ATTACK_BOOST", "minLevel": 4},
    {"skillCode": "WEAKNESS_EXPLOIT", "minLevel": 3}
  ],
  "optionalCharm": null,
  "maxResults": 5
}
```

### Validation Error Response

```json
{
  "code": "VALIDATION_ERROR",
  "message": "maxResults must be between 1 and 20",
  "details": [{"field": "maxResults", "reason": "out_of_range"}]
}
```

## Risks and Mitigations

- Risk: sample dataset causes low result count for certain skill combinations.
  - Mitigation: define known supported skill combinations for MVP demo evidence.
- Risk: naive generation algorithm is too slow as sample data grows.
  - Mitigation: cap sample dataset size and add short-circuit filtering by weapon/part.
- Risk: ambiguity in score definition leads to inconsistent sorting.
  - Mitigation: define score formula in plan and verify with deterministic test cases.
