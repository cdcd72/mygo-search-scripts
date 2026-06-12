# MyGO 表情包搜尋腳本

提供一個簡單的 PowerShell 腳本，用來從 MyGO 表情包 API 搜尋圖片，並輸出每張圖片的 alt 文字與圖片 URL。

## 專案內容

- `src/mygo-search.ps1`：主搜尋腳本

## 功能說明

此腳本支援兩種使用方式：

1. 搜尋指定關鍵字的表情包
2. 隨機取得指定數量的表情包

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
- 如果沒有找到結果，腳本會顯示提示訊息而不是報錯

## 授權

本專案採用 MIT License，詳見 [LICENSE](LICENSE)。

## 特別銘謝

感謝這個 [miyago9267/MyGO-Searcher: MyGO表情包搜尋器](https://github.com/miyago9267/MyGO-Searcher) 專案讓我們有 MyGO API 可以運用。
