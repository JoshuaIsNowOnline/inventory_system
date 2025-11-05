#!/usr/bin/env python3
# start.py - 根目錄啟動腳本，適用於 Render 部署

import os
import sys

if __name__ == "__main__":
    # 將 backend 目錄添加到 Python 路徑
    backend_path = os.path.join(os.path.dirname(__file__), 'backend')
    sys.path.insert(0, backend_path)
    
    # 切換工作目錄到 backend
    os.chdir(backend_path)
    
    import uvicorn
    
    # 獲取 PORT 環境變數
    port = int(os.environ.get("PORT", "8000"))
    
    # 直接啟動 uvicorn，指定模組路徑
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=port,
        log_level="info"
    )