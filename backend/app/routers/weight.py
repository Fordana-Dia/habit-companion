from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.weight_log import WeightLog
from app.schemas.weight_log import WeightLogCreate, WeightLogOut

router = APIRouter(prefix="/weight", tags=["weight"])


@router.post("/", response_model=WeightLogOut, status_code=status.HTTP_201_CREATED)
def add_weight_log(
    payload: WeightLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    log = WeightLog(
        user_id=current_user.id,
        log_date=payload.log_date,
        weight_kg=payload.weight_kg,
    )
    db.add(log)
    db.commit()
    db.refresh(log)
    return log


@router.get("/", response_model=List[WeightLogOut])
def list_weight_logs(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return (
        db.query(WeightLog)
        .filter(WeightLog.user_id == current_user.id)
        .order_by(WeightLog.log_date)
        .all()
    )
