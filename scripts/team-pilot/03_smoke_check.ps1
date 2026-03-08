param(
    [ValidateSet("mhr", "expense")]
    [string]$Mode = "expense",
    [string]$BaseUrl = "http://localhost:8080"
)

$ErrorActionPreference = "Stop"

function Assert-Status200 {
    param([string]$Url)
    $status = (Invoke-WebRequest -Uri $Url -UseBasicParsing).StatusCode
    if ($status -ne 200) {
        throw "Expected 200 but got $status for $Url"
    }
}

if ($Mode -eq "mhr") {
    Write-Host "[smoke] MHR mode"
    Invoke-RestMethod -Uri "$BaseUrl/api/v1/skills" -Method Get | Out-Null

    $body = '{"weaponType":"LONG_SWORD","targetSkills":[{"skillCode":"ATTACK_BOOST","minLevel":4},{"skillCode":"WEAKNESS_EXPLOIT","minLevel":3}],"maxResults":5}'
    Invoke-RestMethod -Uri "$BaseUrl/api/v1/builds/generate" -Method Post -ContentType "application/json" -Body $body | Out-Null

    Assert-Status200 "$BaseUrl/"
}
else {
    Write-Host "[smoke] Expense mode"
    Invoke-RestMethod -Uri "$BaseUrl/api/v1/categories" -Method Get | Out-Null

    $createBody = '{"amount":48.50,"category":"FOOD","occurredAt":"2026-03-08","note":"Pilot"}'
    Invoke-RestMethod -Uri "$BaseUrl/api/v1/transactions" -Method Post -ContentType "application/json" -Body $createBody | Out-Null

    Invoke-RestMethod -Uri "$BaseUrl/api/v1/summaries/by-category?fromDate=2026-03-01&toDate=2026-03-31" -Method Get | Out-Null

    $badBody = '{"amount":0,"category":"FOOD","occurredAt":"2026-03-08","note":"bad"}'
    try {
        Invoke-RestMethod -Uri "$BaseUrl/api/v1/transactions" -Method Post -ContentType "application/json" -Body $badBody -ErrorAction Stop | Out-Null
        throw "Expected validation error for amount boundary but request succeeded"
    }
    catch {
        # Expected for boundary validation.
    }

    Assert-Status200 "$BaseUrl/expense.html"
}

Write-Host "[smoke] OK"
