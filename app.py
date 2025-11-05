# app.py - 根目錄應用入口，用於 Render 部署
# 這個檔案作為備用方案，將請求轉發到 backend/app.py

import sys
import os

# 添加 backend 目錄到 Python 路徑
backend_path = os.path.join(os.path.dirname(__file__), 'backend')
sys.path.insert(0, backend_path)

# 導入實際的應用
try:
    from backend.app import app
except ImportError:
    # 如果無法導入 backend.app，嘗試直接導入
    sys.path.insert(0, backend_path)
    os.chdir(backend_path)
    import app as backend_app
    app = backend_app.app

# 導出 app 供 uvicorn 使用
__all__ = ['app']