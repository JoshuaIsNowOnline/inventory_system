# 🚀 Render 雲端部署指南

## 📋 部署前準備

### 1️⃣ GitHub 儲存庫設置
```bash
# 1. 初始化 Git（如果尚未完成）
cd c:\Users\Joshua\inventory_system
git init
git add .
git commit -m "Initial commit"

# 2. 推送到 GitHub
git remote add origin https://github.com/YOUR_USERNAME/inventory_system.git
git branch -M main
git push -u origin main
```

### 2️⃣ 檔案結構確認
確保以下檔案存在於正確位置：
```
inventory_system/          # 專案根目錄
├── requirements.txt       ✅ Python 依賴（根目錄）
├── start.py              ✅ Render 啟動腳本（根目錄）
├── render.yaml           ✅ Render 配置（根目錄）
└── backend/              # 後端目錄  
    ├── app.py            ✅ 主應用程式
    ├── db.py             ✅ 資料庫模型
    ├── logic.py          ✅ 商業邏輯
    └── models.py         ✅ Pydantic 模型
```

---

## 🌐 Render 平台部署

### 步驟 1：建立 Render 帳號
1. 訪問 [render.com](https://render.com)
2. 使用 GitHub 帳號註冊登入
3. 授權 Render 存取您的 GitHub 儲存庫

### 步驟 2：創建 Web Service
1. **點擊「New +」** → **「Web Service」**
2. **連接 GitHub 儲存庫：**
   - 選擇 `inventory_system` 儲存庫
   - 點擊「Connect」

3. **配置服務設定：**
   ```
   Name: inventory-backend
   Environment: Python 3
   Build Command: pip install -r requirements.txt  
   Start Command: python start.py
   ```

4. **環境變數設定：**
   - 點擊「Advanced」
   - 新增環境變數：
     ```
     PYTHON_VERSION = 3.11.0
     PORT = 8000
     ```

5. **其他設定：**
   ```
   Instance Type: Free (初期測試)
   Auto-Deploy: Yes (自動部署)
   Root Directory: (保持空白，使用專案根目錄)
   ```

### 步驟 3：部署啟動
1. 點擊「Create Web Service」
2. 等待部署完成（約 3-5 分鐘）
3. 部署成功後，獲得 API 網址：
   ```
   https://YOUR-SERVICE-NAME.onrender.com
   ```

---

## 🔧 前端配置更新

部署完成後，需要更新前端 API 網址：

### 修改 ApiService
編輯 `frontend/inventory_app/lib/services/api_service.dart`：

```dart
class ApiService {
  // 🔄 更新為 Render 部署的網址
  static const String baseUrl = 'https://YOUR-SERVICE-NAME.onrender.com';
  
  // 範例：
  // static const String baseUrl = 'https://inventory-backend-abc123.onrender.com';
}
```

### 重新打包應用
```bash
# 更新 API 網址後重新打包
cd frontend/inventory_app
flutter clean
flutter pub get
flutter build apk --release  # Android
flutter build web --release  # 網頁版
```

---

## 📊 部署狀態檢查

### ✅ 健康檢查
訪問以下網址確認服務正常：
```
https://YOUR-SERVICE-NAME.onrender.com/docs
```

應該顯示 FastAPI 自動生成的 API 文檔。

### 🔍 測試 API 端點
```bash
# 測試庫存 API
curl https://YOUR-SERVICE-NAME.onrender.com/inventory

# 測試排程 API  
curl https://YOUR-SERVICE-NAME.onrender.com/schedule
```

---

## 🐛 故障排除

### 問題 1：部署失敗 - ImportError
**原因：** 相對導入問題
**解決：** 已修正為絕對導入，重新部署即可

### 問題 2：CORS 錯誤
**原因：** 跨域請求被阻擋
**解決：** 已添加 CORS 中間件，允許跨域請求

### 問題 3：資料庫初始化失敗
**原因：** SQLite 檔案權限問題
**解決：** Render 會自動處理檔案系統權限

### 問題 4：應用無法啟動
**檢查步驟：**
1. 查看 Render 部署日誌
2. 確認 `requirements.txt` 包含所有依賴
3. 驗證 `start.py` 檔案存在且正確

---

## 💰 成本評估

### Free Tier 限制
- **記憶體：** 512 MB
- **CPU：** 共享
- **休眠：** 15分鐘無活動後自動休眠
- **喚醒時間：** 30-60秒

### 建議升級時機
當店面使用頻繁時，考慮升級到 Starter Plan ($7/月)：
- 無休眠限制
- 更快啟動速度
- 更穩定效能

---

## 🔄 自動部署流程

設定完成後，每次推送程式碼到 GitHub：
```bash
git add .
git commit -m "更新功能"
git push origin main
```

Render 會自動：
1. 檢測程式碼變更
2. 重新構建應用
3. 部署新版本
4. 零停機更新

---

## 📱 移動應用配置

### Android APK
```bash
# 使用新的 API 網址重新打包
cd frontend/inventory_app
flutter build apk --release
```

### iPhone 網頁版  
```bash
# 構建網頁版並部署到靜態託管
flutter build web --release

# 可部署到：
# - Netlify (免費)
# - Vercel (免費) 
# - GitHub Pages (免費)
```

---

## 🎯 生產環境最佳實踐

### 安全性設定
1. **環境變數管理：**
   ```
   DATABASE_URL=postgresql://...  # 升級到 PostgreSQL
   SECRET_KEY=your-secret-key
   ALLOWED_HOSTS=your-domain.com
   ```

2. **CORS 限制：**
   ```python
   allow_origins=["https://your-domain.com"]  # 指定允許的域名
   ```

### 效能優化
1. **資料庫升級：** SQLite → PostgreSQL
2. **快取機制：** Redis 快取頻繁查詢
3. **監控設置：** 添加應用效能監控

### 備份策略
1. **自動備份：** 設定定期資料庫備份
2. **版本控制：** 保持程式碼版本同步
3. **災難復原：** 準備快速復原計畫

---

## 📞 技術支援

### Render 官方資源
- 📖 [文檔](https://render.com/docs)
- 💬 [社群論壇](https://community.render.com)
- 📧 [技術支援](https://render.com/contact)

### 常用指令
```bash
# 查看部署日誌
render logs --service YOUR-SERVICE-ID

# 重新部署
render deploy --service YOUR-SERVICE-ID

# 環境變數管理
render env set KEY=VALUE --service YOUR-SERVICE-ID
```