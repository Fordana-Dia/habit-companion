from datetime import date
from pydantic import BaseModel
from app.models.wellness import WellnessCategoryEnum


class WellnessHabitCreate(BaseModel):
    category: WellnessCategoryEnum
    target_value: int


class WellnessHabitOut(BaseModel):
    id: int
    category: WellnessCategoryEnum
    target_value: int

    class Config:
        from_attributes = True


class WellnessLogCreate(BaseModel):
    log_date: date
    value: int


class WellnessLogOut(BaseModel):
    id: int
    log_date: date
    value: int

    class Config:
        from_attributes = True


class UserPointsOut(BaseModel):
    total_points: int

    class Config:
        from_attributes = True
