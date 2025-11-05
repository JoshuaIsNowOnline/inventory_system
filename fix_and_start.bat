@echo off
echo 庫存系統修復工具
echo ================

cd /d "%~dp0backend"

echo 1. 檢查 Python 環境...
%~dp0.venv\Scripts\python.exe --version

echo.
echo 2. 升級 SQLAlchemy 以修復 Python 3.13 相容性問題...
%~dp0.venv\Scripts\pip.exe install "SQLAlchemy>=2.0.35" --upgrade

echo.
echo 3. 測試應用程式導入...
%~dp0.venv\Scripts\python.exe -c "import sys; sys.path.append('.'); import app; print('✅ 應用程式導入成功')"

echo.
echo 4. 檢查端口佔用情況...
netstat -ano | findstr :8000
if %ERRORLEVEL%==0 (
    echo ⚠️  端口 8000 被佔用，請手動停止相關程序
) else (
    echo ✅ 端口 8000 可用
)

echo.
echo 5. 啟動應用程式...
echo 正在啟動庫存管理系統後端...
echo 訪問 http://127.0.0.1:8000/docs 查看 API 文檔
echo 按 Ctrl+C 停止服務
echo.
%~dp0.venv\Scripts\python.exe app.py

pause