# AGENTS.md

## 專案概觀

這是一個單檔案的 PowerShell 7+ CLI 工具（`src/mygo-search.ps1`），透過呼叫公開的
MyGO-Searcher API（`https://mygo.miyago9267.com/api/v1`）來搜尋或隨機取得 MyGO
動畫表情包，並輸出每筆結果的 alt 文字與圖片 URL。

本儲存庫沒有建置、測試、lint 或套件管理工具——僅有此腳本、README、LICENSE
（MIT）以及一份 AI 協作盡職聲明文件。

## 執行腳本

```powershell
.\src\mygo-search.ps1 "春日影"          # 關鍵字搜尋
.\src\mygo-search.ps1 "春日影" -Fuzzy   # 模糊搜尋
.\src\mygo-search.ps1 -Random -Count 3  # 隨機取圖
```

沒有自動化測試；驗證變更時，請直接對正式 API 執行腳本，涵蓋搜尋、模糊搜尋、
隨機取圖以及下方列出的錯誤情境。

## 腳本結構（`src/mygo-search.ps1`）

此腳本是線性流程而非模組，修改時請維持相同結構：

1. **參數驗證**——`-Random` 與搜尋關鍵字互斥，且兩者必須擇一提供。錯誤訊息透過
   `Write-Error` 輸出至 stderr，並搭配 `Write-Host` 輸出黃色用法提示，最後以
   `return` 結束（不拋出例外、不使用結束代碼）。
2. **URL 組成**——依情境組出 `/images/random?count=` 或
   `/images/search?q=&fuzzy=` 兩種 `$BaseUrl` 端點，關鍵字以
   `[Uri]::EscapeDataString` 進行 URL 編碼。
3. **API 呼叫**——以 try/catch 包裹 `Invoke-RestMethod`，逾時設為 15 秒，錯誤一律
   透過 `Write-Error` 回報（不再往外拋出）。
4. **輸出處理**——逐一走訪 `$Response.data`，依序輸出 `[alt 文字]` 與圖片
   URL；若結果為空或 null，則改以黃色文字提示「找不到結果」，而非報錯。

所有面向使用者的字串、註解及文件註解（`.SYNOPSIS`/`.DESCRIPTION` 等）一律使用
正體中文（zh-TW）撰寫，新增的輸出與文件請維持此慣例。

## 參考

- [MyGO-Searcher API 文件](https://github.com/miyago9267/MyGO-Searcher/blob/main/docs/API.md)
