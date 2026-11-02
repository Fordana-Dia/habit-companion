from datetime import date
from pydantic import BaseModel


class WeightLogCreate(BaseModel):
    log_date: date
    weight_kg: float


class WeightLogOut(BaseModel):
    id: int
    log_date: date
    weight_kg: float

    class Config:
        from_attributes = True
