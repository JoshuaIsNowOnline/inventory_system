# 🔧 庫存系統問題診斷與修復指南

## ❌ 問題：相對導入改成絕對導入後載入不出資料

### 🔍 問題分析
1. **SQLAlchemy 版本相容性問題**
   - Python 3.13 與 SQLAlchemy 2.0.23 不相容
   - 導致應用程式無法啟動

2. **導入路徑問題**
   - 相對導入改為絕對導入後模組找不到
   - 需要在正確目錄執行應用程式

3. **端口衝突**
   - 多次啟動導致端口被佔用

### ✅ 解決方案

#### 1️⃣ 升級 SQLAlchemy
```bash
# 安裝相容版本
pip install "SQLAlchemy>=2.0.35" --upgrade
```

#### 2️⃣ 修正應用程式啟動方式
```python
# 在 app.py 末尾添加
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
```

#### 3️⃣ 更新前端 API 端口
```dart
// frontend/inventory_app/lib/services/api_service.dart
String get baseUrl {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000';  // 從 7000 改為 8000
  }
  // ...其他平台
}
```

#### 4️⃣ 更新 requirements.txt
```
sqlalchemy>=2.0.35  # 從 2.0.23 改為 >=2.0.35
```

### 🚀 一鍵修復腳本

#### Windows 用戶：
```bash
# 執行修復腳本
fix_and_start.bat
```

#### 手動修復步驟：
```bash
# 1. 升級依賴
cd backend
../.venv/Scripts/pip.exe install "SQLAlchemy>=2.0.35" --upgrade

# 2. 啟動應用程式
../.venv/Scripts/python.exe app.py

# 3. 訪問測試
# http://127.0.0.1:8000/docs
```

### 🔍 驗證步驟

1. **後端健康檢查：**
   ```
   ✅ 訪問：http://127.0.0.1:8000/docs
   ✅ 測試：http://127.0.0.1:8000/inventory
   ```

2. **前端連接測試：**
   ```bash
   cd frontend/inventory_app
   flutter run -d web-server --web-port 3000
   ```

3. **API 測試：**
   - 庫存頁面能正常載入數據 ✅
   - 排程頁面顯示任務列表 ✅
   - 配送頁面計算正常 ✅

### 🐛 常見問題排除

#### Q1: 仍然無法啟動
```bash
# 檢查 Python 版本
python --version

# 檢查 SQLAlchemy 版本
pip show SQLAlchemy

# 確認版本 >= 2.0.35
```

#### Q2: 端口被佔用
```bash
# 查看佔用程序
netstat -ano | findstr :8000

# 停止佔用程序
taskkill /PID [PID_NUMBER] /F
```

#### Q3: 前端無法連接
```
檢查清單：
□ 後端是否在 8000 端口運行
□ 前端 API URL 是否更新為 8000
□ 防火牆是否允許連接
□ 網路連接是否正常
```

#### Q4: 資料庫錯誤
```bash
# 重新初始化資料庫
cd backend
python -c "from db import init_db; from models import PRODUCTS; init_db(PRODUCTS)"
```

### 📋 預防措施

1. **版本鎖定：**
   - 使用 `requirements.txt` 鎖定相容版本
   - 定期檢查依賴更新

2. **啟動檢查：**
   - 使用 `fix_and_start.bat` 自動檢查環境
   - 啟動前驗證端口可用性

3. **測試流程：**
   - 每次修改後執行健康檢查
   - 確保前後端連接正常

### 🎯 部署建議

#### 本地開發：
- 使用端口 8000 避免衝突
- 定期更新依賴版本

#### Render 部署：
- requirements.txt 使用相容版本
- 環境變數配置 PORT
- 使用 start.py 適配雲端環境

#### 生產環境：
- 固定 Python 3.11 或 3.12 版本
- 使用 Docker 容器化部署
- 配置健康檢查和自動重啟

---

## 📞 技術支援

### 立即幫助
1. 執行 `fix_and_start.bat` 自動修復
2. 檢查 `http://127.0.0.1:8000/docs` 是否可訪問
3. 確認前端 API URL 已更新

### 進階診斷
如果問題持續存在，請提供：
- Python 版本號
- 錯誤訊息截圖
- `pip list` 輸出
- 啟動日誌內容