param(
    [string]$DbHost = "localhost",
    [int]$DbPort = 5432,
    [string]$DbName = "speckit_mhr",
    [string]$DbUser = "mhr_user",
    [string]$DbPassword = "",
    [string]$BaseSkillsUrl = "https://www.gamersky.com/handbook/202206/1491533.shtml",
    [string]$SunbreakSkillsUrl = "https://www.gamersky.com/handbook/202207/1497439.shtml"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-CommandExists {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

function Decode-Html {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) {
        return ""
    }
    return [System.Net.WebUtility]::HtmlDecode($Text)
}

function Strip-Html {
    param([string]$Html)
    $v = Decode-Html $Html
    $v = [regex]::Replace($v, "(?is)<br\s*/?>", " ")
    $v = [regex]::Replace($v, "(?is)<[^>]+>", " ")
    $v = [regex]::Replace($v, "\s+", " ")
    return $v.Trim()
}

function Get-MaxLevelFromEffect {
    param([string]$Effect)

    $maxLevel = 0

    foreach ($m in [regex]::Matches($Effect, "(?i)Lv\s*([0-9]{1,2})")) {
        $v = [int]$m.Groups[1].Value
        if ($v -gt $maxLevel) {
            $maxLevel = $v
        }
    }

    foreach ($m in [regex]::Matches($Effect, "(^|\s|。|；|;|，|,)([0-9]{1,2})\s*:")) {
        $v = [int]$m.Groups[2].Value
        if ($v -gt $maxLevel) {
            $maxLevel = $v
        }
    }

    if ($maxLevel -eq 0 -and $Effect.Length -gt 0) {
        $maxLevel = 1
    }

    if ($maxLevel -lt 1) { $maxLevel = 1 }
    if ($maxLevel -gt 10) { $maxLevel = 10 }
    return $maxLevel
}

function Is-SkillRow {
    param(
        [string]$Name,
        [string]$Effect
    )

    if ([string]::IsNullOrWhiteSpace($Name)) {
        return $false
    }

    if ($Name.Length -gt 40) {
        return $false
    }

    if ([string]::IsNullOrWhiteSpace($Effect)) {
        return $false
    }

    if ($Effect.Length -lt 2) {
        return $false
    }

    return $true
}

function Parse-SkillsFromPage {
    param([string]$Url)

    Write-Host "[skills] fetching $Url"
    $resp = Invoke-WebRequest -Uri $Url -UseBasicParsing
    $html = $resp.Content

    $rows = [regex]::Matches($html, "(?is)<tr[^>]*>(.*?)</tr>")
    $result = @()

    foreach ($row in $rows) {
        $cells = [regex]::Matches($row.Groups[1].Value, "(?is)<t[dh][^>]*>(.*?)</t[dh]>")
        if ($cells.Count -lt 3) {
            continue
        }

        $name = Strip-Html $cells[0].Groups[1].Value
        $effect = Strip-Html $cells[2].Groups[1].Value

        if (-not (Is-SkillRow -Name $name -Effect $effect)) {
            continue
        }

        $maxLevel = Get-MaxLevelFromEffect -Effect $effect

        $result += [pscustomobject]@{
            nameZh = $name
            maxLevel = $maxLevel
            effect = $effect
        }
    }

    return $result
}

function New-SkillCode {
    param([string]$NameZh)

    $sha = [System.Security.Cryptography.SHA1]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($NameZh)
        $hash = $sha.ComputeHash($bytes)
        $hex = ([BitConverter]::ToString($hash) -replace "-", "")
        return "ZH_" + $hex.Substring(0, 10)
    } finally {
        $sha.Dispose()
    }
}

function Escape-Sql {
    param([string]$Text)
    if ($null -eq $Text) {
        return ""
    }
    return $Text.Replace("'", "''")
}

Assert-CommandExists -Name "psql"

if ([string]::IsNullOrWhiteSpace($DbPassword)) {
    if ($env:MHR_DB_PASSWORD) {
        $DbPassword = $env:MHR_DB_PASSWORD
    }
}
if ([string]::IsNullOrWhiteSpace($DbPassword)) {
    throw "DbPassword is empty. Pass -DbPassword or set MHR_DB_PASSWORD."
}

$allRaw = @()
$allRaw += Parse-SkillsFromPage -Url $BaseSkillsUrl
$allRaw += Parse-SkillsFromPage -Url $SunbreakSkillsUrl

$merged = @{}
foreach ($s in $allRaw) {
    $key = $s.nameZh.Trim()
    if (-not $merged.ContainsKey($key)) {
        $merged[$key] = $s
        continue
    }
    $existing = $merged[$key]
    if ($s.maxLevel -gt $existing.maxLevel) {
        $existing.maxLevel = $s.maxLevel
    }
    if ($s.effect.Length -gt $existing.effect.Length) {
        $existing.effect = $s.effect
    }
}

$env:PGPASSWORD = $DbPassword
$existingRows = & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -At -F '|' -c "SELECT name_zh, code FROM mhr_skills;"
if ($LASTEXITCODE -ne 0) {
    throw "Failed to query existing mhr_skills."
}

$existingCodeByName = @{}
foreach ($line in $existingRows) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line.Split('|')
    if ($parts.Length -lt 2) { continue }
    $existingCodeByName[$parts[0]] = $parts[1]
}

$sqlLines = New-Object System.Collections.Generic.List[string]
$sqlLines.Add("BEGIN;")
$sqlLines.Add("CREATE TABLE IF NOT EXISTS mhr_skill_effects (skill_code VARCHAR(64) PRIMARY KEY, effect TEXT NOT NULL DEFAULT '');")

foreach ($name in ($merged.Keys | Sort-Object)) {
    $s = $merged[$name]
    $code = if ($existingCodeByName.ContainsKey($name)) { $existingCodeByName[$name] } else { New-SkillCode -NameZh $name }
    $safeCode = Escape-Sql $code
    $safeName = Escape-Sql $name
    $safeEffect = Escape-Sql $s.effect
    $max = [int]$s.maxLevel
    if ($max -lt 1) { $max = 1 }

    $sqlLines.Add("INSERT INTO mhr_skills (id, code, name, name_zh, max_level)")
    $sqlLines.Add("VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM mhr_skills), '$safeCode', '$safeName', '$safeName', $max)")
    $sqlLines.Add("ON CONFLICT (code) DO UPDATE SET")
    $sqlLines.Add("  name = EXCLUDED.name,")
    $sqlLines.Add("  name_zh = EXCLUDED.name_zh,")
    $sqlLines.Add("  max_level = GREATEST(mhr_skills.max_level, EXCLUDED.max_level);")
    $sqlLines.Add("INSERT INTO mhr_skill_effects (skill_code, effect)")
    $sqlLines.Add("VALUES ('$safeCode', '$safeEffect')")
    $sqlLines.Add("ON CONFLICT (skill_code) DO UPDATE SET effect = CASE WHEN EXCLUDED.effect <> '' THEN EXCLUDED.effect ELSE mhr_skill_effects.effect END;")
}

$sqlLines.Add(@"
WITH ranked AS (
    SELECT
        code,
        name_zh,
        max_level,
        ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(name_zh)) ORDER BY max_level DESC, code ASC) AS rn,
        FIRST_VALUE(code) OVER (PARTITION BY LOWER(TRIM(name_zh)) ORDER BY max_level DESC, code ASC) AS keep_code
    FROM mhr_skills
), moved AS (
    INSERT INTO mhr_equipment_skill_points (equipment_id, skill_code, points)
    SELECT p.equipment_id, r.keep_code, p.points
    FROM mhr_equipment_skill_points p
    JOIN ranked r ON p.skill_code = r.code
    WHERE r.rn > 1
    ON CONFLICT (equipment_id, skill_code) DO UPDATE
    SET points = GREATEST(mhr_equipment_skill_points.points, EXCLUDED.points)
    RETURNING 1
)
DELETE FROM mhr_equipment_skill_points p
USING ranked r
WHERE p.skill_code = r.code
  AND r.rn > 1;
"@)

$sqlLines.Add(@"
WITH ranked AS (
    SELECT
        code,
        ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(name_zh)) ORDER BY max_level DESC, code ASC) AS rn
    FROM mhr_skills
)
DELETE FROM mhr_skills s
USING ranked r
WHERE s.code = r.code
  AND r.rn > 1;
"@)

$sqlLines.Add("COMMIT;")

$tempSql = Join-Path $env:TEMP ("mhr_skill_repair_" + [guid]::NewGuid().ToString("N") + ".sql")
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($tempSql, ($sqlLines -join [Environment]::NewLine), $utf8NoBom)

try {
    Write-Host "[skills] applying SQL patch: $tempSql"
    & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -f $tempSql
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to apply skill repair SQL."
    }

    $summary = & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -At -F '|' -c "SELECT COUNT(*)::text, COUNT(se.skill_code)::text FROM mhr_skills s LEFT JOIN mhr_skill_effects se ON se.skill_code = s.code;"
    if ($LASTEXITCODE -eq 0 -and $summary.Count -gt 0) {
        $parts = $summary[0].Split('|')
        Write-Host "[skills] repaired total skills: $($parts[0]), with effect text: $($parts[1])"
    }

    Write-Host "[skills] done"
} finally {
    if (Test-Path $tempSql) {
        Remove-Item $tempSql -Force
    }
}
