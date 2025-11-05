# models.py
from enum import Enum
from typing import Dict, List , Optional
from pydantic import BaseModel
from datetime import date

# 日期類型（平日/假日/休息日）
class DateType(str, Enum):
    weekday = "weekday"  # 平日
    holiday = "holiday"  # 假日
    restday = "restday"  # 休息日

# 商品列表
PRODUCTS: List[str] = ["魚肚","魚皮","魚肉","粉蒸","Q腸","豬腸","脆丸","蝦丸","肉丸","肉燥"]

# =========================================================
# ✅ Pydantic 模型區（FastAPI 使用）
# =========================================================   
class InventoryUpdate(BaseModel):
    updates: Dict[str, float]

class LeftoverUpsert(BaseModel):
    day: date
    leftovers: Dict[str, float]

class DeliveryRequest(BaseModel):
    day: date                # 計畫要計算的日期（通常是「明天」）
    weather: Optional[str] = None   # 若空則由後端自動查
    safety_factor: float = 1.0

class ConfirmDelivery(BaseModel):
    day: date
    items: Dict[str, float]  # 最終確認的提貨量

class MoveTaskRequest(BaseModel):
    new_weekday: str

class UpdateTaskQtyRequest(BaseModel):
    new_qty: float
