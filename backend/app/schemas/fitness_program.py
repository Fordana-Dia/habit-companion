from datetime import date
from typing import Optional, List
from pydantic import BaseModel
from app.models.user_profile import GoalEnum, TrainingModeEnum


class ProgramExerciseOut(BaseModel):
    id: int
    week_number: int
    day_of_week: int
    name: str
    sets: Optional[int] = None
    reps: Optional[int] = None
    duration_minutes: Optional[int] = None

    class Config:
        from_attributes = True


class FitnessProgramOut(BaseModel):
    id: int
    goal: GoalEnum
    training_mode: TrainingModeEnum
    estimated_weeks_to_results: Optional[int] = None
    total_weeks: int
    is_active: bool
    exercises: List[ProgramExerciseOut] = []

    class Config:
        from_attributes = True


class ExerciseLogCreate(BaseModel):
    log_date: date


class ExerciseLogOut(BaseModel):
    id: int
    log_date: date

    class Config:
        from_attributes = True
