param(
    [int]$StartPage = 1,
    [int]$EndPage = 127,
    [string]$OutputJsonPath = "data/mhr/gamersky_armor.json",
    [switch]$DisableSlotParsing,
    [bool]$IncludeSunbreakDlc = $true,
    [string]$HandbookUrl = "https://www.gamersky.com/z/mhrise/handbook/",
    [string[]]$ExtraPageUrls = @()
)

$ErrorActionPreference = "Stop"

# Unicode escapes keep the script ASCII-safe across shell encodings.
function Decode-UnicodeLiteral {
    param([string]$Text)

    return [regex]::Replace($Text, "\\u([0-9a-fA-F]{4})", {
        param($m)
        return [char][int]::Parse($m.Groups[1].Value, [System.Globalization.NumberStyles]::HexNumber)
    })
}

$MARKER_MATERIALS = Decode-UnicodeLiteral "\u9632\u5177\u5236\u4f5c\u6750\u6599\u5982\u4e0b"
$MARKER_STATS = Decode-UnicodeLiteral "\u9632\u5177\u5c5e\u6027\u5982\u4e0b"
$MARKER_SKILLS = Decode-UnicodeLiteral "\u9632\u5177\u6280\u80fd\u5982\u4e0b"
$MARKER_SLOTS = Decode-UnicodeLiteral "\u9632\u5177\u5d4c\u5b54\u5982\u4e0b"

$global:SlotTemplates = $null

function Get-PageUrl {
    param([int]$Page)
    if ($Page -eq 1) {
        return "https://www.gamersky.com/handbook/202103/1375357.shtml"
    }
    return "https://www.gamersky.com/handbook/202103/1375357_${Page}.shtml"
}

function Get-HtmlContent {
    param([string]$Url)

    $tempHtml = Join-Path $env:TEMP ("mhr_armor_html_" + [guid]::NewGuid().ToString("N") + ".html")
    try {
        Invoke-WebRequest -Uri $Url -UseBasicParsing -OutFile $tempHtml
        $bytes = [System.IO.File]::ReadAllBytes($tempHtml)

        $asciiProbe = [System.Text.Encoding]::ASCII.GetString($bytes)
        $charsetMatch = [regex]::Match($asciiProbe, '(?i)charset\s*=\s*["'']?([a-z0-9\-_]+)')
        $charset = if ($charsetMatch.Success) { $charsetMatch.Groups[1].Value.ToLowerInvariant() } else { "" }

        if ($charset -match "utf-8") {
            return [System.Text.Encoding]::UTF8.GetString($bytes)
        }
        if ($charset -match "gb2312|gbk|gb18030") {
            return [System.Text.Encoding]::GetEncoding("GB18030").GetString($bytes)
        }

        $utf8Text = [System.Text.Encoding]::UTF8.GetString($bytes)
        if ($utf8Text -match "\u9632\u5177|\u66D9\u5149|\u602A\u7269\u730E\u4EBA") {
            return $utf8Text
        }
        return [System.Text.Encoding]::GetEncoding("GB18030").GetString($bytes)
    }
    finally {
        if (Test-Path $tempHtml) {
            Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue
        }
    }
}

function Get-SunbreakArmorUrls {
    param([string]$Url)

    $html = Get-HtmlContent -Url $Url
    $sectionPattern = "(?is)\u66D9\u5149DLC\u9632\u5177\u56FE\u9274(?<block>.*?)(?:\u66D9\u5149DLC\u914D\u88C5|\u66D9\u5149DLC\u95EE\u9898\u89E3\u51B3)"
    $sectionMatch = [regex]::Match($html, $sectionPattern)

    if (-not $sectionMatch.Success) {
        Write-Host "[import][warn] unable to locate Sunbreak armor module in handbook page: $Url"
        return @()
    }

    $block = $sectionMatch.Groups["block"].Value
    $urlMatches = [regex]::Matches($block, "https://www\.gamersky\.com/handbook/\d{6}/\d+\.shtml", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $result = New-Object System.Collections.Generic.List[string]
    foreach ($m in $urlMatches) {
        $u = $m.Value.Trim()
        if (-not [string]::IsNullOrWhiteSpace($u) -and -not $result.Contains($u)) {
            $result.Add($u)
        }
    }

    return @($result)
}

function Get-Rarity {
    param([string]$Html)
    $match = [regex]::Match($Html, "\u7b2c\d+\u9875\uff1aR(?<r>\d+)")
    if ($match.Success) {
        return [int]$match.Groups["r"].Value
    }
    return 1
}

function Extract-Table {
    param(
        [string]$Html,
        [string]$Marker
    )

    $pattern = [regex]::Escape($Marker) + ".*?<table[^>]*>(?<table>.*?)</table>"
    $match = [regex]::Match($Html, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $match.Success) {
        return $null
    }
    return $match.Groups["table"].Value
}

function Parse-TableRows {
    param([string]$TableHtml)

    if ([string]::IsNullOrWhiteSpace($TableHtml)) {
        return @()
    }

    $rows = @()
    $rowMatches = [regex]::Matches($TableHtml, "<tr[^>]*>(?<row>.*?)</tr>", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    foreach ($rowMatch in $rowMatches) {
        $cells = @()
        $cellMatches = [regex]::Matches($rowMatch.Groups["row"].Value, "<t[dh][^>]*>(?<cell>.*?)</t[dh]>", [System.Text.RegularExpressions.RegexOptions]::Singleline)
        foreach ($cellMatch in $cellMatches) {
            $value = $cellMatch.Groups["cell"].Value
            $value = $value -replace "<br\\s*/?>", "`n"
            $value = $value -replace "<[^>]+>", ""
            $value = [System.Net.WebUtility]::HtmlDecode($value).Trim()
            $cells += $value
        }
        if ($cells.Count -gt 0) {
            $rows += ,$cells
        }
    }
    return $rows
}

function Get-SlotImageUrl {
    param([string]$Html)

    $pattern = [regex]::Escape($MARKER_SLOTS) + '.*?<a[^>]*href="(?<href>[^\"]+)"'
    $match = [regex]::Match($Html, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $match.Success) {
        return $null
    }

    $href = $match.Groups["href"].Value
    if ($href -match '\?(https?://[^\s\"]+\.jpg)') {
        return $matches[1]
    }
    if ($href -match 'https?://[^\s\"]+\.jpg') {
        return $href
    }

    return $null
}

function Get-SlotRect {
    param(
        [int]$Row,
        [int]$Col
    )

    # All slot images currently use a 411x226 fixed layout.
    return @{
        X = 269 + (($Col - 1) * 38)
        Y = 47 + (($Row - 1) * 37)
        W = 22
        H = 22
    }
}

function Get-BinarySymbol {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [hashtable]$Rect
    )

    $bits = New-Object System.Collections.Generic.List[int]
    for ($y = $Rect.Y; $y -lt ($Rect.Y + $Rect.H); $y++) {
        for ($x = $Rect.X; $x -lt ($Rect.X + $Rect.W); $x++) {
            $p = $Bitmap.GetPixel($x, $y)
            $gray = [int](($p.R + $p.G + $p.B) / 3)
            if ($gray -lt 165) {
                $bits.Add(1)
            }
            else {
                $bits.Add(0)
            }
        }
    }
    return ,$bits.ToArray()
}

function Get-SymbolDistance {
    param(
        [int[]]$A,
        [int[]]$B
    )

    $diff = 0
    for ($i = 0; $i -lt $A.Length; $i++) {
        if ($A[$i] -ne $B[$i]) {
            $diff += 1
        }
    }
    return $diff
}

function Ensure-SlotTemplates {
    if ($global:SlotTemplates -ne $null) {
        return
    }

    Add-Type -AssemblyName System.Drawing
    $cacheDir = "data/mhr/.cache"
    if (-not (Test-Path $cacheDir)) {
        New-Item -Path $cacheDir -ItemType Directory -Force | Out-Null
    }

    $refNoSlotsPath = Join-Path $cacheDir "slot_ref_noslots.jpg"
    $refMixedPath = Join-Path $cacheDir "slot_ref_mixed.jpg"

    if (-not (Test-Path $refNoSlotsPath)) {
        Invoke-WebRequest -Uri "https://img1.gamersky.com/image2022/06/20220622_lkd_510_1/1180.jpg" -OutFile $refNoSlotsPath
    }
    if (-not (Test-Path $refMixedPath)) {
        Invoke-WebRequest -Uri "https://img1.gamersky.com/image2022/06/20220623_lkd_510_1/17474.jpg" -OutFile $refMixedPath
    }

    function Build-TemplateFromSamples {
        param([int[][]]$Samples)

        $length = $Samples[0].Length
        $result = New-Object int[] $length
        for ($i = 0; $i -lt $length; $i++) {
            $ones = 0
            foreach ($sample in $Samples) {
                if ($sample[$i] -eq 1) {
                    $ones += 1
                }
            }
            if ($ones -ge [Math]::Ceiling($Samples.Count / 2.0)) {
                $result[$i] = 1
            }
            else {
                $result[$i] = 0
            }
        }
        return ,$result
    }

    $bmpNoSlots = [System.Drawing.Bitmap]::new($refNoSlotsPath)
    $bmpMixed = [System.Drawing.Bitmap]::new($refMixedPath)

    try {
        # Reference set:
        # - page 1 row1 col1 is '-'
        # - page 123 row1 col1 is '1'
        # - page 123 row3 col1 is '2'
        # - page 123 row4 col1 is '3'
        $dashSamples = @(
            (Get-BinarySymbol -Bitmap $bmpNoSlots -Rect (Get-SlotRect -Row 1 -Col 1)),
            (Get-BinarySymbol -Bitmap $bmpNoSlots -Rect (Get-SlotRect -Row 2 -Col 1)),
            (Get-BinarySymbol -Bitmap $bmpNoSlots -Rect (Get-SlotRect -Row 3 -Col 1))
        )
        $oneSamples = @(
            (Get-BinarySymbol -Bitmap $bmpMixed -Rect (Get-SlotRect -Row 1 -Col 1)),
            (Get-BinarySymbol -Bitmap $bmpMixed -Rect (Get-SlotRect -Row 2 -Col 1)),
            (Get-BinarySymbol -Bitmap $bmpMixed -Rect (Get-SlotRect -Row 5 -Col 1))
        )

        $global:SlotTemplates = @{
            DASH = Build-TemplateFromSamples -Samples $dashSamples
            ONE  = Build-TemplateFromSamples -Samples $oneSamples
            TWO  = Get-BinarySymbol -Bitmap $bmpMixed -Rect (Get-SlotRect -Row 3 -Col 1)
            THREE = Get-BinarySymbol -Bitmap $bmpMixed -Rect (Get-SlotRect -Row 4 -Col 1)
        }
    }
    finally {
        $bmpNoSlots.Dispose()
        $bmpMixed.Dispose()
    }
}

function Classify-SlotSymbol {
    param([int[]]$Symbol)

    $scores = @{
        DASH = Get-SymbolDistance -A $Symbol -B $global:SlotTemplates.DASH
        ONE = Get-SymbolDistance -A $Symbol -B $global:SlotTemplates.ONE
        TWO = Get-SymbolDistance -A $Symbol -B $global:SlotTemplates.TWO
        THREE = Get-SymbolDistance -A $Symbol -B $global:SlotTemplates.THREE
    }

    $best = $scores.GetEnumerator() | Sort-Object -Property Value | Select-Object -First 1
    switch ($best.Key) {
        "ONE" { return 1 }
        "TWO" { return 2 }
        "THREE" { return 3 }
        default { return 0 }
    }
}

function Parse-SlotsFromImage {
    param(
        [string]$ImageUrl,
        [string[]]$EquipmentNames
    )

    $result = @{}
    if ([string]::IsNullOrWhiteSpace($ImageUrl) -or $EquipmentNames.Count -eq 0) {
        return $result
    }

    Ensure-SlotTemplates
    Add-Type -AssemblyName System.Drawing

    $tempPath = Join-Path "data/mhr/.cache" ("slot_runtime_" + [Guid]::NewGuid().ToString("N") + ".jpg")
    Invoke-WebRequest -Uri $ImageUrl -OutFile $tempPath

    $bmp = [System.Drawing.Bitmap]::new($tempPath)
    try {
        for ($row = 1; $row -le [Math]::Min(5, $EquipmentNames.Count); $row++) {
            $slots = New-Object System.Collections.Generic.List[int]
            for ($col = 1; $col -le 3; $col++) {
                $bits = Get-BinarySymbol -Bitmap $bmp -Rect (Get-SlotRect -Row $row -Col $col)
                $level = Classify-SlotSymbol -Symbol $bits
                if ($level -gt 0) {
                    $slots.Add($level)
                }
            }
            $result[$EquipmentNames[$row - 1]] = @($slots)
        }
    }
    finally {
        $bmp.Dispose()
        Remove-Item -Path $tempPath -Force -ErrorAction SilentlyContinue
    }

    return $result
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

function New-SkillCode {
    param([string]$SkillNameZh)

    $md5 = [System.Security.Cryptography.MD5]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($SkillNameZh)
        $hash = $md5.ComputeHash($bytes)
        $hex = [System.BitConverter]::ToString($hash).Replace("-", "")
        return "ZH_" + $hex.Substring(0, 10)
    }
    finally {
        $md5.Dispose()
    }
}

function Parse-SkillPoints {
    param(
        [string]$SkillText,
        [hashtable]$SkillCodeByZh,
        [System.Collections.ArrayList]$SkillCatalog
    )

    $result = @{}
    if ([string]::IsNullOrWhiteSpace($SkillText)) {
        return $result
    }

    $matches = [regex]::Matches($SkillText, "(?<name>[\u4e00-\u9fa5A-Za-z\-\u00b7]+)\s*LV(?<lv>\d+)")
    foreach ($m in $matches) {
        $nameZh = $m.Groups["name"].Value.Trim()
        $level = [int]$m.Groups["lv"].Value
        if ([string]::IsNullOrWhiteSpace($nameZh)) {
            continue
        }

        if (-not $SkillCodeByZh.ContainsKey($nameZh)) {
            $code = New-SkillCode -SkillNameZh $nameZh
            $SkillCodeByZh[$nameZh] = $code
            [void]$SkillCatalog.Add([ordered]@{
                code = $code
                name = $nameZh
                nameZh = $nameZh
                maxLevel = [Math]::Max($level, 1)
            })
        }

        $codeRef = $SkillCodeByZh[$nameZh]
        if ($result.ContainsKey($codeRef)) {
            $result[$codeRef] = [Math]::Max($result[$codeRef], $level)
        }
        else {
            $result[$codeRef] = $level
        }

        foreach ($skill in $SkillCatalog) {
            if ($skill.code -eq $codeRef -and $level -gt $skill.maxLevel) {
                $skill.maxLevel = $level
                break
            }
        }
    }

    return $result
}

$equipmentMap = @{}
$skillCodeByZh = @{}
$skillCatalog = New-Object System.Collections.ArrayList

$pageUrls = New-Object System.Collections.Generic.List[string]
for ($page = $StartPage; $page -le $EndPage; $page++) {
    $pageUrls.Add((Get-PageUrl -Page $page))
}

if ($IncludeSunbreakDlc) {
    $sunbreakUrls = Get-SunbreakArmorUrls -Url $HandbookUrl
    Write-Host "[import] Sunbreak DLC armor links discovered: $($sunbreakUrls.Count)"
    foreach ($u in $sunbreakUrls) {
        if (-not $pageUrls.Contains($u)) {
            $pageUrls.Add($u)
        }
    }
}

foreach ($u in $ExtraPageUrls) {
    if ([string]::IsNullOrWhiteSpace($u)) {
        continue
    }
    if (-not $pageUrls.Contains($u)) {
        $pageUrls.Add($u)
    }
}

for ($idx = 0; $idx -lt $pageUrls.Count; $idx++) {
    $url = $pageUrls[$idx]
    Write-Host "[import] Fetching page $($idx + 1)/$($pageUrls.Count): $url"

    try {
        $html = Get-HtmlContent -Url $url
    }
    catch {
        Write-Host "[import][warn] failed to fetch page: $url"
        Write-Host "[import][warn] reason: $($_.Exception.Message)"
        Start-Sleep -Milliseconds 150
        continue
    }

    $rarity = Get-Rarity -Html $html
    if ($rarity -lt 1) {
        $rarity = 1
    }
    if ($rarity -eq 1 -and $url -match "https://www\.gamersky\.com/handbook/20(22|23|24)") {
        # Sunbreak pages usually do not expose the legacy page-index rarity marker.
        $rarity = 8
    }

    $materialsTable = Extract-Table -Html $html -Marker $MARKER_MATERIALS
    $statsTable = Extract-Table -Html $html -Marker $MARKER_STATS
    $skillsTable = Extract-Table -Html $html -Marker $MARKER_SKILLS

    $materialRows = Parse-TableRows -TableHtml $materialsTable
    $statRows = Parse-TableRows -TableHtml $statsTable
    $skillRows = Parse-TableRows -TableHtml $skillsTable

    if ($materialRows.Count -le 1 -and $statRows.Count -le 1 -and $skillRows.Count -le 1) {
        Write-Host "[import][warn] skipped non-structured page: $url"
        Start-Sleep -Milliseconds 150
        continue
    }

    $equipmentNamesInOrder = @()
    $first = $true
    foreach ($row in $materialRows) {
        if ($first) { $first = $false; continue }
        if ($row.Count -lt 2) { continue }
        $equipmentNamesInOrder += $row[0]
    }

    $slotMapForPage = @{}
    if (-not $DisableSlotParsing) {
        $slotImageUrl = Get-SlotImageUrl -Html $html
        if ($slotImageUrl) {
            try {
                $slotMapForPage = Parse-SlotsFromImage -ImageUrl $slotImageUrl -EquipmentNames $equipmentNamesInOrder
            }
            catch {
                Write-Host "[import][warn] slot parse failed on page url=$url : $($_.Exception.Message)"
            }
        }
    }

    $first = $true
    foreach ($row in $materialRows) {
        if ($first) { $first = $false; continue }
        if ($row.Count -lt 2) { continue }
        $nameZh = $row[0]
        if (-not $equipmentMap.ContainsKey($nameZh)) {
            $equipmentMap[$nameZh] = [ordered]@{
                name = $nameZh
                nameZh = $nameZh
                part = Resolve-Part -EquipmentName $nameZh
                rarity = $rarity
                defense = 0
                fireRes = 0
                waterRes = 0
                thunderRes = 0
                iceRes = 0
                dragonRes = 0
                slots = @()
                skillPoints = @{}
                supportedWeaponTypes = @("LONG_SWORD", "GREAT_SWORD", "BOW")
                source = $url
            }
        }
        else {
            $equipmentMap[$nameZh].rarity = [Math]::Max([int]$equipmentMap[$nameZh].rarity, $rarity)
        }

        if ($slotMapForPage.ContainsKey($nameZh)) {
            $equipmentMap[$nameZh].slots = @($slotMapForPage[$nameZh])
        }
    }

    $first = $true
    foreach ($row in $statRows) {
        if ($first) { $first = $false; continue }
        if ($row.Count -lt 7) { continue }
        $nameZh = $row[0]
        if (-not $equipmentMap.ContainsKey($nameZh)) {
            $equipmentMap[$nameZh] = [ordered]@{
                name = $nameZh
                nameZh = $nameZh
                part = Resolve-Part -EquipmentName $nameZh
                rarity = $rarity
                defense = 0
                fireRes = 0
                waterRes = 0
                thunderRes = 0
                iceRes = 0
                dragonRes = 0
                slots = @()
                skillPoints = @{}
                supportedWeaponTypes = @("LONG_SWORD", "GREAT_SWORD", "BOW")
                source = $url
            }
        }

        $equipmentMap[$nameZh].defense = [int]$row[1]
        $equipmentMap[$nameZh].fireRes = [int]$row[2]
        $equipmentMap[$nameZh].waterRes = [int]$row[3]
        $equipmentMap[$nameZh].thunderRes = [int]$row[4]
        $equipmentMap[$nameZh].iceRes = [int]$row[5]
        $equipmentMap[$nameZh].dragonRes = [int]$row[6]
    }

    $first = $true
    foreach ($row in $skillRows) {
        if ($first) { $first = $false; continue }
        if ($row.Count -lt 2) { continue }

        $nameZh = $row[0]
        if (-not $equipmentMap.ContainsKey($nameZh)) {
            $equipmentMap[$nameZh] = [ordered]@{
                name = $nameZh
                nameZh = $nameZh
                part = Resolve-Part -EquipmentName $nameZh
                rarity = $rarity
                defense = 0
                fireRes = 0
                waterRes = 0
                thunderRes = 0
                iceRes = 0
                dragonRes = 0
                slots = @()
                skillPoints = @{}
                supportedWeaponTypes = @("LONG_SWORD", "GREAT_SWORD", "BOW")
                source = $url
            }
        }

        $equipmentMap[$nameZh].skillPoints = Parse-SkillPoints -SkillText $row[1] -SkillCodeByZh $skillCodeByZh -SkillCatalog $skillCatalog
    }

    Start-Sleep -Milliseconds 250
}

$equipments = @()
$nextId = 100000
foreach ($nameZh in ($equipmentMap.Keys | Sort-Object)) {
    $entry = $equipmentMap[$nameZh]
    $entry.id = $nextId
    $nextId += 1
    $equipments += $entry
}

$skills = @()
$skillId = 200000
foreach ($skill in ($skillCatalog | Sort-Object -Property nameZh)) {
    $skill.id = $skillId
    $skillId += 1
    $skills += $skill
}

$payload = [ordered]@{
    source = "gamersky"
    generatedAt = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    pageRange = "${StartPage}-${EndPage}"
    notes = @(
        "slots are parsed from slot images via fixed-layout symbol templates",
        "skills are extracted from zh text and use deterministic hash-based codes"
    )
    skills = $skills
    equipments = $equipments
}

$targetDir = Split-Path -Path $OutputJsonPath -Parent
if (-not (Test-Path -Path $targetDir)) {
    New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
}

$payload | ConvertTo-Json -Depth 12 | Set-Content -Path $OutputJsonPath -Encoding utf8

Write-Host "[import] OK -> $OutputJsonPath"
Write-Host "[import] skills: $($skills.Count), equipments: $($equipments.Count)"
