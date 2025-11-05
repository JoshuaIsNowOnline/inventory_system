FROM python:3.11-slim

WORKDIR /app

# 安裝依賴
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 複製應用代碼
COPY . .

# 暴露端口
EXPOSE 7000

# 創建數據目錄
RUN mkdir -p /app/data

# 啟動命令
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "7000"]