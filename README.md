# MyGO 表情包搜尋腳本

提供一個簡單的 PowerShell 腳本，用來從 MyGO 表情包 API 搜尋圖片，並輸出每張圖片的 alt 文字與圖片 URL。

## 專案內容

- `src/mygo-search.ps1`：主搜尋腳本

## 功能說明

此腳本支援兩種使用方式：

1. 搜尋指定關鍵字的表情包
2. 隨機取得指定數量的表情包

搜尋成功後，除了在終端機輸出文字結果，預設還會跳出一個圖片預覽視窗，顯示這次取得的所有圖片，每張圖片都有一個「下載」按鈕，可另存新檔到本機。關閉視窗即結束本次執行；若不需要視窗，可加上 `-NoPreview` 停用。

## 需求

- PowerShell 7+
- 可存取 MyGO API

## 使用方式

### 1. 搜尋表情包

```powershell
.\src\mygo-search.ps1 "春日影"
```

### 2. 啟用模糊搜尋

```powershell
.\src\mygo-search.ps1 "春日影" -Fuzzy
```

### 3. 隨機取得表情包

```powershell
.\src\mygo-search.ps1 -Random -Count 3
```

### 4. 停用圖片預覽視窗

```powershell
.\src\mygo-search.ps1 "春日影" -NoPreview
```

## 圖片預覽視窗

預設情況下，搜尋或隨機取圖成功後會跳出一個可捲動的視窗，裡面顯示這次取得的所有圖片與對應的 alt 文字，每張圖片下方都有「下載」按鈕，點擊後會跳出「另存新檔」對話框，讓你選擇儲存路徑與檔名。關閉視窗即代表結束本次指令執行。若不需要跳出視窗（例如自動化腳本情境），可加上 `-NoPreview` 停用，僅輸出終端機文字。

## 輸出格式

腳本會逐筆輸出：

```text
[alt 文字]
圖片 URL
```

例如：

```text
[春日影]
https://example.com/image.jpg
```

## 注意事項

- `-Random` 與搜尋關鍵字不能同時使用
- `-Count` 必須大於 0
- 如果沒有找到結果，腳本會顯示提示訊息而不是報錯，也不會跳出預覽視窗
- 圖片預覽視窗依賴 Windows Forms，僅支援 Windows 環境

## 授權

本專案採用 MIT License，詳見 [LICENSE](LICENSE)。

## 特別銘謝

感謝這個 [miyago9267/MyGO-Searcher: MyGO表情包搜尋器](https://github.com/miyago9267/MyGO-Searcher) 專案讓我們有 MyGO API 可以運用。
