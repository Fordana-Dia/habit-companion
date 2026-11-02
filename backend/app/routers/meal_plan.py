from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.core.meal_engine import generate_meal_plan
from app.models.user import User
from app.models.premium import PremiumSubscription
from app.models.location_finances import UserFinances
from app.models.allergy import UserAllergy
from app.models.meal_plan import MealPlan, MealPlanItem
from app.schemas.meal_plan import MealPlanGenerate, MealPlanOut

router = APIRouter(prefix="/meal-plan", tags=["meal-plan"])


def _require_premium(db: Session, user_id: int):
    sub = db.query(PremiumSubscription).filter(PremiumSubscription.user_id == user_id).first()
    if not sub or not sub.is_active:
        raise HTTPException(
            status_code=403,
            detail="Cette fonctionnalité nécessite un abonnement premium actif.",
        )


@router.post("/generate", response_model=MealPlanOut, status_code=status.HTTP_201_CREATED)
def generate_plan(
    payload: MealPlanGenerate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_premium(db, current_user.id)

    finances = db.query(UserFinances).filter(UserFinances.user_id == current_user.id).first()
    if not finances or not finances.monthly_budget:
        raise HTTPException(
            status_code=400,
            detail="Renseigne d'abord ton budget avant de générer un planning.",
        )

    allergies = [a.allergy_name for a in db.query(UserAllergy).filter(UserAllergy.user_id == current_user.id).all()]

    daily_budget = finances.monthly_budget / 30

    items_data, total_cost = generate_meal_plan(
        start_date=payload.start_date,
        period_type=payload.period_type.value,
        daily_budget=daily_budget,
        allergies=allergies,
    )

    num_days = 1 if payload.period_type.value == "daily" else 30
    end_date = payload.start_date + timedelta(days=num_days - 1)

    plan = MealPlan(
        user_id=current_user.id,
        period_type=payload.period_type,
        start_date=payload.start_date,
        end_date=end_date,
        total_estimated_cost=total_cost,
    )
    db.add(plan)
    db.commit()
    db.refresh(plan)

    for item in items_data:
        db.add(MealPlanItem(
            meal_plan_id=plan.id,
            meal_date=item["meal_date"],
            meal_time=item["meal_time"],
            meal_name=item["meal_name"],
            estimated_cost=item["estimated_cost"],
        ))
    db.commit()
    db.refresh(plan)

    return plan


@router.get("/latest", response_model=MealPlanOut)
def get_latest_plan(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_premium(db, current_user.id)
    plan = (
        db.query(MealPlan)
        .filter(MealPlan.user_id == current_user.id)
        .order_by(MealPlan.created_at.desc())
        .first()
    )
    if not plan:
        raise HTTPException(status_code=404, detail="Aucun planning généré pour l'instant.")
    return plan
