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
.PARAMETER NoPreview
    是否停用圖片預覽視窗（預設會跳出視窗，加此參數則只輸出終端機文字）。
.EXAMPLE
    .\mygo-search.ps1 "春日影"
.EXAMPLE
    .\mygo-search.ps1 "春日影" -Fuzzy
.EXAMPLE
    .\mygo-search.ps1 -Random -Count 3
.EXAMPLE
    .\mygo-search.ps1 "春日影" -NoPreview
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
    [int]$Count = 1,

    [Parameter(Mandatory=$false)]
    [switch]$NoPreview
)

function Get-ImageFromUrl {
    <#
    .SYNOPSIS
        下載圖片並轉成 System.Drawing.Image 物件與原始位元組。
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url
    )

    try {
        $webClient = New-Object System.Net.WebClient
        $bytes = $webClient.DownloadData($Url)
        $ms = New-Object System.IO.MemoryStream($bytes, 0, $bytes.Length)
        $image = [System.Drawing.Image]::FromStream($ms)
        return [PSCustomObject]@{
            Image = $image
            Bytes = $bytes
        }
    }
    catch {
        Write-Error "下載圖片失敗（$Url）：$($_.Exception.Message)"
        return $null
    }
}

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

# 5. 彈出圖片預覽視窗（可用 -NoPreview 停用）
if (-not $NoPreview) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "MyGO 表情包預覽"
    $form.Width = ($Count -gt 2) ? 425 : 410
    $form.Height = ($Count -gt 2) ? 720 : 635
    $form.StartPosition = "CenterScreen"

    $flowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $flowPanel.Dock = "Fill"
    $flowPanel.AutoScroll = $true
    $flowPanel.FlowDirection = "TopDown"
    $flowPanel.WrapContents = $false
    $form.Controls.Add($flowPanel)

    foreach ($item in $Response.data) {
        $result = Get-ImageFromUrl -Url $item.url
        if ($null -eq $result) {
            continue
        }

        $itemPanel = New-Object System.Windows.Forms.Panel
        $itemPanel.Width = 380
        $itemPanel.Height = 285
        $itemPanel.Margin = New-Object System.Windows.Forms.Padding(5)

        $pictureBox = New-Object System.Windows.Forms.PictureBox
        $pictureBox.Width = 370
        $pictureBox.Height = 208
        $pictureBox.Top = 0
        $pictureBox.Left = 8
        $pictureBox.SizeMode = "Zoom"
        $pictureBox.Image = $result.Image
        $itemPanel.Controls.Add($pictureBox)

        $label = New-Object System.Windows.Forms.Label
        $label.Text = $item.alt
        $label.Top = 210
        $label.Left = 8
        $label.Width = 370
        $label.Height = 30
        $label.TextAlign = "MiddleCenter"
        $itemPanel.Controls.Add($label)

        $downloadButton = New-Object System.Windows.Forms.Button
        $downloadButton.Text = "下載"
        $downloadButton.Top = 245
        $downloadButton.Left = 8
        $downloadButton.Width = 370
        $itemPanel.Tag = $result.Bytes
        $downloadButton.Tag = @{ Bytes = $result.Bytes; Alt = $item.alt; Url = $item.url }

        $downloadButton.Add_Click({
            param($sender, $eventArgs)

            $tagData = $sender.Tag
            $extension = [System.IO.Path]::GetExtension($tagData.Url)
            if ([string]::IsNullOrWhiteSpace($extension)) {
                $extension = ".jpg"
            }

            $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
            $safeName = ($tagData.Alt.ToCharArray() | ForEach-Object {
                if ($invalidChars -contains $_) { "_" } else { $_ }
            }) -join ""
            if ([string]::IsNullOrWhiteSpace($safeName)) {
                $safeName = "mygo表情包"
            }

            $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
            $saveDialog.FileName = "$safeName$extension"
            $saveDialog.Filter = "圖片檔案|*$extension|所有檔案|*.*"

            if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                [System.IO.File]::WriteAllBytes($saveDialog.FileName, $tagData.Bytes)
            }
        })
        $itemPanel.Controls.Add($downloadButton)

        $flowPanel.Controls.Add($itemPanel)
    }

    $form.ShowDialog() | Out-Null
    $form.Dispose()
}
