@echo off
echo =========================================
echo 庫存管理系統 - Netlify 部署準備工具
echo =========================================
echo.

echo 🔧 準備 Netlify 部署檔案...
echo.

echo 📋 部署方式選擇：
echo 1. 手動上傳 (拖拉 build/web 資料夾)
echo 2. GitHub 自動部署 (推薦)
echo.

set /p choice="請選擇部署方式 (1 或 2): "

if "%choice%"=="1" goto manual_deploy
if "%choice%"=="2" goto github_deploy
goto invalid

:manual_deploy
echo.
echo 🏗️  構建網頁版應用程式...
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
echo ✅ 構建完成！
echo.
echo 📁 部署檔案位置: frontend\inventory_app\build\web\
echo.
echo 🌐 Netlify 手動部署步驟:
echo 1. 開啟 https://www.netlify.com
echo 2. 註冊/登入帳號
echo 3. 將整個 build\web\ 資料夊拖拉到部署區域
echo 4. 等待部署完成，獲得網址
echo.
start "" "https://www.netlify.com"
start "" "%cd%\build\web"
goto end

:github_deploy
echo.
echo 🔄 準備 GitHub 自動部署...
echo.
echo ✅ netlify.toml 配置檔案已創建
echo ✅ 所有檔案準備推送到 GitHub
echo.

cd %~dp0
git add .
git status

echo.
echo 📝 提交變更...
git commit -m "🚀 Netlify 部署配置

- 添加 netlify.toml 自動構建配置
- 準備 GitHub 整合部署"

echo.
echo 📤 推送到 GitHub...
git push origin main

echo.
echo 🌐 GitHub 自動部署步驟:
echo 1. 開啟 https://www.netlify.com
echo 2. 點擊 "New site from Git"
echo 3. 選擇 GitHub 並連接儲存庫: inventory_system
echo 4. Netlify 自動讀取 netlify.toml 配置
echo 5. 點擊 "Deploy site" 開始自動部署
echo.
start "" "https://www.netlify.com"
goto end

:invalid
echo ❌ 無效選項，請重新執行
pause
exit /b 1

:end
echo.
echo 🎉 部署準備完成！
echo 💡 部署完成後，您將獲得一個 https:// 網址
echo 📱 可在任何裝置的瀏覽器中使用
echo.
pause