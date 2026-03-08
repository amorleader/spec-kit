param(
    [string]$DbHost = "localhost",
    [int]$DbPort = 5432,
    [string]$DbName = "speckit_mhr",
    [string]$DbUser = "mhr_user",
    [string]$DbPassword = "",
    [string]$OutputPath = "src/main/resources/catalog/mhr-catalog.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($DbPassword)) {
    if (-not [string]::IsNullOrWhiteSpace($env:MHR_DB_PASSWORD)) {
        $DbPassword = $env:MHR_DB_PASSWORD
    }
}
if ([string]::IsNullOrWhiteSpace($DbPassword)) {
    throw "DbPassword is empty. Pass -DbPassword or set MHR_DB_PASSWORD."
}

function Assert-CommandExists {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

Assert-CommandExists -Name "psql"

$env:PGPASSWORD = $DbPassword
$env:PGCLIENTENCODING = "UTF8"

# Keep external command stdout/stderr decoding in UTF-8 to avoid mojibake on Windows PowerShell.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[Console]::InputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$out = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $root $OutputPath }
$outDir = Split-Path -Parent $out
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

$skills = @()
$skillRows = @(& psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -At -F '|' -c "SELECT t.id,t.code,t.name,t.name_zh,t.max_level,COALESCE(se.effect,'') FROM (SELECT DISTINCT ON (LOWER(TRIM(name_zh))) id,code,name,name_zh,max_level FROM mhr_skills ORDER BY LOWER(TRIM(name_zh)),max_level DESC,id ASC) t LEFT JOIN mhr_skill_effects se ON se.skill_code=t.code ORDER BY t.id ASC;")
foreach ($r in $skillRows) {
    if ([string]::IsNullOrWhiteSpace($r)) { continue }
    $p = $r.Split('|', 6)
    if ($p.Count -lt 6) { continue }
    $skills += [pscustomobject]@{
        id       = [int64]$p[0]
        code     = [string]$p[1]
        name     = [string]$p[2]
        nameZh   = [string]$p[3]
        maxLevel = [int]$p[4]
        effect   = [string]$p[5]
    }
}

$eqRows = @(& psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -At -F '|' -c "SELECT id,name,name_zh,part,rarity,slots_csv FROM mhr_equipments ORDER BY part ASC,id ASC;")
$eqSkillRows = @(& psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -At -F '|' -c "SELECT equipment_id,skill_code,points FROM mhr_equipment_skill_points;")
$eqWeaponRows = @(& psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -At -F '|' -c "SELECT equipment_id,weapon_type FROM mhr_equipment_weapon_types;")

$skillMap = @{}
foreach ($r in $eqSkillRows) {
    if ([string]::IsNullOrWhiteSpace($r)) { continue }
    $p = $r.Split('|')
    if ($p.Count -lt 3) { continue }
    $id = [int64]$p[0]
    if (-not $skillMap.ContainsKey($id)) { $skillMap[$id] = @{} }
    $skillMap[$id][$p[1]] = [int]$p[2]
}

$weaponMap = @{}
foreach ($r in $eqWeaponRows) {
    if ([string]::IsNullOrWhiteSpace($r)) { continue }
    $p = $r.Split('|')
    if ($p.Count -lt 2) { continue }
    $id = [int64]$p[0]
    if (-not $weaponMap.ContainsKey($id)) { $weaponMap[$id] = New-Object System.Collections.Generic.List[string] }
    $weaponMap[$id].Add($p[1])
}

$equipments = @()
foreach ($r in $eqRows) {
    if ([string]::IsNullOrWhiteSpace($r)) { continue }
    $p = $r.Split('|')
    if ($p.Count -lt 6) { continue }
    $id = [int64]$p[0]

    $slots = @()
    if (-not [string]::IsNullOrWhiteSpace($p[5])) {
        $slots = @($p[5].Split(',') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { [int]$_ })
    }

    $skillPoints = @{}
    if ($skillMap.ContainsKey($id)) {
        $skillPoints = $skillMap[$id]
    }

    $supportedWeaponTypes = @()
    if ($weaponMap.ContainsKey($id)) {
        $supportedWeaponTypes = @($weaponMap[$id] | Sort-Object -Unique)
    }

    $equipments += [pscustomobject]@{
        id                   = $id
        name                 = [string]$p[1]
        nameZh               = [string]$p[2]
        part                 = [string]$p[3]
        rarity               = [int]$p[4]
        slots                = $slots
        skillPoints          = $skillPoints
        supportedWeaponTypes = $supportedWeaponTypes
    }
}

$decorations = @()
$decorRows = @(& psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -At -F '|' -c "SELECT id,name,name_zh,slot_level,skill_code,skill_name_zh,skill_level,price,materials FROM mhr_decorations ORDER BY slot_level ASC,id ASC;")
foreach ($r in $decorRows) {
    if ([string]::IsNullOrWhiteSpace($r)) { continue }
    $p = $r.Split('|', 9)
    if ($p.Count -lt 9) { continue }
    $decorations += [pscustomobject]@{
        id          = [int64]$p[0]
        name        = [string]$p[1]
        nameZh      = [string]$p[2]
        slotLevel   = [int]$p[3]
        skillCode   = [string]$p[4]
        skillNameZh = [string]$p[5]
        skillLevel  = [int]$p[6]
        price       = [int]$p[7]
        materials   = [string]$p[8]
    }
}

$payload = [pscustomobject]@{
    skills = $skills
    equipments = $equipments
    decorations = $decorations
}

[System.IO.File]::WriteAllText($out, ($payload | ConvertTo-Json -Depth 8), $utf8NoBom)

Write-Host "[export] output: $out"
Write-Host "[export] skills=$($skills.Count), equipments=$($equipments.Count), decorations=$($decorations.Count)"
