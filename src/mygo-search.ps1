<#
.SYNOPSIS
    MyGO 表情包搜尋腳本
.DESCRIPTION
    透過 MyGO-Searcher API 搜尋表情包，輸出 alt 文字與圖片 URL。
.PARAMETER Query
    搜尋關鍵字。
.PARAMETER Fuzzy
    是否啟用模糊搜尋。
.PARAMETER Random
    是否啟用隨機取圖。
.PARAMETER Count
    隨機取圖的數量（預設為 1）。
.EXAMPLE
    .\mygo-search.ps1 "春日影"
.EXAMPLE
    .\mygo-search.ps1 "春日影" -Fuzzy
.EXAMPLE
    .\mygo-search.ps1 -Random -Count 3
#>

[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Query,

    [Parameter(Mandatory=$false)]
    [switch]$Fuzzy,

    [Parameter(Mandatory=$false)]
    [switch]$Random,

    [Parameter(Mandatory=$false)]
    [int]$Count = 1
)

# 1. 參數驗證
if ($Random -and (-not [string]::IsNullOrWhiteSpace($Query))) {
    Write-Error "錯誤：不能同時指定搜尋關鍵字與隨機取圖。"
    Write-Host "用法說明：" -ForegroundColor Yellow
    Write-Host "  搜尋表情包: .\mygo-search.ps1 `"<關鍵字>`" [-Fuzzy]" -ForegroundColor White
    Write-Host "  隨機取圖:   .\mygo-search.ps1 -Random [-Count <數量>]" -ForegroundColor White
    return
}

if (-not $Random -and [string]::IsNullOrWhiteSpace($Query)) {
    Write-Error "錯誤：必須指定搜尋關鍵字，或使用 -Random 進行隨機取圖。"
    Write-Host "用法說明：" -ForegroundColor Yellow
    Write-Host "  搜尋表情包: .\mygo-search.ps1 `"<關鍵字>`" [-Fuzzy]" -ForegroundColor White
    Write-Host "  隨機取圖:   .\mygo-search.ps1 -Random [-Count <數量>]" -ForegroundColor White
    return
}

# 2. 建立 API 請求網址與參數
$BaseUrl = "https://mygo.miyago9267.com/api/v1"

if ($Random) {
    if ($Count -lt 1) {
        Write-Error "錯誤：隨機數量必須大於 0。"
        return
    }
    $Uri = "${BaseUrl}/images/random?count=${Count}"
} else {
    $EncodedQuery = [Uri]::EscapeDataString($Query)
    $FuzzyVal = if ($Fuzzy) { "true" } else { "false" }
    $Uri = "${BaseUrl}/images/search?q=${EncodedQuery}&fuzzy=${FuzzyVal}"
}

# 3. 發送請求並處理結果
try {
    $Response = Invoke-RestMethod -Uri $Uri -Method Get -TimeoutSec 15
}
catch {
    Write-Error "呼叫 API 失敗：$($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Error "伺服器回應狀態碼：$($_.Exception.Response.StatusCode)"
    }
    return
}

# 4. 輸出處理
if ($null -eq $Response -or $null -eq $Response.data -or $Response.data.Count -eq 0) {
    if ($Random) {
        Write-Host "未取得隨機表情包。" -ForegroundColor Yellow
    } else {
        Write-Host "找不到與「$Query」相關的表情包。" -ForegroundColor Yellow
    }
    return
}

foreach ($item in $Response.data) {
    # 輸出格式：
    # [alt 文字]
    # 圖片 URL
    Write-Host "[$($item.alt)]"
    Write-Host "$($item.url)"
}
