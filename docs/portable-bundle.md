# Portable Bundle Guide

This project now supports an embedded MHR catalog mode for offline runs.

## What This Solves

- No PostgreSQL setup required on the target machine.
- No JDK installation required if you package a runtime.
- Friend can run with `run.bat` directly.

## Default Runtime Mode

`src/main/resources/application.yml` defaults to:

- `app.mhr.catalog.repository-mode: embedded-json`
- `app.mhr.catalog.embedded-json-path: catalog/mhr-catalog.json`

## Refresh Embedded Data From DB

Use this when your DB data changes:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/mhr/export_catalog_to_embedded_json.ps1 -DbPassword "<db_password>"
```

Output file:

- `src/main/resources/catalog/mhr-catalog.json`

## Build Portable Package

```powershell
powershell -ExecutionPolicy Bypass -File scripts/package_portable_bundle.ps1 -SkipTests
```

Artifacts:

- `dist/portable/` (contains `app.jar`, optional `runtime/`, `run.bat`, `run.ps1`)
- `dist/mhr-build-planner-portable.zip`

## Run On Friend's PC

1. Unzip `dist/mhr-build-planner-portable.zip`.
2. Double click `run.bat`.
3. Open `http://localhost:8080`.

If you package with `-NoRuntime`, target machine must already have Java in PATH.
