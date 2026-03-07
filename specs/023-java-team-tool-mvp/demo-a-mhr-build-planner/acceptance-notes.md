# Demo A Acceptance Notes

## Current Status (2026-03-07)

Implemented MVP code skeleton and core features for Demo A:

- Spring Boot app scaffold (Java 11, Maven project)
- Package structure under `com.amor.speckit.mvp.mhr`
- SQL baseline files (`docs/sql/schema.sql`, `docs/sql/seed.sql`)
- JSON API endpoints:
  - `GET /api/v1/skills`
  - `GET /api/v1/equipments?part=&weaponType=`
  - `POST /api/v1/builds/generate`
  - `GET /api/v1/builds/{id}`
- Build generation service with:
  - unique armor part composition
  - skill threshold filtering
  - maxResults range validation
  - score/sort/limit behavior
- Global JSON error handling
- Simple web page at `/index.html`
- API and service test classes

## Environment Notes

- Build target remains Java 11 in `pom.xml`; runtime verification in this environment used JDK 21.

## Commands Executed

```powershell
$env:JAVA_HOME='C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot'
$env:Path=($env:JAVA_HOME + '\bin;' + $env:Path)
& 'C:\Users\Administrator\AppData\Local\Programs\Apache\Maven\apache-maven-3.9.11\bin\mvn.cmd' -q -DskipTests=false test
& 'C:\Users\Administrator\AppData\Local\Programs\Apache\Maven\apache-maven-3.9.11\bin\mvn.cmd' -q -DskipTests package
& 'C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot\bin\java.exe' -jar target\mhr-build-planner-0.0.1-SNAPSHOT.jar --spring.profiles.active=local
```

## Captured Evidence

1. Test reports generated:
  - `target/surefire-reports/TEST-com.amor.speckit.mvp.mhr.controller.BuildControllerTest.xml`
  - `target/surefire-reports/TEST-com.amor.speckit.mvp.mhr.service.BuildGenerationServiceTest.xml`
2. Jar artifact generated:
  - `target/mhr-build-planner-0.0.1-SNAPSHOT.jar`
3. Runtime smoke checks passed:
  - `GET /api/v1/skills` returned 3 seeded skills
  - `POST /api/v1/builds/generate` returned build results meeting thresholds
  - Validation contract returned expected JSON for `maxResults=21`:
    - `code=VALIDATION_ERROR`
    - `message=maxResults must be between 1 and 20`
    - `details[0]={field:maxResults, reason:out_of_range}`
  - `GET /` returned HTTP 200

## Known Gaps

- Database integration is currently represented by SQL baselines and in-memory catalog data for MVP speed.
- If full PostgreSQL runtime persistence is required, repository layer should be upgraded to JPA/Jdbc implementation in next step.
