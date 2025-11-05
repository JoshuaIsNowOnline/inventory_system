@echo off
echo 庫存管理系統 - 應用打包工具
echo ================================

cd /d "%~dp0frontend\inventory_app"

echo.
echo 選擇打包類型:
echo 1. Android APK (所有 Android 手機適用)
echo 2. 網頁版 (iPhone Safari 適用)  
echo 3. Windows 桌面版
echo.

set /p choice="請輸入選項 (1-3): "

if %choice%==1 goto android
if %choice%==2 goto web  
if %choice%==3 goto windows
goto end

:android
echo.
echo 正在構建 Android APK...
flutter clean
flutter pub get
flutter build apk --release
echo.
echo ✅ APK 已生成: build\app\outputs\flutter-apk\app-release.apk
echo 📱 請將此檔案傳送到 Android 手機並安裝
goto end

:web
echo.
echo 正在構建網頁版...
flutter clean
flutter pub get  
flutter build web --release
echo.
echo ✅ 網頁版已生成: build\web\
echo 🌐 將此資料夾上傳到網頁伺服器
echo 📱 iPhone 用戶可透過 Safari 訪問
goto end

:windows
echo.
echo 正在構建 Windows 桌面版...
flutter clean
flutter pub get
flutter build windows --release
echo.
echo ✅ Windows 應用已生成: build\windows\runner\Release\
echo 💻 可直接在 Windows 電腦上運行
goto end

:end
echo.
pause