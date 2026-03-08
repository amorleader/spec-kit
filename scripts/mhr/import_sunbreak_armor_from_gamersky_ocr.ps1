param(
    [string]$DbHost = "localhost",
    [int]$DbPort = 5432,
    [string]$DbName = "speckit_mhr",
    [string]$DbUser = "mhr_user",
    [string]$DbPassword = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-CommandExists {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

function Escape-Sql {
    param([string]$Text)
    if ($null -eq $Text) { return "" }
    return $Text.Replace("'", "''")
}

function Get-DeterministicId {
    param([string]$Key)

    $md5 = [System.Security.Cryptography.MD5]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Key)
        $hash = $md5.ComputeHash($bytes)
        $hex = [System.BitConverter]::ToString($hash).Replace("-", "")
        $n = [Convert]::ToInt64($hex.Substring(0, 12), 16)
        return 760000000 + ($n % 200000000)
    }
    finally {
        $md5.Dispose()
    }
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

# Curated from the 4 screenshot tables provided by user.
# Names are ASCII-safe to avoid terminal/script encoding corruption on Windows PowerShell.
$equipments = @(
    @{ set = "SILVER_SOL"; part = "HEAD";  name = "SILVER_SOL_HEAD";  slots = @(4,1,1); rarity = 10; skills = @{ "SK_SUPER_CRIT" = 2; "SK_ELEM_CRIT" = 1; "SK_WINDPROOF" = 3 } },
    @{ set = "SILVER_SOL"; part = "CHEST"; name = "SILVER_SOL_CHEST"; slots = @(4,3,1); rarity = 10; skills = @{ "SK_ELEM_WEX" = 1; "SK_ELEM_CRIT" = 1; "SK_FIRE_ATK" = 3 } },
    @{ set = "SILVER_SOL"; part = "ARMS";  name = "SILVER_SOL_ARMS";  slots = @(4,1,1); rarity = 10; skills = @{ "SK_ELEM_WEX" = 1; "SK_ELEM_CRIT" = 1; "SK_CONSTITUTION" = 2 } },
    @{ set = "SILVER_SOL"; part = "WAIST"; name = "SILVER_SOL_WAIST"; slots = @(2,1,1); rarity = 10; skills = @{ "SK_ELEM_WEX" = 1; "SK_ADRENALINE_RUSH" = 1; "SK_CONSTITUTION" = 3 } },
    @{ set = "SILVER_SOL"; part = "LEGS";  name = "SILVER_SOL_LEGS";  slots = @(2,2,1); rarity = 10; skills = @{ "SK_SUPER_CRIT" = 1; "SK_ADRENALINE_RUSH" = 1; "SK_MAXIMUM_MIGHT" = 2 } },

    @{ set = "GOLD_LUNE"; part = "HEAD";  name = "GOLD_LUNE_HEAD";  slots = @(2,2);   rarity = 10; skills = @{ "SK_STATUS_TRIGGER" = 2; "SK_BURST_UP" = 1; "SK_CHAIN_CRIT" = 2 } },
    @{ set = "GOLD_LUNE"; part = "CHEST"; name = "GOLD_LUNE_CHEST"; slots = @(3,2);   rarity = 10; skills = @{ "SK_DEFIANCE" = 2; "SK_COUNTERSTRIKE" = 2; "SK_DIVINE_BLESSING" = 3 } },
    @{ set = "GOLD_LUNE"; part = "ARMS";  name = "GOLD_LUNE_ARMS";  slots = @(4,2,1); rarity = 10; skills = @{ "SK_SUPER_CRIT" = 1; "SK_PEAK_PERF" = 1; "SK_CHAIN_CRIT" = 1 } },
    @{ set = "GOLD_LUNE"; part = "WAIST"; name = "GOLD_LUNE_WAIST"; slots = @(3,2);   rarity = 10; skills = @{ "SK_STATUS_TRIGGER" = 1; "SK_BURST_UP" = 1; "SK_EVADE_WINDOW" = 2 } },
    @{ set = "GOLD_LUNE"; part = "LEGS";  name = "GOLD_LUNE_LEGS";  slots = @(4,2);   rarity = 10; skills = @{ "SK_DEFIANCE" = 3; "SK_PEAK_PERF" = 2; "SK_RECOVERY_UP" = 2 } },

    @{ set = "LUCENT_NARGA"; part = "HEAD";  name = "LUCENT_NARGA_HEAD";  slots = @(3,1,1); rarity = 10; skills = @{ "SK_HANDICRAFT" = 1; "SK_LOAD_SHELLS" = 1; "SK_CHALLENGER" = 3 } },
    @{ set = "LUCENT_NARGA"; part = "CHEST"; name = "LUCENT_NARGA_CHEST"; slots = @(3,1);   rarity = 10; skills = @{ "SK_SNEAK_ATTACK" = 1; "SK_SUPER_CRIT" = 1; "SK_CHALLENGER" = 2 } },
    @{ set = "LUCENT_NARGA"; part = "ARMS";  name = "LUCENT_NARGA_ARMS";  slots = @(2,2);   rarity = 10; skills = @{ "SK_ADRENALINE_RUSH" = 2; "SK_EVADE_WINDOW" = 3 } },
    @{ set = "LUCENT_NARGA"; part = "WAIST"; name = "LUCENT_NARGA_WAIST"; slots = @(3,1,1); rarity = 10; skills = @{ "SK_SNEAK_ATTACK" = 1; "SK_HANDICRAFT" = 2; "SK_SPREAD_UP" = 2 } },
    @{ set = "LUCENT_NARGA"; part = "LEGS";  name = "LUCENT_NARGA_LEGS";  slots = @(3);     rarity = 10; skills = @{ "SK_SNEAK_ATTACK" = 1; "SK_ADRENALINE_RUSH" = 1; "SK_HANDICRAFT" = 2; "SK_LOAD_SHELLS" = 2 } },

    @{ set = "SEETHING_BAZEL"; part = "HEAD";  name = "SEETHING_BAZEL_HEAD";  slots = @(3,2);   rarity = 10; skills = @{ "SK_LATENT_POWER" = 2; "SK_ATTACK_BOOST" = 1; "SK_EARPLUGS" = 1 } },
    @{ set = "SEETHING_BAZEL"; part = "CHEST"; name = "SEETHING_BAZEL_CHEST"; slots = @(3);     rarity = 10; skills = @{ "SK_GUTS" = 1; "SK_ATTACK_BOOST" = 1; "SK_SPEED_EATING" = 2 } },
    @{ set = "SEETHING_BAZEL"; part = "ARMS";  name = "SEETHING_BAZEL_ARMS";  slots = @(3,1);   rarity = 10; skills = @{ "SK_GUTS" = 1; "SK_WEAKNESS_EXPLOIT" = 1; "SK_EARPLUGS" = 1 } },
    @{ set = "SEETHING_BAZEL"; part = "WAIST"; name = "SEETHING_BAZEL_WAIST"; slots = @(2,1,1); rarity = 10; skills = @{ "SK_LATENT_POWER" = 3; "SK_STAMINA_RECOVERY" = 1; "SK_EARPLUGS" = 1 } },
    @{ set = "SEETHING_BAZEL"; part = "LEGS";  name = "SEETHING_BAZEL_LEGS";  slots = @(2,2);   rarity = 10; skills = @{ "SK_GUTS" = 1; "SK_STAMINA_RECOVERY" = 2; "SK_STAMINA_THIEF" = 3 } },

    # From wiki.gamersky.com/2/3110/12233 (Archfiend Armor)
    @{ set = "ARCHFIEND"; part = "HEAD";  name = "ARCHFIEND_HEAD";  slots = @(1,1); rarity = 10; skills = @{ "SK_WEAKNESS_EXPLOIT" = 1; "SK_RESENTMENT" = 2 } },
    @{ set = "ARCHFIEND"; part = "CHEST"; name = "ARCHFIEND_CHEST"; slots = @(1,1); rarity = 10; skills = @{ "SK_WEAKNESS_EXPLOIT" = 1; "SK_RESENTMENT" = 1; "SK_CHAIN_CRIT" = 1 } },
    @{ set = "ARCHFIEND"; part = "ARMS";  name = "ARCHFIEND_ARMS";  slots = @(1); rarity = 10; skills = @{ "SK_DERELICTION" = 2; "SK_RESENTMENT" = 1 } },
    @{ set = "ARCHFIEND"; part = "WAIST"; name = "ARCHFIEND_WAIST"; slots = @(1); rarity = 10; skills = @{ "SK_WEAKNESS_EXPLOIT" = 1; "SK_CHAIN_CRIT" = 2 } },
    @{ set = "ARCHFIEND"; part = "LEGS";  name = "ARCHFIEND_LEGS";  slots = @(1,1,1); rarity = 10; skills = @{ "SK_DERELICTION" = 1; "SK_RESENTMENT" = 1 } },

    # From wiki.gamersky.com/2/3110/12152 (Ibushi - Pure)
    @{ set = "IBUSHI_PURE"; part = "HEAD";  name = "IBUSHI_PURE_HEAD";  slots = @(1); rarity = 10; skills = @{ "SK_WIND_ALIGNMENT" = 1; "SK_FOCUS" = 1; "SK_EVADE_EXTENDER" = 1; "SK_THUNDEROUS_SOUL" = 1 } },
    @{ set = "IBUSHI_PURE"; part = "CHEST"; name = "IBUSHI_PURE_CHEST"; slots = @(1); rarity = 10; skills = @{ "SK_WIND_ALIGNMENT" = 1; "SK_GUARD" = 1; "SK_FLINCH_FREE" = 1; "SK_THUNDEROUS_SOUL" = 1 } },
    @{ set = "IBUSHI_PURE"; part = "ARMS";  name = "IBUSHI_PURE_ARMS";  slots = @(1); rarity = 10; skills = @{ "SK_WIND_ALIGNMENT" = 1; "SK_CONSTITUTION" = 1; "SK_STAMINA_SURGE" = 1; "SK_THUNDEROUS_SOUL" = 1 } },
    @{ set = "IBUSHI_PURE"; part = "WAIST"; name = "IBUSHI_PURE_WAIST"; slots = @(1); rarity = 10; skills = @{ "SK_WIND_ALIGNMENT" = 1; "SK_POWER_PROLONGER" = 1; "SK_EVASION" = 1; "SK_THUNDEROUS_SOUL" = 1 } },
    @{ set = "IBUSHI_PURE"; part = "LEGS";  name = "IBUSHI_PURE_LEGS";  slots = @(1); rarity = 10; skills = @{ "SK_WIND_ALIGNMENT" = 1; "SK_SLUGGER" = 1; "SK_GUARD_UP" = 1; "SK_THUNDEROUS_SOUL" = 1 } },

    # From wiki.gamersky.com/2/3110/12187 (Narwa - Pure)
    @{ set = "NARWA_PURE"; part = "HEAD";  name = "NARWA_PURE_HEAD";  slots = @(1); rarity = 10; skills = @{ "SK_THUNDER_ALIGNMENT" = 1; "SK_RAPID_MORPH" = 1; "SK_OFFENSIVE_GUARD" = 1; "SK_THUNDEROUS_SOUL" = 1 } },
    @{ set = "NARWA_PURE"; part = "CHEST"; name = "NARWA_PURE_CHEST"; slots = @(1); rarity = 10; skills = @{ "SK_THUNDER_ALIGNMENT" = 1; "SK_CONSTITUTION" = 1; "SK_CRITICAL_DRAW" = 1; "SK_THUNDEROUS_SOUL" = 1 } },
    @{ set = "NARWA_PURE"; part = "ARMS";  name = "NARWA_PURE_ARMS";  slots = @(1); rarity = 10; skills = @{ "SK_THUNDER_ALIGNMENT" = 1; "SK_GUARD" = 1; "SK_PARTBREAKER" = 1; "SK_THUNDEROUS_SOUL" = 1 } },
    @{ set = "NARWA_PURE"; part = "WAIST"; name = "NARWA_PURE_WAIST"; slots = @(1); rarity = 10; skills = @{ "SK_THUNDER_ALIGNMENT" = 1; "SK_GUARD" = 1; "SK_ARTILLERY" = 1; "SK_THUNDEROUS_SOUL" = 1 } },
    @{ set = "NARWA_PURE"; part = "LEGS";  name = "NARWA_PURE_LEGS";  slots = @(1); rarity = 10; skills = @{ "SK_THUNDER_ALIGNMENT" = 1; "SK_EVASION" = 1; "SK_MARATHON_RUNNER" = 1; "SK_THUNDEROUS_SOUL" = 1 } }
)

$skillMax = @{}
foreach ($eq in $equipments) {
    foreach ($kv in $eq.skills.GetEnumerator()) {
        $k = [string]$kv.Key
        $v = [int]$kv.Value
        if (-not $skillMax.ContainsKey($k)) {
            $skillMax[$k] = $v
        } else {
            $skillMax[$k] = [Math]::Max($skillMax[$k], $v)
        }
    }
}

$env:PGPASSWORD = $DbPassword
$env:PGCLIENTENCODING = "UTF8"

$sql = New-Object System.Collections.Generic.List[string]
$sql.Add("BEGIN;")
$sql.Add("CREATE TABLE IF NOT EXISTS mhr_skills (id BIGINT PRIMARY KEY, code VARCHAR(64) UNIQUE NOT NULL, name VARCHAR(128) NOT NULL, name_zh VARCHAR(128) NOT NULL, max_level INT NOT NULL);")
$sql.Add("CREATE TABLE IF NOT EXISTS mhr_skill_effects (skill_code VARCHAR(64) PRIMARY KEY, effect TEXT NOT NULL DEFAULT '');")
$sql.Add("CREATE TABLE IF NOT EXISTS mhr_equipments (id BIGINT PRIMARY KEY, name VARCHAR(128) NOT NULL, name_zh VARCHAR(128) NOT NULL, part VARCHAR(32) NOT NULL, rarity INT NOT NULL, slots_csv VARCHAR(64) NOT NULL);")
$sql.Add("CREATE TABLE IF NOT EXISTS mhr_equipment_skill_points (equipment_id BIGINT NOT NULL, skill_code VARCHAR(64) NOT NULL, points INT NOT NULL, PRIMARY KEY (equipment_id, skill_code));")
$sql.Add("CREATE TABLE IF NOT EXISTS mhr_equipment_weapon_types (equipment_id BIGINT NOT NULL, weapon_type VARCHAR(32) NOT NULL, PRIMARY KEY (equipment_id, weapon_type));")

$sql.Add("WITH numbered AS (")
$sql.Add("  SELECT ROW_NUMBER() OVER (ORDER BY x.code) AS rn, x.code, x.max_level")
$sql.Add("  FROM (")
foreach ($k in ($skillMax.Keys | Sort-Object)) {
    $safeCode = Escape-Sql $k
    $maxLv = [int]$skillMax[$k]
    $sql.Add("    SELECT '$safeCode'::text AS code, $maxLv::int AS max_level UNION ALL")
}
if ($skillMax.Count -gt 0) {
    $last = $sql[$sql.Count - 1]
    $sql[$sql.Count - 1] = $last.Substring(0, $last.Length - " UNION ALL".Length)
}
$sql.Add("  ) x")
$sql.Add("), base AS (")
$sql.Add("  SELECT COALESCE(MAX(id),0) AS max_id FROM mhr_skills")
$sql.Add(")")
$sql.Add("INSERT INTO mhr_skills(id, code, name, name_zh, max_level)")
$sql.Add("SELECT base.max_id + numbered.rn, numbered.code, numbered.code, numbered.code, GREATEST(numbered.max_level,1)")
$sql.Add("FROM numbered CROSS JOIN base")
$sql.Add("ON CONFLICT (code) DO UPDATE SET")
$sql.Add("  max_level = GREATEST(mhr_skills.max_level, EXCLUDED.max_level);")

$sql.Add("INSERT INTO mhr_skill_effects(skill_code, effect)")
$sql.Add("SELECT s.code, '' FROM mhr_skills s")
$sql.Add("WHERE s.code IN (")
foreach ($k in ($skillMax.Keys | Sort-Object)) {
    $safeCode = Escape-Sql $k
    $sql.Add("  '$safeCode',")
}
if ($skillMax.Count -gt 0) {
    $sql[$sql.Count - 1] = $sql[$sql.Count - 1].TrimEnd(',')
}
$sql.Add(")")
$sql.Add("ON CONFLICT (skill_code) DO NOTHING;")

foreach ($eq in $equipments) {
    $name = [string]$eq.name
    $nameZh = [string]$eq.name
    $part = [string]$eq.part
    $id = Get-DeterministicId -Key ("$name|$part")
    $rarity = [int]$eq.rarity
    $slotsCsv = (($eq.slots | ForEach-Object { [string]$_ }) -join ',')

    $safeName = Escape-Sql $name
    $safeNameZh = Escape-Sql $nameZh
    $safePart = Escape-Sql $part
    $safeSlots = Escape-Sql $slotsCsv

    $sql.Add("INSERT INTO mhr_equipments(id, name, name_zh, part, rarity, slots_csv)")
    $sql.Add("VALUES ($id, '$safeName', '$safeNameZh', '$safePart', $rarity, '$safeSlots')")
    $sql.Add("ON CONFLICT (id) DO UPDATE SET")
    $sql.Add("  name = EXCLUDED.name,")
    $sql.Add("  name_zh = EXCLUDED.name_zh,")
    $sql.Add("  part = EXCLUDED.part,")
    $sql.Add("  rarity = EXCLUDED.rarity,")
    $sql.Add("  slots_csv = EXCLUDED.slots_csv;")

    $sql.Add("DELETE FROM mhr_equipment_skill_points WHERE equipment_id = $id;")
    $sql.Add("DELETE FROM mhr_equipment_weapon_types WHERE equipment_id = $id;")

    foreach ($sp in $eq.skills.GetEnumerator()) {
        $code = Escape-Sql ([string]$sp.Key)
        $points = [int]$sp.Value
        $sql.Add("INSERT INTO mhr_equipment_skill_points(equipment_id, skill_code, points) VALUES ($id, '$code', $points) ON CONFLICT (equipment_id, skill_code) DO UPDATE SET points = GREATEST(mhr_equipment_skill_points.points, EXCLUDED.points);")
    }

    foreach ($wt in @("LONG_SWORD", "GREAT_SWORD", "BOW")) {
        $sql.Add("INSERT INTO mhr_equipment_weapon_types(equipment_id, weapon_type) VALUES ($id, '$wt') ON CONFLICT (equipment_id, weapon_type) DO NOTHING;")
    }
}

$sql.Add("COMMIT;")

$tmpSql = Join-Path $env:TEMP ("mhr_sunbreak_manual_import_" + [guid]::NewGuid().ToString("N") + ".sql")
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($tmpSql, ($sql -join [Environment]::NewLine), $utf8NoBom)

try {
    Write-Host "[sunbreak-armor] applying SQL: $tmpSql"
    & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -f $tmpSql
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to apply Sunbreak armor import SQL patch."
    }

    $summary = @(& psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -At -F '|' -c "SELECT COUNT(*)::text FROM mhr_equipments WHERE id >= 760000000;")
    if ($LASTEXITCODE -eq 0 -and $summary.Length -gt 0) {
        Write-Host "[sunbreak-armor] imported equipment rows (id>=760000000): $($summary[0])"
    }

    Write-Host "[sunbreak-armor] done"
}
finally {
    if (Test-Path $tmpSql) {
        Remove-Item $tmpSql -Force -ErrorAction SilentlyContinue
    }
}
