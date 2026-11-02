from typing import Optional
from pydantic import BaseModel
from app.models.user_profile import GoalEnum, TrainingModeEnum


class UserProfileCreate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    current_weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    goal: Optional[GoalEnum] = None
    training_mode: Optional[TrainingModeEnum] = None


class UserProfileOut(BaseModel):
    id: int
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    current_weight_kg: Optional[float] = None
    height_cm: Optional[float] = None
    goal: Optional[GoalEnum] = None
    training_mode: Optional[TrainingModeEnum] = None

    class Config:
        from_attributes = True
