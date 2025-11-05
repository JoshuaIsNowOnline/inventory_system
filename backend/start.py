#!/usr/bin/env python3
# start.py - Render 部署啟動腳本

import uvicorn
import os

if __name__ == "__main__":
    # Render 會自動設定 PORT 環境變數
    port = int(os.environ.get("PORT", 7000))
    
    # 啟動 FastAPI 應用
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=port,
        log_level="info"
    )