# 庫存管理系統 - 部署指南

## 🖥️ 後端部署 (推薦方案)

### 選項 1: 本地網路部署 (最簡單)
在店內的一台電腦上運行後端服務：

```bash
# 1. 安裝 Python 3.8+ 
# 2. 切換到後端目錄
cd backend

# 3. 安裝依賴
pip install -r requirements.txt

# 4. 啟動服務 (對內網開放)
uvicorn app:app --host 0.0.0.0 --port 7000

# 服務將在 http://[電腦IP]:7000 運行
```

**優點**: 
- ✅ 部署簡單，成本最低
- ✅ 數據保存在本地，隱私安全
- ✅ 不需要網路就能在店內使用

**注意**:
- 📱 手機需要連接店內 WiFi
- 💻 運行服務的電腦需要保持開機

### 選項 2: 雲端部署 (推薦用於遠程管理)

#### 使用 Railway (免費額度)
1. 註冊 [Railway](https://railway.app)
2. 連接您的 GitHub 倉庫
3. 自動部署

#### 使用 Render (免費額度)
1. 註冊 [Render](https://render.com)  
2. 連接 GitHub 倉庫
3. 設定環境變數

## 📱 手機應用部署

### Android 部署 (APK)
```bash
# 1. 切換到前端目錄
cd frontend/inventory_app

# 2. 構建 APK
flutter build apk --release

# 3. APK 檔案位置
build/app/outputs/flutter-apk/app-release.apk
```

### iOS 部署 (需要 Mac + Apple Developer 帳號)
```bash
# 1. 構建 iOS 應用
flutter build ios --release

# 2. 使用 Xcode 打包和簽名
# 3. 上傳到 App Store 或使用 TestFlight 測試
```

### 網頁版部署 (適合 iPhone 用戶)
```bash
# 1. 構建網頁版
flutter build web --release

# 2. 將 build/web 資料夾部署到任何網頁服務器
# iPhone 用戶可直接透過 Safari 使用
```

## 🔧 配置檔案

需要的配置檔案：
- requirements.txt ✅ (已創建)
- Dockerfile (容器化部署)
- railway.json (Railway 部署)
- render.yaml (Render 部署)

## 📋 上線檢查清單

### 後端準備
- [ ] 確認所有依賴已列在 requirements.txt
- [ ] 測試 API 端點正常運作  
- [ ] 設置 CORS 允許手機訪問
- [ ] 備份數據庫 (app.db)

### 前端準備
- [ ] 更新 API 基礎 URL (指向正式環境)
- [ ] 測試所有功能正常
- [ ] 構建發布版本
- [ ] 準備應用圖示和名稱

### 設備準備
- [ ] iPhone: 準備網頁版或 App Store 版本
- [ ] Android: 準備 APK 檔案
- [ ] 確保設備能連接到後端服務

## 📞 技術支援
- 後端問題: 檢查防火牆設置
- 手機連接問題: 確認網路連通性  
- 性能問題: 考慮硬體升級