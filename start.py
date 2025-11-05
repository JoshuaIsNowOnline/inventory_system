#!/usr/bin/env python3
# start.py - 根目錄啟動腳本，適用於 Render 部署

import os
import subprocess
import sys

if __name__ == "__main__":
    # 切換到 backend 目錄並啟動應用
    os.chdir('backend')
    
    # 獲取 PORT 環境變數
    port = os.environ.get("PORT", "8000")
    
    # 使用 uvicorn 啟動應用
    subprocess.run([
        sys.executable, "-m", "uvicorn", 
        "app:app", 
        "--host", "0.0.0.0", 
        "--port", port
    ])