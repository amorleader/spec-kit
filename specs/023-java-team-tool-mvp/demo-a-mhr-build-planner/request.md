# Demo A Request: Monster Hunter Rise Build Planner (MVP)

## Source Snapshot

This file normalizes the user-provided request into repository-tracked input for Demo A.

## 1. Basic Context

- Request title: Monster Hunter Rise Build Planner (MVP)
- Original title: 怪物猎人崛起配装系统（MVP）
- Request source: Personal project / requirement demonstration
- Target release date: 2026-03-31
- Priority: P1

## 2. Business Goal

Provide a web tool that helps players quickly generate usable gear builds by weapon type and target skills, reducing manual lookup time.

### Success Metrics

1. User can get at least one usable build within 3 minutes.
2. Given skill constraints, generated results are accurate and explainable.
3. Initial page load time is under 5 seconds in local environment.

## 3. Target User and Scenario

### Target User

Monster Hunter Rise players, especially beginners and returning players.

### Main Scenario

1. User selects weapon type (for example: long sword, great sword, bow).
2. User selects target skills and minimum levels.
3. User optionally enters charm skills or slot constraints.
4. User clicks generate.
5. System returns several build options with skill totals, equipment pieces, slots, and explanation.

## 4. Functional Scope

### Must Have (MVP)

1. Basic data management for equipment, skills, parts, and slots.
2. Filtering by target skills and weapon type.
3. Result list with 3 to 10 build options and sorting.
4. Build detail view showing each equipment contribution.
5. JSON API and a simple web page (single service is acceptable).

### Out of Scope

1. Full game content database (sample dataset only).
2. Chinese language support.
3. Login, favorites, sharing.
4. Globally optimal algorithm guarantees.

## 5. Data and Domain Rules

### Core Entities

1. Equipment
2. Skill
3. BuildRequest
4. BuildResult
5. Charm (optional)

### Required Fields

- Equipment: id, name, part, rarity, slots, skillPoints
- Skill: id, name, maxLevel
- BuildRequest: weaponType, targetSkills, optionalCharm, maxResults
- BuildResult: equipmentSet, totalSkills, slotSummary, score

### Validation Rules

1. Skill level cannot exceed skill max level.
2. Equipment part cannot be duplicated (head/chest/arms/waist/legs unique).
3. Returned build must satisfy requested minimum skills.
4. maxResults range is 1 to 20.

## 6. API Expectations (JSON)

### Required Endpoints

1. GET /api/v1/skills
2. GET /api/v1/equipments?part=&weaponType=
3. POST /api/v1/builds/generate
4. GET /api/v1/builds/{id} (optional in MVP if no persistence)

### Example Request

```json
{
  "weaponType": "LONG_SWORD",
  "targetSkills": [
    {"skillCode": "ATTACK_BOOST", "minLevel": 4},
    {"skillCode": "WEAKNESS_EXPLOIT", "minLevel": 3}
  ],
  "maxResults": 5
}
```

### Example Error Response

```json
{
  "code": "VALIDATION_ERROR",
  "message": "maxResults must be between 1 and 20",
  "details": [{"field": "maxResults", "reason": "out_of_range"}]
}
```

## 7. Non-Functional Constraints

- Performance: build generation under 2 seconds with sample dataset.
- Security: no authentication for MVP, strict input validation, sanitized exception output.
- Compatibility: Java 11, Spring Boot 2.7.x, Maven, PostgreSQL.

## 8. Technical Defaults

- Java: 11
- Spring Boot: 2.7.x
- Build: Maven
- Database: PostgreSQL
- Package root: com.amor.speckit.mvp.mhr
- Delivery: runnable jar

## 9. Acceptance and Handoff

### UAT Criteria

1. User can input filters and generate builds from the web page.
2. At least one returned result satisfies constraints.
3. Skill totals in result are correct.
4. Packaged jar starts locally and serves web page.

### Required Evidence

1. Screen recording from input to generated results.
2. API invocation evidence (Postman or curl).
3. Test report and jar packaging evidence.

### Risks and Assumptions

1. Sample dataset does not represent full-game completeness.
2. Algorithm prioritizes usable solutions, not mathematical optimum.
