# db.py
# import os
from sqlalchemy import create_engine, Column, Integer, Float, String, Date, Boolean, UniqueConstraint
from sqlalchemy.orm import sessionmaker, declarative_base


DB_URL = "sqlite:///./app.db"
engine = create_engine(DB_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()

class Inventory(Base):
    __tablename__ = "inventory"
    id = Column(Integer, primary_key=True)
    item = Column(String, unique=True, index=True, nullable=False)
    qty = Column(Float, default=0)
    danger_level = Column(Float, default=5.0)  # ⚠️ 新增：危險庫存警戒值

class Leftover(Base):
    __tablename__ = "leftovers"
    id = Column(Integer, primary_key=True)
    day = Column(Date, index=True, nullable=False)
    item = Column(String, nullable=False)
    qty = Column(Float, default=0)
    __table_args__ = (UniqueConstraint('day', 'item', name='uq_leftovers_day_item'),)

class DeliveryPlan(Base):
    __tablename__ = "delivery_plans"
    id = Column(Integer, primary_key=True)
    day = Column(Date, index=True, nullable=False)   # 計畫要「哪一天」的提貨量
    item = Column(String, nullable=False)
    planned_qty = Column(Float, default=0)
    confirmed = Column(Boolean, default=False)
    __table_args__ = (UniqueConstraint('day', 'item', name='uq_plan_day_item'),)

class ScheduleTask(Base):
    __tablename__ = "schedule_tasks"

    id = Column(Integer, primary_key=True, index=True)
    weekday = Column(String)      # 星期幾
    task = Column(String)         # 工作內容（例如「製作脆丸」）
    item = Column(String)         # 品項
    qty = Column(Float, default=0)
    done = Column(Boolean, default=False)

def init_db(products):
    Base.metadata.create_all(bind=engine)
    # seed inventory rows
    with SessionLocal() as s:
        for p in products:
            if not s.query(Inventory).filter_by(item=p).first():
                s.add(Inventory(item=p, qty=0))
        s.commit()
