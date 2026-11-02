from datetime import date
from typing import Optional, List
from pydantic import BaseModel
from app.models.meal_plan import PeriodTypeEnum


class MealPlanGenerate(BaseModel):
    period_type: PeriodTypeEnum
    start_date: date


class MealPlanItemOut(BaseModel):
    meal_date: date
    meal_time: str
    meal_name: str
    estimated_cost: Optional[float] = None

    class Config:
        from_attributes = True


class MealPlanOut(BaseModel):
    id: int
    period_type: PeriodTypeEnum
    start_date: date
    end_date: date
    total_estimated_cost: Optional[float] = None
    items: List[MealPlanItemOut] = []

    class Config:
        from_attributes = True
