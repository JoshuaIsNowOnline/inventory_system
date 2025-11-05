# 🌐 Windows 網頁版上線指南

## 🎯 目標
將庫存管理系統部署為 Windows 電腦可訊問的網頁應用程式

## ✅ 前置條件
- ✅ 後端已部署到 Render: `https://inventory-system-api-wu21.onrender.com`
- ✅ 前端 API 已更新指向雲端服務
- ✅ Flutter 開發環境已安裝

---

## 🚀 步驟 1：構建網頁版應用

### 1️⃣ 切換到前端目錄
```bash
cd frontend/inventory_app
```

### 2️⃣ 清理並安裝依賴
```bash
flutter clean
flutter pub get
```

### 3️⃣ 構建生產版本
```bash
flutter build web --release
```

---

## 🌐 步驟 2：部署網頁版

### 方案 A：本地 HTTP 伺服器（測試用）
```bash
# 切換到構建目錄
cd build\web

# 啟動 Python HTTP 伺服器
python -m http.server 8080

# 或使用 Node.js
npx http-server -p 8080 -c-1
```

**訪問網址**: http://localhost:8080

### 方案 B：Netlify 免費託管（推薦）

1. **訪問 [Netlify](https://www.netlify.com)**
2. **拖拉部署**：
   - 將 `frontend/inventory_app/build/web/` 整個資料夾拖到 Netlify
   - 自動獲得 HTTPS 網域（如：https://amazing-app-123.netlify.app）

3. **自訂網域**（可選）：
   - 在 Netlify 設定中添加自訂網域

### 方案 C：Vercel 免費託管

1. **訪問 [Vercel](https://vercel.com)**
2. **GitHub 連接**：
   - 連接您的 GitHub 儲存庫
   - 設定構建目錄：`frontend/inventory_app/build/web`

---

## 📱 步驟 3：Windows 使用設定

### 🖥️ 桌面應用體驗（推薦）

#### Chrome/Edge 建立桌面應用：
1. **開啟網頁**: 訪問部署的網址
2. **安裝應用**: 
   - Chrome: 右上角 ⋮ → 「安裝庫存管理系統」
   - Edge: 右上角 ⋯ → 「應用程式」→「將此網站安裝為應用程式」

3. **桌面圖示**: 自動在桌面和開始功能表建立捷徑

#### 優點：
- ✅ 看起來像原生 Windows 應用
- ✅ 獨立視窗，沒有瀏覽器工具列
- ✅ 可從工作列和開始功能表啟動
- ✅ 支援離線快取

### 🌐 瀏覽器書籤方式：
1. **加入書籤**: 將網址加入瀏覽器收藏夾
2. **建立桌面捷徑**: 從收藏夾拖拉到桌面

---

## 🔧 步驟 4：優化和配置

### 📄 建立啟動腳本
建立 `launch_inventory_web.bat`：
```batch
@echo off
echo 正在啟動庫存管理系統...
start "" "https://YOUR-NETLIFY-URL.netlify.app"
echo 庫存管理系統已在瀏覽器中開啟
pause
```

### ⚙️ Windows 排程自動開啟
1. **開啟工作排程器**: `taskschd.msc`
2. **建立基本工作**: 
   - 觸發程序: 每日 9:00 AM
   - 動作: 執行上述批次檔
3. **店面自動化**: 每天自動開啟庫存系統

---

## 📊 步驟 5：測試和驗證

### ✅ 功能測試清單
```
□ 庫存頁面載入正常
□ 可以新增/修改庫存數量  
□ 剩食頁面運作正常
□ 配送計劃生成成功
□ 排程任務顯示和操作
□ 拖拉功能在觸控螢幕正常
□ 響應式設計適應不同螢幕
```

### 🌐 連線測試
```bash
# 測試 API 連線
curl https://inventory-system-api-wu21.onrender.com/inventory

# 應該回傳 JSON 格式的庫存資料
```

---

## 🎯 步驟 6：使用者培訓

### 📖 建立使用手冊
1. **螢幕截圖**: 擷取各頁面操作畫面
2. **操作影片**: 錄製常用功能操作
3. **快速參考卡**: 印製常用功能清單

### 👨‍🏫 員工訓練重點
- **基本操作**: 點擊數字修改庫存
- **拖拉功能**: 移動排程任務
- **每日流程**: 更新剩食 → 查看配送 → 確認任務

---

## 🔄 維護和更新

### 🔄 更新流程
1. **修改前端程式碼**
2. **重新構建**: `flutter build web --release`
3. **重新部署**: 上傳新的 `build/web` 到託管平台
4. **清除快取**: 使用者按 Ctrl+F5 強制重新載入

### 📊 監控和分析
- **Render 後端**: 查看 Render 儀表板監控 API 使用量
- **Netlify 前端**: 查看訪問統計和效能數據

---

## 🆘 故障排除

### ❌ 常見問題

#### 問題 1：網頁載入空白
**解決方案**:
```bash
# 重新構建並檢查
flutter build web --release
# 檢查 build/web/index.html 是否存在
```

#### 問題 2：API 連接失敗
**檢查清單**:
- ✅ Render 服務是否正常運行
- ✅ 網路連接是否正常
- ✅ HTTPS 憑證是否有效

#### 問題 3：功能無法使用
**解決方案**:
- 清除瀏覽器快取 (Ctrl+Shift+Delete)
- 檢查瀏覽器主控台錯誤訊息
- 確認 API 網址配置正確

---

## 📞 技術支援

### 🔍 診斷工具
- **API 健康檢查**: https://inventory-system-api-wu21.onrender.com/docs
- **瀏覽器開發者工具**: F12 查看網路請求
- **Render 日誌**: 查看後端運行狀態

### 📊 效能優化
- 使用 CDN 加速靜態資源
- 啟用瀏覽器快取
- 壓縮圖片和資源檔案

---

## 🎉 完成檢查清單

- [ ] 前端 API 已更新為雲端網址
- [ ] Flutter 網頁版成功構建
- [ ] 選擇並完成託管平台部署
- [ ] Windows 電腦可正常訪問
- [ ] 建立桌面捷徑或 PWA 應用
- [ ] 完成功能測試
- [ ] 員工培訓完成
- [ ] 建立維護更新流程

**🎯 目標達成：Windows 電腦可透過瀏覽器或 PWA 方式使用完整的庫存管理系統！**