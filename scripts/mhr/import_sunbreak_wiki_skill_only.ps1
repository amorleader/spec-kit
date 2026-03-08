param(
    [string]$DbHost = "localhost",
    [int]$DbPort = 5432,
    [string]$DbName = "speckit_mhr",
    [string]$DbUser = "mhr_user",
    [string]$DbPassword = "",
    [string]$CatalogUrl = "https://wiki.gamersky.com/2/3110",
    [int]$RequestDelayMs = 80
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Decode-UnicodeLiteral {
    param([string]$Text)

    return [regex]::Replace($Text, "\\u([0-9a-fA-F]{4})", {
        param($m)
        return [char][int]::Parse($m.Groups[1].Value, [System.Globalization.NumberStyles]::HexNumber)
    })
}

$MARKER_SKILLS = Decode-UnicodeLiteral "\u5404\u4ef6\u9632\u5177\u7684\u6280\u80fd"
$MARKER_DEFENSE = Decode-UnicodeLiteral "\u5404\u4ef6\u9632\u5177\u7684\u9632\u5fa1\u529b"
$HEADER_EQUIP_NAME = Decode-UnicodeLiteral "\u9632\u5177\u540d\u79f0"

function Assert-CommandExists {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

function Escape-Sql {
    param([string]$Text)
    if ($null -eq $Text) {
        return ""
    }
    return $Text.Replace("'", "''")
}

function Decode-Html {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }
    return [System.Net.WebUtility]::HtmlDecode($Text)
}

function Strip-Html {
    param([string]$Html)

    $v = Decode-Html $Html
    $v = [regex]::Replace($v, "(?is)<br\s*/?>", "`n")
    $v = [regex]::Replace($v, "(?is)<[^>]+>", " ")
    $v = [regex]::Replace($v, "\s+", " ")
    return $v.Trim()
}

function Get-PageDataObject {
    param([string]$Url)

    $tempPath = Join-Path $env:TEMP ("mhr_wiki_" + [guid]::NewGuid().ToString("N") + ".html")
    try {
        Invoke-WebRequest -Uri $Url -UseBasicParsing -OutFile $tempPath
        $raw = Get-Content -Raw -Path $tempPath

        $start = $raw.IndexOf("window._pageData = ")
        if ($start -lt 0) {
            throw "window._pageData not found: $Url"
        }
        $start += "window._pageData = ".Length

        $end = $raw.IndexOf("</script>", $start)
        if ($end -lt 0) {
            throw "_pageData script end not found: $Url"
        }

        $json = $raw.Substring($start, $end - $start).Trim()
        if ($json.EndsWith(";")) {
            $json = $json.Substring(0, $json.Length - 1)
        }

        return ($json | ConvertFrom-Json)
    }
    finally {
        if (Test-Path $tempPath) {
            Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
        }
    }
}

function Resolve-Part {
    param([string]$EquipmentName)

    if ($EquipmentName -match "\u4e0a\u8863|\u94e0|\u670d|\u80f8|\u7532|\u7fbd\u7ec7") { return "CHEST" }
    if ($EquipmentName -match "\u5934|\u51a0|\u5e3d|\u76d4|\u5dfe") { return "HEAD" }
    if ($EquipmentName -match "\u624b|\u8155|\u8896") { return "ARMS" }
    if ($EquipmentName -match "\u8170|\u5e26") { return "WAIST" }
    if ($EquipmentName -match "\u817f|\u9774|\u88e4|\u8db3|\u80eb") { return "LEGS" }

    return "CHEST"
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

function Get-SkillCode {
    param([string]$SkillNameZh)

    $md5 = [System.Security.Cryptography.MD5]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($SkillNameZh)
        $hash = $md5.ComputeHash($bytes)
        $hex = [System.BitConverter]::ToString($hash).Replace("-", "")
        return "ZH_" + $hex.Substring(0, 10).ToUpperInvariant()
    }
    finally {
        $md5.Dispose()
    }
}

function Get-SkillEntriesFromMap {
    param($Map)

    $entries = New-Object System.Collections.Generic.List[object]
    if ($null -eq $Map) {
        return @()
    }

    if ($Map -is [System.Collections.IDictionary]) {
        foreach ($item in $Map.GetEnumerator()) {
            $entries.Add([pscustomobject]@{
                nameZh = [string]$item.Key
                level = [int]$item.Value
            })
        }
        return ,$entries.ToArray()
    }

    if ($Map.PSObject -and $Map.PSObject.Properties) {
        foreach ($prop in $Map.PSObject.Properties) {
            $entries.Add([pscustomobject]@{
                nameZh = [string]$prop.Name
                level = [int]$prop.Value
            })
        }
        return ,$entries.ToArray()
    }

    return @()
}

function Get-SlotsFromSmallImage {
    param([string]$ImageUrl)

    if ([string]::IsNullOrWhiteSpace($ImageUrl)) {
        return @()
    }

    Add-Type -AssemblyName System.Drawing

    $tempImg = Join-Path $env:TEMP ("mhr_wiki_slot_" + [guid]::NewGuid().ToString("N") + ".jpg")
    try {
        Invoke-WebRequest -Uri $ImageUrl -UseBasicParsing -OutFile $tempImg
        $bmp = [System.Drawing.Bitmap]::new($tempImg)

        try {
            $levels = New-Object System.Collections.Generic.List[int]
            for ($col = 0; $col -lt 3; $col++) {
                $x0 = [int][Math]::Floor($bmp.Width * $col / 3.0)
                $x1 = [int][Math]::Floor($bmp.Width * ($col + 1) / 3.0) - 1
                $y0 = [int][Math]::Floor($bmp.Height * 0.2)
                $y1 = [int][Math]::Floor($bmp.Height * 0.85)

                $dark = 0
                $tot = 0
                for ($y = $y0; $y -le $y1; $y++) {
                    for ($x = $x0; $x -le $x1; $x++) {
                        $p = $bmp.GetPixel($x, $y)
                        $gray = ($p.R + $p.G + $p.B) / 3
                        if ($gray -lt 180) {
                            $dark += 1
                        }
                        $tot += 1
                    }
                }

                $ratio = if ($tot -gt 0) { $dark * 1.0 / $tot } else { 0.0 }
                if ($ratio -gt 0.12) {
                    # Wiki slot icon columns are stable as occupancy markers.
                    $levels.Add(1)
                }
            }

            return @($levels)
        }
        finally {
            $bmp.Dispose()
        }
    }
    catch {
        return @()
    }
    finally {
        if (Test-Path $tempImg) {
            Remove-Item $tempImg -Force -ErrorAction SilentlyContinue
        }
    }
}

function Parse-SkillRowsFromPage {
    param($PageData)

    if (-not $PageData.page -or [string]::IsNullOrWhiteSpace($PageData.page.jsonContent)) {
        return @()
    }

    if (-not ($PageData.page.jsonContent -is [string])) {
        return @()
    }

    $blocks = $PageData.page.jsonContent | ConvertFrom-Json
    if ($null -eq $blocks) {
        return @()
    }

    if (-not ($blocks -is [System.Collections.IEnumerable])) {
        $blocks = @($blocks)
    }

    $allHtml = ""
    foreach ($b in $blocks) {
        if ($b.data) {
            $allHtml += $b.data + "`n"
        }
    }

    $start = $allHtml.IndexOf($MARKER_SKILLS)
    $end = $allHtml.IndexOf($MARKER_DEFENSE)
    if ($start -lt 0 -or $end -le $start) {
        return @()
    }

    $skillSection = $allHtml.Substring($start, $end - $start)
    $tableMatch = [regex]::Match($skillSection, "(?is)<table[^>]*>.*?</table>")
    if (-not $tableMatch.Success) {
        return @()
    }

    $rows = New-Object System.Collections.Generic.List[object]
    $trMatches = [regex]::Matches($tableMatch.Value, "(?is)<tr[^>]*>(?<row>.*?)</tr>")
    foreach ($tr in $trMatches) {
        $cells = [regex]::Matches($tr.Groups["row"].Value, "(?is)<td[^>]*>(?<cell>.*?)</td>")
        if ($cells.Count -lt 3) {
            continue
        }

        $nameZh = Strip-Html $cells[0].Groups["cell"].Value
        if ([string]::IsNullOrWhiteSpace($nameZh) -or $nameZh -eq $HEADER_EQUIP_NAME) {
            continue
        }

        $slotHtml = $cells[1].Groups["cell"].Value
        $slotMatch = [regex]::Match($slotHtml, "https://img1\.gamersky\.com/upimg/users/\d{4}/\d{2}/\d{2}/small_\d+\.jpg")
        $slotUrl = if ($slotMatch.Success) { $slotMatch.Value } else { "" }
        $slots = Get-SlotsFromSmallImage -ImageUrl $slotUrl

        $skillHtml = $cells[2].Groups["cell"].Value
        $skillText = Decode-Html $skillHtml
        $skillText = [regex]::Replace($skillText, "(?is)<br\s*/?>", "`n")
        $skillText = [regex]::Replace($skillText, "(?is)<[^>]+>", " ")
        $skillText = [regex]::Replace($skillText, "\s+", " ")

        $skillPoints = @{}
        $skillMatches = [regex]::Matches($skillText, "(?<name>[^\s][^L]{0,40}?)\s*L[Vv]\.?(?<lv>\d+)")
        foreach ($sm in $skillMatches) {
            $skillNameZh = $sm.Groups["name"].Value.Trim()
            $lv = [int]$sm.Groups["lv"].Value
            if ([string]::IsNullOrWhiteSpace($skillNameZh) -or $lv -le 0) {
                continue
            }
            $skillPoints[$skillNameZh] = $lv
        }

        if ($skillPoints.Count -eq 0) {
            continue
        }

        $rows.Add([pscustomobject]@{
            nameZh = $nameZh
            part = Resolve-Part -EquipmentName $nameZh
            slots = @($slots)
            rarity = 10
            skillPointsByZh = $skillPoints
        })
    }

    return $rows.ToArray()
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

Write-Host "[wiki-import] loading catalog page: $CatalogUrl"
$catalog = Get-PageDataObject -Url $CatalogUrl
if (-not $catalog.childPostSimpleJsonContents -or $catalog.childPostSimpleJsonContents.Count -eq 0) {
    throw "No childPostSimpleJsonContents found under catalog: $CatalogUrl"
}

$entries = @($catalog.childPostSimpleJsonContents)
Write-Host "[wiki-import] discovered pages: $($entries.Count)"

$equipmentByName = @{}
$skillMaxByZh = @{}
$parsedPages = 0
$skippedPages = 0

foreach ($entry in $entries) {
    $pageId = [int]$entry.pageId
    $url = "https://wiki.gamersky.com/2/3110/$pageId"

    try {
        $pd = Get-PageDataObject -Url $url
        $rows = @(Parse-SkillRowsFromPage -PageData $pd)
        if ($rows.Count -eq 0) {
            $skippedPages += 1
            Start-Sleep -Milliseconds $RequestDelayMs
            continue
        }

        foreach ($r in $rows) {
            $equipmentByName[$r.nameZh] = $r
            foreach ($kv in (Get-SkillEntriesFromMap -Map $r.skillPointsByZh)) {
                $skillNameZh = [string]$kv.nameZh
                $lv = [int]$kv.level
                if (-not $skillMaxByZh.ContainsKey($skillNameZh)) {
                    $skillMaxByZh[$skillNameZh] = $lv
                }
                else {
                    $skillMaxByZh[$skillNameZh] = [Math]::Max($skillMaxByZh[$skillNameZh], $lv)
                }
            }
        }

        $parsedPages += 1
    }
    catch {
        Write-Host "[wiki-import][warn] page parse failed: $url"
        Write-Host "[wiki-import][warn] reason: $($_.Exception.Message)"
        $skippedPages += 1
    }

    Start-Sleep -Milliseconds $RequestDelayMs
}

Write-Host "[wiki-import] parsed pages: $parsedPages, skipped: $skippedPages"
Write-Host "[wiki-import] equipment rows prepared: $($equipmentByName.Count), skills prepared: $($skillMaxByZh.Count)"

if ($equipmentByName.Count -eq 0) {
    throw "No equipment rows parsed from wiki catalog."
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

$skillRows = New-Object System.Collections.Generic.List[object]
foreach ($skillNameZh in ($skillMaxByZh.Keys | Sort-Object)) {
    $skillRows.Add([pscustomobject]@{
        code = Get-SkillCode -SkillNameZh $skillNameZh
        nameZh = $skillNameZh
        maxLevel = [int]$skillMaxByZh[$skillNameZh]
    })
}

if ($skillRows.Count -gt 0) {
    $sql.Add("WITH numbered AS (")
    $sql.Add("  SELECT ROW_NUMBER() OVER (ORDER BY x.code) AS rn, x.code, x.name_zh, x.max_level")
    $sql.Add("  FROM (")
    foreach ($sr in $skillRows) {
        $safeCode = Escape-Sql $sr.code
        $safeNameZh = Escape-Sql $sr.nameZh
        $maxLv = [int]$sr.maxLevel
        $sql.Add("    SELECT '$safeCode'::text AS code, '$safeNameZh'::text AS name_zh, $maxLv::int AS max_level UNION ALL")
    }
    $sql[$sql.Count - 1] = $sql[$sql.Count - 1].Substring(0, $sql[$sql.Count - 1].Length - " UNION ALL".Length)
    $sql.Add("  ) x")
    $sql.Add("), base AS (")
    $sql.Add("  SELECT COALESCE(MAX(id),0) AS max_id FROM mhr_skills")
    $sql.Add(")")
    $sql.Add("INSERT INTO mhr_skills(id, code, name, name_zh, max_level)")
    $sql.Add("SELECT base.max_id + numbered.rn, numbered.code, numbered.name_zh, numbered.name_zh, GREATEST(numbered.max_level,1)")
    $sql.Add("FROM numbered CROSS JOIN base")
    $sql.Add("ON CONFLICT (code) DO UPDATE SET")
    $sql.Add("  name = EXCLUDED.name,")
    $sql.Add("  name_zh = EXCLUDED.name_zh,")
    $sql.Add("  max_level = GREATEST(mhr_skills.max_level, EXCLUDED.max_level);")

    $sql.Add("INSERT INTO mhr_skill_effects(skill_code, effect)")
    $sql.Add("SELECT s.code, '' FROM mhr_skills s")
    $sql.Add("WHERE s.code IN (")
    foreach ($sr in $skillRows) {
        $safeCode = Escape-Sql $sr.code
        $sql.Add("  '$safeCode',")
    }
    $sql[$sql.Count - 1] = $sql[$sql.Count - 1].TrimEnd(',')
    $sql.Add(")")
    $sql.Add("ON CONFLICT (skill_code) DO NOTHING;")
}

foreach ($eqName in ($equipmentByName.Keys | Sort-Object)) {
    $eq = $equipmentByName[$eqName]

    $nameZh = [string]$eq.nameZh
    $part = [string]$eq.part
    $rarity = [int]$eq.rarity
    $slotsCsv = (($eq.slots | ForEach-Object { [string]$_ }) -join ',')

    $id = Get-DeterministicId -Key ("wiki|" + $nameZh + "|" + $part)

    $safeNameZh = Escape-Sql $nameZh
    $safePart = Escape-Sql $part
    $safeSlots = Escape-Sql $slotsCsv

    $sql.Add("INSERT INTO mhr_equipments(id, name, name_zh, part, rarity, slots_csv)")
    $sql.Add("VALUES ($id, '$safeNameZh', '$safeNameZh', '$safePart', $rarity, '$safeSlots')")
    $sql.Add("ON CONFLICT (id) DO UPDATE SET")
    $sql.Add("  name = EXCLUDED.name,")
    $sql.Add("  name_zh = EXCLUDED.name_zh,")
    $sql.Add("  part = EXCLUDED.part,")
    $sql.Add("  rarity = EXCLUDED.rarity,")
    $sql.Add("  slots_csv = EXCLUDED.slots_csv;")

    $sql.Add("DELETE FROM mhr_equipment_skill_points WHERE equipment_id = $id;")
    $sql.Add("DELETE FROM mhr_equipment_weapon_types WHERE equipment_id = $id;")

    foreach ($sp in (Get-SkillEntriesFromMap -Map $eq.skillPointsByZh)) {
        $skillNameZh = [string]$sp.nameZh
        $points = [int]$sp.level
        $skillCode = Get-SkillCode -SkillNameZh $skillNameZh
        $safeSkillCode = Escape-Sql $skillCode
        $sql.Add("INSERT INTO mhr_equipment_skill_points(equipment_id, skill_code, points) VALUES ($id, '$safeSkillCode', $points) ON CONFLICT (equipment_id, skill_code) DO UPDATE SET points = EXCLUDED.points;")
    }

    foreach ($wt in @("LONG_SWORD", "GREAT_SWORD", "BOW")) {
        $sql.Add("INSERT INTO mhr_equipment_weapon_types(equipment_id, weapon_type) VALUES ($id, '$wt') ON CONFLICT (equipment_id, weapon_type) DO NOTHING;")
    }
}

$sql.Add("COMMIT;")

$tempSql = Join-Path $env:TEMP ("mhr_wiki_auto_import_" + [guid]::NewGuid().ToString("N") + ".sql")
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($tempSql, ($sql -join [Environment]::NewLine), $utf8NoBom)

try {
    Write-Host "[wiki-import] applying SQL patch: $tempSql"
    & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -f $tempSql
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to apply wiki import SQL."
    }

    $summary = @(& psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -At -F '|' -c "SELECT COUNT(*)::text, COUNT(DISTINCT skill_code)::text FROM mhr_equipment_skill_points WHERE equipment_id IN (SELECT id FROM mhr_equipments WHERE id >= 760000000);")
    if ($LASTEXITCODE -eq 0 -and $summary.Length -gt 0) {
        $parts = $summary[0].Split('|')
        Write-Host "[wiki-import] skill point rows (id>=760000000): $($parts[0]), distinct skills: $($parts[1])"
    }

    Write-Host "[wiki-import] done"
}
finally {
    if (Test-Path $tempSql) {
        Remove-Item $tempSql -Force -ErrorAction SilentlyContinue
    }
}
