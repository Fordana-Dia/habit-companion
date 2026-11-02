from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.wellness import WellnessHabit, WellnessLog
from app.models.points import UserPoints, PointTransaction
from app.schemas.wellness import (
    WellnessHabitCreate,
    WellnessHabitOut,
    WellnessLogCreate,
    WellnessLogOut,
    UserPointsOut,
)

router = APIRouter(prefix="/wellness", tags=["wellness"])

POINTS_PER_GOAL_REACHED = 10


@router.post("/habits", response_model=WellnessHabitOut, status_code=status.HTTP_201_CREATED)
def create_wellness_habit(
    payload: WellnessHabitCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = WellnessHabit(
        user_id=current_user.id,
        category=payload.category,
        target_value=payload.target_value,
    )
    db.add(habit)
    db.commit()
    db.refresh(habit)
    return habit


@router.get("/habits", response_model=List[WellnessHabitOut])
def list_wellness_habits(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return db.query(WellnessHabit).filter(WellnessHabit.user_id == current_user.id).all()


def _get_owned_wellness_habit(habit_id: int, db: Session, current_user: User) -> WellnessHabit:
    habit = db.query(WellnessHabit).filter(
        WellnessHabit.id == habit_id, WellnessHabit.user_id == current_user.id
    ).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habitude bien-être introuvable")
    return habit


def _award_points(db: Session, user_id: int, points: int, reason: str):
    user_points = db.query(UserPoints).filter(UserPoints.user_id == user_id).first()
    if user_points is None:
        user_points = UserPoints(user_id=user_id, total_points=0)
        db.add(user_points)
        db.flush()

    user_points.total_points += points
    db.add(PointTransaction(user_id=user_id, points=points, reason=reason))


@router.post("/habits/{habit_id}/logs", response_model=WellnessLogOut, status_code=status.HTTP_201_CREATED)
def add_wellness_log(
    habit_id: int,
    payload: WellnessLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    habit = _get_owned_wellness_habit(habit_id, db, current_user)
    log = WellnessLog(
        wellness_habit_id=habit.id,
        log_date=payload.log_date,
        value=payload.value,
    )
    db.add(log)

    if payload.value >= habit.target_value:
        _award_points(
            db,
            current_user.id,
            POINTS_PER_GOAL_REACHED,
            f"Objectif {habit.category.value} atteint le {payload.log_date}",
        )

    db.commit()
    db.refresh(log)
    return log


@router.get("/points", response_model=UserPointsOut)
def get_points(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    user_points = db.query(UserPoints).filter(UserPoints.user_id == current_user.id).first()
    if user_points is None:
        return UserPointsOut(total_points=0)
    return user_points
