- [x] 在 `src\mygo-search.ps1` 開頭加入 `Add-Type -AssemblyName System.Windows.Forms` 與 `System.Drawing`（若尚未載入）
- [x] 新增一個函式：輸入圖片 URL，下載圖片位元組並轉成 `System.Drawing.Image` 物件（失敗時要能捕捉例外，不中斷整體流程）
- [x] 建立主視窗（`Form`），內含可捲動的容器（例如 `FlowLayoutPanel`，`AutoScroll = $true`），視窗大小要能容納多張圖片並可調整
- [x] 針對 `$Response.data` 中每一筆項目，建立一個區塊：`PictureBox`（顯示圖片，`SizeMode = Zoom`）+ `Label`（顯示 alt 文字）+ `Button`（下載）
- [x] 實作下載按鈕的點擊事件：跳出 `SaveFileDialog`，預設檔名帶入該圖片的 alt 文字，使用者確認路徑後將圖片位元組寫入該路徑
- [x] 在既有的第 4 步「輸出處理」之後（終端機輸出完成後），呼叫 `$form.ShowDialog()` 顯示視窗；若 `$Response.data` 為空則跳過視窗，維持現有黃色提示
- [x] 視窗關閉後呼叫 `$form.Dispose()` 釋放資源，確認腳本能正常結束
- [x] 在 `param()` 區塊新增 `[switch]$NoPreview` 參數
- [x] 在「5. 彈出圖片預覽視窗」區塊外層加上判斷：`if (-not $NoPreview)` 才建立視窗與執行 `ShowDialog()`；有 `-NoPreview` 時直接略過，腳本在終端機輸出後就結束
- [x] 調整圖片卡片版面：縮小 `PictureBox` 高度使其比例更貼近實際圖片（避免 `Zoom` 模式產生過多垂直留白），並同步縮小 `itemPanel`／`Label`／`Button` 間距，讓卡片更緊湊

## 驗收條件

- 情境：使用者執行 `.\mygo-search.ps1 "春日影"` 且有搜尋結果時，終端機照舊輸出 alt 文字與 URL，同時跳出一個視窗，裡面顯示所有搜尋到的圖片與各自的 alt 文字
- 情境：使用者執行 `.\mygo-search.ps1 -Random -Count 3`，視窗中會顯示 3 張圖片，且視窗內容可以上下捲動
- 情境：使用者點擊某張圖片下方的「下載」按鈕，會跳出「另存新檔」對話框，預設檔名為該圖片的 alt 文字；使用者選好路徑並儲存後，該路徑下會出現正確的圖片檔案
- 情境：使用者關閉視窗後，腳本執行結束，回到終端機提示字元
- 情境：搜尋不到任何結果（或隨機取圖失敗）時，維持原本的黃色提示文字，不會跳出空視窗
- 情境：使用者執行 `.\mygo-search.ps1 "春日影" -NoPreview`，終端機照舊輸出 alt 文字與 URL，但不會跳出任何視窗
- 情境：使用者執行 `.\mygo-search.ps1 -Random -Count 2` 時（不加 `-NoPreview`），維持跳出視窗，確認預設行為沒有改變
- 情境：視窗中每張圖片卡片的圖片下緣到 alt 文字之間，不應出現明顯大片空白，卡片整體看起來緊湊
