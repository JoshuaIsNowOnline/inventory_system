# app.py
import datetime
from fastapi import FastAPI, HTTPException
from typing import Dict
from datetime import date

from models import PRODUCTS, InventoryUpdate, LeftoverUpsert, DeliveryRequest, ConfirmDelivery, MoveTaskRequest, UpdateTaskQtyRequest
from db import SessionLocal, init_db, Inventory, Leftover, DeliveryPlan, ScheduleTask
from logic import generate_schedule, weekday_to_datetype, fetch_weather_label, calc_base_delivery, apply_leftover_deduction, format_delivery_plan


from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Inventory API", version="0.2.0")

# CORS 設定 - 允許前端應用連接
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生產環境建議指定具體域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

init_db(PRODUCTS)

@app.get("/healthz")
def health():
    return {"ok": True}

@app.get("/inventory")
def get_inventory() -> Dict[str, Dict[str, float]]:
    with SessionLocal() as s:
        rows = s.query(Inventory).all()
        return {
            r.item: {
                "qty": r.qty,
                "danger_level": r.danger_level
            } for r in rows
        }

@app.post("/inventory/update")
def update_inventory(update: InventoryUpdate):
    if not update.updates:
        raise HTTPException(400, "updates 不可為空")
    with SessionLocal() as s:
        for item, qty in update.updates.items():
            row = s.query(Inventory).filter_by(item=item).first()
            if row:
                row.qty = max(float(qty), 0.0)
            else:
                s.add(Inventory(item=item, qty=max(float(qty), 0.0)))
        s.commit()
    return {"message": "inventory updated", "inventory": get_inventory()}

@app.post("/inventory/danger")
def update_danger_levels(payload: Dict[str, float]):
    if not payload:
        raise HTTPException(400, "danger_levels 不可為空")

    with SessionLocal() as s:
        for item, danger in payload.items():
            row = s.query(Inventory).filter_by(item=item).first()
            if row:
                row.danger_level = float(danger)
            else:
                s.add(Inventory(item=item, qty=0.0, danger_level=float(danger)))
        s.commit()

    return {"message": "danger levels updated", "inventory": get_inventory()}


@app.get("/leftovers/{day}")
def get_leftovers(day: date):
    with SessionLocal() as s:
        rows = s.query(Leftover).filter_by(day=day).all()
        return {r.item: r.qty for r in rows}

@app.post("/leftovers")
def upsert_leftovers(payload: LeftoverUpsert):
    with SessionLocal() as s:
        for item, qty in payload.leftovers.items():
            row = s.query(Leftover).filter_by(day=payload.day, item=item).first()
            if row: row.qty = max(float(qty), 0.0)
            else:   s.add(Leftover(day=payload.day, item=item, qty=max(float(qty), 0.0)))
        s.commit()
    return {"message": "leftovers upserted", "leftovers": get_leftovers(payload.day)}

@app.post("/delivery")
async def compute_delivery(payload: DeliveryRequest):
    day=payload.day
    with SessionLocal() as s:
        # ✅ 先查今天的 confirmed 提貨紀錄
        confirmed_rows = s.query(DeliveryPlan).filter_by(day=day, confirmed=True).all()
        if confirmed_rows:
            print("已有確認提貨紀錄，回傳既有版本")
            raw_data = {r.item: r.planned_qty for r in confirmed_rows}
            # 對已確認的數據也應用格式化邏輯
            formatted_data = format_delivery_plan(raw_data, s, day)
            return {
                "confirmed": True,
                # "date": day.isoformat(),
                "final_plan": formatted_data,
            }
        # 1) 自動判定平/假日
        dt = weekday_to_datetype(payload.day)
        # 2) 天氣：若未指定，呼叫 API 自動偵測
        weather_label = payload.weather or await fetch_weather_label()
        # 3) 計算基本計畫
        plan = calc_base_delivery(dt, weather_label, payload.safety_factor)
        # 4) 扣除「當日剩料」（用今天日期）
        today = date.today()
        with SessionLocal() as s2:
            todays = s2.query(Leftover).filter_by(day=today).all()
            leftovers = {r.item: r.qty for r in todays}
        raw_final_plan = apply_leftover_deduction(plan, leftovers)
        
        # 5) 格式化顯示邏輯
        final_plan = format_delivery_plan(raw_final_plan, s, day)
        
        return {
            "confirmed": False,
            "date_type": dt,
            "weather": weather_label,
            "base_plan": plan,
            "leftovers_today": leftovers,
            "final_plan": final_plan
        }

@app.post("/delivery/confirm")
def confirm_delivery(payload: ConfirmDelivery):
    # 寫入/更新 DeliveryPlan，並同步更新庫存（提貨到庫存 -）
    with SessionLocal() as s:
        # upsert plans
        for item, qty in payload.items.items():
            row = s.query(DeliveryPlan).filter_by(day=payload.day, item=item).first()
            if row:
                row.planned_qty = float(qty)
                row.confirmed = True
            else:
                s.add(DeliveryPlan(day=payload.day, item=item, planned_qty=float(qty), confirmed=True))
            # 更新庫存 + planned
            inv = s.query(Inventory).filter_by(item=item).first()
            if inv: inv.qty = max(inv.qty - float(qty), 0.0)
            else:   s.add(Inventory(item=item, qty=max(float(qty), 0.0)))
        s.commit()
    return {"message": "delivery confirmed & inventory updated", "inventory": get_inventory()}

@app.get("/schedule")
def get_schedule():
    """
    讀取排程（讀之前先自動生成）
    回傳: [{id, weekday, task, item, qty, done}, ...]
    """
    with SessionLocal() as s:
        generate_schedule(s)  # 先根據當前庫存低於危險量情形產生
        tasks = s.query(ScheduleTask).order_by(ScheduleTask.id).all()
        return [
            {"id": t.id, "weekday": t.weekday, "task": t.task, "item": t.item, "qty": t.qty, "done": t.done}
            for t in tasks
        ]


@app.post("/schedule/complete/{task_id}")
def complete_task(task_id: int):
    """
    完成任務：
      - 刪除這筆排程（或你想改 done=True 也行）
      - 依任務數量更新庫存（完成備料 → 庫存增加）
    """
    with SessionLocal() as s:
        task = s.query(ScheduleTask).filter_by(id=task_id).first()
        if not task:
            raise HTTPException(404, "Task not found")

        # 特殊處理：剝魚肉任務
        if task.item == "魚肉" and "剝魚肉" in task.task:
            # 剝一次產出 3包魚肉 + 4包魚皮
            # 更新魚肉庫存
            fish_meat_inv = s.query(Inventory).filter_by(item="魚肉").first()
            if fish_meat_inv:
                fish_meat_inv.qty = fish_meat_inv.qty + 3.0
            else:
                s.add(Inventory(item="魚肉", qty=3.0))
            
            # 更新魚皮庫存
            fish_skin_inv = s.query(Inventory).filter_by(item="魚皮").first()
            if fish_skin_inv:
                fish_skin_inv.qty = fish_skin_inv.qty + 4.0
            else:
                s.add(Inventory(item="魚皮", qty=4.0))
            
            message = f"任務 [{task.task}] 已完成，已增加魚肉 3.0 包、魚皮 4.0 包"
        else:
            # 一般任務：完成備料 → 庫存加 qty
            inv = s.query(Inventory).filter_by(item=task.item).first()
            if inv:
                inv.qty = max(inv.qty + float(task.qty), 0.0)
            else:
                s.add(Inventory(item=task.item, qty=max(float(task.qty), 0.0)))
            message = f"任務 [{task.task}] 已完成，已更新 {task.item} 庫存 {task.qty}"

        # 刪除任務（或改 task.done = True；這裡依你規格用刪除）
        s.delete(task)
        s.commit()
        return {"message": message}


@app.post("/schedule/delete/{task_id}")
def delete_task(task_id: int):
    """
    刪除任務：不更新庫存
    """
    with SessionLocal() as s:
        task = s.query(ScheduleTask).filter_by(id=task_id).first()
        if not task:
            raise HTTPException(404, "Task not found")
        s.delete(task)
        s.commit()
        return {"message": f"任務 [{task.task}] 已刪除"}


@app.post("/schedule/move/{task_id}")
def move_task(task_id: int, payload: MoveTaskRequest):
    """
    移動任務到不同星期幾
    """
    valid_weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    if payload.new_weekday not in valid_weekdays:
        raise HTTPException(400, f"Invalid weekday. Must be one of: {valid_weekdays}")
    
    with SessionLocal() as s:
        task = s.query(ScheduleTask).filter_by(id=task_id).first()
        if not task:
            raise HTTPException(404, "Task not found")
        
        old_weekday = task.weekday
        task.weekday = payload.new_weekday
        s.commit()
        return {"message": f"任務已從 {old_weekday} 移動到 {payload.new_weekday}"}


@app.post("/schedule/update_qty/{task_id}")
def update_task_qty(task_id: int, payload: UpdateTaskQtyRequest):
    """
    更新任務數量
    """
    with SessionLocal() as s:
        task = s.query(ScheduleTask).filter_by(id=task_id).first()
        if not task:
            raise HTTPException(404, "Task not found")
        
        old_qty = task.qty
        task.qty = max(float(payload.new_qty), 0.0)
        s.commit()
        return {"message": f"任務數量已從 {old_qty} 更新為 {task.qty}"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)