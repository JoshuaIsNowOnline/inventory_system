@echo off
echo =====================================
echo 庫存管理系統 - 網頁版部署工具
echo =====================================
echo.

echo 🔧 步驟 1: 構建網頁版應用程式
cd frontend\inventory_app
call flutter clean
call flutter pub get
call flutter build web --release

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter 構建失敗！
    pause
    exit /b 1
)

echo.
echo ✅ 網頁版構建完成！
echo.

echo 🌐 步驟 2: 啟動本地網頁伺服器
echo 正在啟動 HTTP 伺服器於端口 8080...
cd build\web

echo.
echo 🎉 部署完成！
echo.
echo 📱 訪問網址: http://localhost:8080
echo 💡 按 Ctrl+C 停止伺服器
echo.

start "" "http://localhost:8080"
python -m http.server 8080

pause