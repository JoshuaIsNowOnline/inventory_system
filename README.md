# 🏪 智能庫存管理系統

餐飲業專用的智能庫存管理系統，支援自動排程、剩食處理和配送計劃。

## ✨ 主要功能

- 📦 **庫存管理** - 即時監控，危險量警示
- 🗑️ **剩食處理** - 智能追蹤，減少浪費  
- 🚚 **配送計劃** - 天氣感知的智能建議
- 📅 **工作排程** - 自動任務生成，拖拉操作

## 🎯 設計特色

- 👴 **老人友善** - 大字體、高對比度
- 📱 **跨平台** - Android APK + iPhone 網頁版
- 🎮 **直觀操作** - 點擊編輯、拖拉排程

## 🚀 技術架構

- **前端**: Flutter (跨平台)
- **後端**: FastAPI + SQLAlchemy + SQLite
- **部署**: 本地/Docker/Render 雲端

## 📋 快速開始

### Windows 一鍵啟動
```bash
fix_and_start.bat
```

### 手動啟動
```bash
# 後端
cd backend
python app.py

# 前端打包
build_app.bat  # Windows
./build_app.sh # macOS/Linux
```

## 📱 安裝方式

| 平台 | 方法 |
|------|------|
| Android | 安裝 APK 檔案 |
| iPhone | Safari 網頁版 + 加入桌面 |
| 電腦 | 直接執行桌面版 |

## 📚 完整文檔

- [🏪 店面部署指南](STORE_DEPLOYMENT_GUIDE.md)
- [📱 手機安裝指南](MOBILE_SETUP_GUIDE.md)  
- [☁️ Render 雲端部署](RENDER_DEPLOYMENT_GUIDE.md)
- [🔧 故障排除指南](TROUBLESHOOTING_GUIDE.md)

## 🎯 適用場景

- 🍜 小型餐廳庫存管理
- 🥘 連鎖店面統一管理  
- 👨‍🍳 廚房製作排程
- 📊 食材浪費監控

---

**🎉 讓您的餐廳營運更智能高效！**