from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.core.database import get_db
from app.core.deps import get_current_user
from app.core.engine import calculate_streak, get_encouragement_message
from app.models.user import User
from app.models.habit import Habit
from app.models.habit_log import HabitLog
from app.schemas.habit import (
    HabitCreate,
    HabitOut,
    HabitLogCreate,
    HabitLogOut,
    HabitWithStatusOut,
)

router = APIRouter(prefix="/habits", tags=["habits"])


@router.post("/", response_model=HabitOut, status_code=status.HTTP_201_CREATED)
def create_habit(
    payload: HabitCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = Habit(
        user_id=current_user.id,
        name=payload.name,
        target_minutes=payload.target_minutes,
    )
    db.add(habit)
    db.commit()
    db.refresh(habit)
    return habit


@router.get("/", response_model=List[HabitOut])
def list_habits(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return db.query(Habit).filter(Habit.user_id == current_user.id).all()


def _get_owned_habit(habit_id: int, db: Session, current_user: User) -> Habit:
    habit = db.query(Habit).filter(
        Habit.id == habit_id, Habit.user_id == current_user.id
    ).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habitude introuvable")
    return habit


@router.post("/{habit_id}/logs", response_model=HabitLogOut, status_code=status.HTTP_201_CREATED)
def add_log(
    habit_id: int,
    payload: HabitLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = _get_owned_habit(habit_id, db, current_user)
    log = HabitLog(
        habit_id=habit.id,
        log_date=payload.log_date,
        duration_minutes=payload.duration_minutes,
    )
    db.add(log)
    db.commit()
    db.refresh(log)
    return log


@router.get("/{habit_id}/logs", response_model=List[HabitLogOut])
def list_logs(
    habit_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = _get_owned_habit(habit_id, db, current_user)
    return db.query(HabitLog).filter(HabitLog.habit_id == habit.id).order_by(HabitLog.log_date).all()


class HabitStatusOut(BaseModel):
    streak: int
    message: str


@router.get("/{habit_id}/status", response_model=HabitStatusOut)
def get_habit_status(
    habit_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = _get_owned_habit(habit_id, db, current_user)
    logs = db.query(HabitLog).filter(HabitLog.habit_id == habit.id).all()
    return HabitStatusOut(
        streak=calculate_streak(logs),
        message=get_encouragement_message(logs),
    )


@router.get("/with-status", response_model=List[HabitWithStatusOut])
def list_habits_with_status(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habits = db.query(Habit).filter(Habit.user_id == current_user.id).all()
    result = []
    for habit in habits:
        logs = db.query(HabitLog).filter(HabitLog.habit_id == habit.id).all()
        result.append(
            HabitWithStatusOut(
                id=habit.id,
                name=habit.name,
                target_minutes=habit.target_minutes,
                streak=calculate_streak(logs),
                message=get_encouragement_message(logs),
            )
        )
    return result
