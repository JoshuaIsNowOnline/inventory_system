# 🏪 店面部署快速指南

## 🚀 推薦部署方案

### 方案一：本地網路部署 (推薦)
**優點：** 數據隱私、穩定快速、無月費
**適用：** 店內有 WiFi 網路

### 方案二：雲端部署  
**優點：** 遠程管理、自動備份
**適用：** 需要遠程監控庫存

---

## 📋 部署前準備

### 硬體需求
- **電腦主機：** Windows 10/11 或 Mac (至少 4GB RAM)
- **網路設備：** WiFi 路由器
- **手機設備：** Android 或 iPhone

### 軟體安裝
```bash
# 1. 安裝 Python 3.8+
# https://www.python.org/downloads/

# 2. 安裝 Flutter (用於打包手機應用)
# https://flutter.dev/docs/get-started/install

# 3. 驗證安裝
python --version
flutter --version
```

---

## ⚡ 5分鐘快速部署

### 步驟 1：啟動系統
```bash
cd inventory_system

# Windows
start_system.bat

# Mac/Linux  
./start_system.sh
```

### 步驟 2：打包手機應用
```bash
# Windows
build_app.bat

# Mac/Linux
./build_app.sh
```

### 步驟 3：安裝到手機
- **Android：** 安裝 APK 檔案
- **iPhone：** 使用 Safari 開啟網頁版

### 步驟 4：測試連接
1. 手機連接店內 WiFi
2. 開啟庫存管理應用  
3. 確認可以新增/查看庫存

---

## 🏪 店面使用流程

### 每日營業準備
1. **開機啟動**
   ```bash
   cd inventory_system
   start_system.bat  # 雙擊執行
   ```

2. **員工登入**
   - 開啟手機應用
   - 開始庫存操作

### 日常庫存管理
1. **進貨入庫**
   - 庫存頁面 → 調整數量 → 增加
   
2. **銷售出貨**  
   - 庫存頁面 → 調整數量 → 減少

3. **剩食處理**
   - 剩食頁面 → 輸入危險係數
   
4. **查看配送計劃**
   - 配送頁面 → 查看建議配送量

5. **安排工作排程**
   - 排程頁面 → 拖拉調整任務

### 每日營業結束
- 系統會自動保存所有數據
- 可直接關閉電腦

---

## 🔧 常用維護操作

### 備份數據
```bash
# 手動備份
copy backend\inventory.db backup\inventory_backup_YYYYMMDD.db

# 自動備份 (可加入 Windows 工作排程器)
backup_database.bat
```

### 重置系統
```bash
# 重新初始化數據庫 (⚠️ 會清除所有數據)
cd backend
python -c "import database; database.init_db()"
```

### 更新 IP 地址
當路由器 IP 改變時，編輯 `frontend/inventory_app/lib/services/api_service.dart`：
```dart
static const String baseUrl = 'http://NEW_IP:7000';
```
然後重新打包應用。

---

## 📱 員工使用手冊

### Android 手機
1. **安裝：** 點擊 APK 檔案安裝
2. **開啟：** 桌面找到「庫存管理」圖標
3. **使用：** 直接操作，無需額外設定

### iPhone 手機  
1. **開啟：** Safari 瀏覽器
2. **訪問：** 輸入網址 http://店內電腦IP:8080
3. **加入桌面：** 分享 → 加入主畫面
4. **使用：** 點擊桌面圖標，如同原生 App

### 基本操作
- **👆 點擊數字：** 直接修改數量
- **🎯 拖拉卡片：** 移動排程任務  
- **🔄 下拉更新：** 重新整理數據
- **📊 查看圖表：** 配送建議和趨勢

---

## 🆘 常見問題解決

### Q1: 手機連不上系統
**解決方法：**
1. 確認手機和電腦連同一個 WiFi
2. 檢查電腦防火牆設定
3. 重新啟動系統：`start_system.bat`

### Q2: 數據沒有同步
**解決方法：**
1. 檢查網路連接狀態
2. 手機下拉重新整理
3. 重新開啟應用

### Q3: 應用運行緢慢
**解決方法：**
1. 關閉其他不必要的應用
2. 重新啟動手機
3. 檢查 WiFi 信號強度

### Q4: 忘記備份數據
**解決方法：**  
數據庫檔案位於：`backend/inventory.db`
定期複製此檔案到安全位置。

---

## 📞 技術支援

### 自助檢測
1. **後端狀態：** 訪問 http://電腦IP:7000/docs
2. **網頁版狀態：** 訪問 http://電腦IP:8080  
3. **數據庫狀態：** 檢查 `backend/inventory.db` 檔案

### 聯繫支援
- **系統問題：** 提供錯誤截圖和操作步驟
- **功能建議：** 說明具體使用場景
- **緊急故障：** 先嘗試重新啟動系統

---

## 📈 進階功能

### 數據分析
- 配送頁面可查看歷史趨勢
- 剩食頁面追蹤浪費情況  
- 排程頁面優化工作分配

### 多店管理
每個店面獨立部署一套系統，數據獨立管理。

### 雲端同步
可升級為雲端版本，實現多店數據同步。