from datetime import date
from pydantic import BaseModel


class HabitCreate(BaseModel):
    name: str
    target_minutes: int


class HabitOut(BaseModel):
    id: int
    name: str
    target_minutes: int

    class Config:
        from_attributes = True


class HabitLogCreate(BaseModel):
    log_date: date
    duration_minutes: int


class HabitLogOut(BaseModel):
    id: int
    log_date: date
    duration_minutes: int

    class Config:
        from_attributes = True


class HabitWithStatusOut(BaseModel):
    id: int
    name: str
    target_minutes: int
    streak: int
    message: str
