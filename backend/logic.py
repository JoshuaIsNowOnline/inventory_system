# logic.py
from typing import Dict, Tuple
from datetime import date
import httpx
from models import DateType
from datetime import datetime, timedelta
from db import ScheduleTask,Inventory,Leftover
import asyncio

# 門市座標（自行調整）
STORE_LAT, STORE_LON = 22.989382341539695, 120.20492352698653

#提貨基準量
AVERAGE_DELIVERY = {
    "魚肚": 3.0, "魚皮": 2.0, "魚肉": 3.0, "粉蒸": 2.0, "Q腸": 1.0,
    "豬腸": 1.0, "脆丸": 0.8, "蝦丸": 1.0, "肉丸": 0.5, "肉燥": 0.5
}

DATE_WEIGHT = {
    DateType.weekday: 1.0,
    DateType.holiday: 1.3,
    DateType.restday: 0.2,
}

# 可按實際數據微調(排程用)
ITEM_COEFF: Dict[str, float] = {
    "魚肚": 1.2,
    "魚皮": 1.1,
    "魚肉": 1.0,
    "粉蒸": 1.0,
    "腸子": 0.9,
    "脆丸": 1.3,
    "蝦肉丸": 1.1,
    "肉燥": 1.0,
}

WEATHER_WEIGHT = {  # 簡化分類
    "sunny": 1.0, "cloudy": 0.95, "rain": 0.8, "storm": 0.6, "typhoon": 0.4
}

def weekday_to_datetype(d: date) -> DateType:
    # 六日視為 holiday；可擴充一個 set 放國定假日
    if d.weekday() >= 5:
        return DateType.holiday
    elif d.weekday() == 2:  # 每週三為 restday 
        return DateType.restday
    return DateType.weekday 

def map_weather_code_to_label(code: int) -> str:
    # Open-Meteo weathercode 簡化對應
    if code in (0,1): return "sunny"
    if code in (2,3): return "cloudy"
    if code in (51,53,55,61,63,65,80,81,82): return "rain"
    if code in (95,96,99): return "storm"
    return "cloudy"

async def fetch_weather_label() -> str:
    # Open-Meteo：當前天氣
    url = (f"https://api.open-meteo.com/v1/forecast?latitude={STORE_LAT}"
           f"&longitude={STORE_LON}&current=weather_code")
    async with httpx.AsyncClient(timeout=10) as client:
        r = await client.get(url)
        r.raise_for_status()
        code = r.json().get("current", {}).get("weather_code", 2)
        return map_weather_code_to_label(code)

def calc_base_delivery(date_type: DateType, weather_label: str, safety: float) -> Dict[str, float]:
    dw = DATE_WEIGHT.get(date_type, 1.0)
    ww = WEATHER_WEIGHT.get(weather_label, 1.0)
    out: Dict[str, float] = {}
    for name, avg in AVERAGE_DELIVERY.items():
        out[name] = round(avg * dw * ww * safety, 2)
    return out

def apply_leftover_deduction(plan: Dict[str, float], leftovers: Dict[str, float]) -> Dict[str, float]:
    # 第 6 點：提貨量扣掉當日剩料（不得為負）
    out: Dict[str, float] = {}
    for item, qty in plan.items():
        ded = leftovers.get(item, 0.0)
        out[item] = max(round(qty - ded, 2), 0.0)
    return out

def format_delivery_plan(plan: Dict[str, float], session, target_date: date) -> Dict[str, float]:
    """
    格式化提貨計畫的顯示邏輯：
    - 魚肚魚皮粉蒸Q腸豬腸蝦丸肉丸：顯示到小數點第一位
    - 魚肉：只有隔天做脆丸或蝦肉丸才顯示，並且取整
    - 肉燥：取整
    - 脆丸：不需要提貨（從計畫中移除）
    """
    from datetime import timedelta
    from db import ScheduleTask
    
    # 檢查目標日期是否有脆丸或蝦肉丸的排程任務
    target_weekday = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"][target_date.weekday()]
    
    # 查詢目標日期的排程任務
    tasks = session.query(ScheduleTask).filter_by(weekday=target_weekday, done=False).all()
    has_crispy_ball_task = any("脆丸" in (task.task or "") for task in tasks)
    has_shrimp_ball_task = any("蝦肉丸" in (task.task or "") or "蝦丸" in (task.task or "") or "肉丸" in (task.task or "") for task in tasks)
    
    formatted_plan = {}
    
    for item, qty in plan.items():
        # 脆丸不需要提貨
        if item == "脆丸":
            continue
            
        # 魚肉：只有隔天做脆丸或蝦肉丸才顯示，並且取整
        elif item == "魚肉":
            if has_crispy_ball_task or has_shrimp_ball_task:
                formatted_plan[item] = float(int(qty))  # 取整
        
        # 肉燥：顯示到小數點第一位
        elif item == "肉燥":
            formatted_plan[item] = round(qty, 1)
        
        # 其他項目（魚肚魚皮粉蒸Q腸豬腸蝦丸肉丸）：顯示到小數點第一位
        else:
            formatted_plan[item] = round(qty, 1)
    
    return formatted_plan

def compute_intensity(
    next_day_plan_qty: float,
    today_leftover_qty: float,
    weather_label: str,
    date_type: DateType,
    item: str,
    K: float = 5.0,
    min_int: float = 0.1,
) -> float:
    """
    將「隔日提貨量 / 當日剩料」轉成 0~1 的強度，並用天氣/日期/品項係數修正
    """
    baseline_ratio = next_day_plan_qty / max(today_leftover_qty + 1.0, 1.0)
    basic_int = min(max(baseline_ratio / K, min_int), 1.0)

    weather_map = {"晴": 1.0, "雨": 0.9, "颱風": 0.7}
    date_map = {
        DateType.weekday: 1.0,
        DateType.holiday: 1.2,
        DateType.restday: 0.8,
    }
    item_coeff = ITEM_COEFF.get(item, 1.0)

    return min(basic_int * weather_map.get(weather_label, 1.0) * date_map.get(date_type, 1.0) * item_coeff, 1.0)

def calculate_qty_plan(item: str, intensity: float) -> Tuple[str, float]:
    """
    回傳 (顯示用工作名稱, 數量)
    ——依你的規則：
      魚肚:一次3/4/5/6(強度高選大),魚皮:4,粉蒸:8
      脆丸:7/8/9包魚肉 → 4.5/5/5.5(名稱:脆丸7/8/9)
      腸子、蝦肉丸:數量由前端/現場決定(0)
      肉燥:8
    """
    if item == "魚肚":
        # 用強度把 3~6 映射出來（你也可以改成離散規則）
        if intensity >= 0.85:
            return ("魚肚", 6.0)
        elif intensity >= 0.65:
            return ("魚肚", 5.0)
        elif intensity >= 0.45:
            return ("魚肚", 4.0)
        else:
            return ("魚肚", 3.0)

    if item == "魚皮":
        return ("魚皮", 4.0)

    if item == "魚肉":
        return ("剝魚肉", 1.0)  # 剝一次產出 3包魚肉 + 4包魚皮

    if item == "粉蒸":
        return ("粉蒸", 8.0)

    if item == "脆丸":
        # 強度高 → 做9，次高 → 8，否則7
        if intensity >= 0.8:
            return ("脆丸9", 5.5)
        elif intensity >= 0.5:
            return ("脆丸8", 5.0)
        else:
            return ("脆丸7", 4.5)

    if item in ("Q腸", "豬腸", "腸子"):
        return ("腸子", 0.0)

    if item in ("蝦丸", "肉丸", "蝦肉丸"):
        return ("蝦肉丸", 0.0)

    if item == "肉燥":
        return ("肉燥", 8.0)

    # fallback
    return (item, 0.0)
# =========================================================
# 🧮 自動排程邏輯
# =========================================================
def generate_schedule(session):
    """
    自動排程：
      - 掃描：哪些品項庫存 < 危險量
      - 將 (Q腸,豬腸) 合併成「腸子」，(蝦丸,肉丸) 合併成「蝦肉丸」
      - 依「隔日提貨 / 當日剩料 + 天氣 + 日期 + 品項係數」計算 intensity
      - 依 intensity 決定每項工作的離散數量 (calculate_qty_plan)
      - 避開假日/休息日 + 避免同日>1件
      - 已有未完成同品項任務 → 視為鎖住，不重複建
    """
    WEEKDAYS_EN = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    today = datetime.today()
    # 1) 決定隔日的 date_type & 天氣
    tomorrow = today.date() + timedelta(days=1)
    dt = weekday_to_datetype(tomorrow)              # DateType
    weather_label = asyncio.run(fetch_weather_label()) if callable(fetch_weather_label) else "晴"

    # 2) 計算隔日提貨「基準計畫」（用你既有函式）
    base_plan: Dict[str, float] = calc_base_delivery(dt, weather_label, 1.0)

    # 3) 當日剩料（用今天）
    todays_leftovers = {r.item: r.qty for r in session.query(Leftover).filter_by(day=today.date()).all()}

    # 4) 盤點庫存、找出低於危險量的品項
    inventories = session.query(Inventory).all()
    low_items = [inv.item for inv in inventories if inv.qty < inv.danger_level]

    # 5) 特殊邏輯：當魚皮低於危險量時，也新增魚肉任務
    fish_skin_inv = next((inv for inv in inventories if inv.item == "魚皮"), None)
    if fish_skin_inv and fish_skin_inv.qty < fish_skin_inv.danger_level:
        if "魚肉" not in low_items:
            low_items.append("魚肉")

    # 6) 合併：腸子 / 蝦肉丸
    if any(x in low_items for x in ("Q腸", "豬腸")):
        low_items = [x for x in low_items if x not in ("Q腸", "豬腸")]
        low_items.append("腸子")
    if any(x in low_items for x in ("蝦丸", "肉丸")):
        low_items = [x for x in low_items if x not in ("蝦丸", "肉丸")]
        low_items.append("蝦肉丸")

    # 7) 取出目前未完成任務（鎖住，不重建）
    locked_items = set(t.item for t in session.query(ScheduleTask).filter_by(done=False).all())

    # 8) 逐項建立任務
    for item in low_items:
        if item in locked_items:
            continue

        # 7-1) 取得「隔日提貨量」與「當日剩料量」→ 計算 intensity
        # 對合併項目做對應
        if item == "腸子":
            # 取 Q腸/豬腸的合計當作參考
            base_qty = (base_plan.get("Q腸", 0.0) or 0.0) + (base_plan.get("豬腸", 0.0) or 0.0)
            leftover_qty = (todays_leftovers.get("Q腸", 0.0) or 0.0) + (todays_leftovers.get("豬腸", 0.0) or 0.0)
        elif item == "蝦肉丸":
            base_qty = (base_plan.get("蝦丸", 0.0) or 0.0) + (base_plan.get("肉丸", 0.0) or 0.0)
            leftover_qty = (todays_leftovers.get("蝦丸", 0.0) or 0.0) + (todays_leftovers.get("肉丸", 0.0) or 0.0)
        else:
            base_qty = base_plan.get(item, 0.0) or 0.0
            leftover_qty = todays_leftovers.get(item, 0.0) or 0.0

        intensity = compute_intensity(
            next_day_plan_qty=base_qty,
            today_leftover_qty=leftover_qty,
            weather_label=weather_label,
            date_type=dt,
            item=item,
        )

        # 7-2) 用 intensity 決定離散數量 & 顯示名稱
        task_name, qty = calculate_qty_plan(item, intensity)

        # 7-3) 幫它找一個合適天（避假日/休息日、同日>1件）
        for i in range(1, 8):
            d = today + timedelta(days=i)
            day_dt = weekday_to_datetype(d.date())
            if day_dt in (DateType.holiday, DateType.restday):
                continue

            wd = WEEKDAYS_EN[d.weekday()]
            existed_same_day = session.query(ScheduleTask).filter_by(weekday=wd, done=False).first()
            if existed_same_day:
                continue

            session.add(ScheduleTask(
                weekday=wd,
                task=f"製作 {task_name}",
                item=item,
                qty=qty,
                done=False
            ))
            break

    session.commit()