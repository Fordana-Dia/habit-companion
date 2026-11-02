from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.location_finances import UserLocation, UserFinances
from app.models.allergy import UserAllergy
from app.models.premium import PremiumSubscription
from app.schemas.premium import (
    LocationUpdate,
    LocationOut,
    FinancesUpdate,
    FinancesOut,
    AllergyCreate,
    AllergyOut,
    SubscriptionOut,
)

router = APIRouter(prefix="/premium", tags=["premium"])


def _require_premium(db: Session, user_id: int):
    sub = db.query(PremiumSubscription).filter(PremiumSubscription.user_id == user_id).first()
    if not sub or not sub.is_active:
        raise HTTPException(
            status_code=403,
            detail="Cette fonctionnalité nécessite un abonnement premium actif.",
        )


@router.get("/status", response_model=SubscriptionOut)
def get_subscription_status(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    sub = db.query(PremiumSubscription).filter(PremiumSubscription.user_id == current_user.id).first()
    if not sub:
        return SubscriptionOut(is_active=False)
    return sub


@router.post("/activate", response_model=SubscriptionOut)
def activate_subscription(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Active l'abonnement premium (paiement à intégrer plus tard)."""
    sub = db.query(PremiumSubscription).filter(PremiumSubscription.user_id == current_user.id).first()
    if sub is None:
        sub = PremiumSubscription(user_id=current_user.id, is_active=True)
        db.add(sub)
    else:
        sub.is_active = True
    db.commit()
    db.refresh(sub)
    return sub


@router.put("/location", response_model=LocationOut)
def update_location(
    payload: LocationUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_premium(db, current_user.id)
    location = db.query(UserLocation).filter(UserLocation.user_id == current_user.id).first()
    if location is None:
        location = UserLocation(user_id=current_user.id)
        db.add(location)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(location, field, value)
    db.commit()
    db.refresh(location)
    return location


@router.put("/finances", response_model=FinancesOut)
def update_finances(
    payload: FinancesUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_premium(db, current_user.id)
    finances = db.query(UserFinances).filter(UserFinances.user_id == current_user.id).first()
    if finances is None:
        finances = UserFinances(user_id=current_user.id, currency="XAF")
        db.add(finances)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(finances, field, value)
    db.commit()
    db.refresh(finances)
    return finances


@router.post("/allergies", response_model=AllergyOut, status_code=status.HTTP_201_CREATED)
def add_allergy(
    payload: AllergyCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_premium(db, current_user.id)
    allergy = UserAllergy(user_id=current_user.id, allergy_name=payload.allergy_name)
    db.add(allergy)
    db.commit()
    db.refresh(allergy)
    return allergy


@router.get("/allergies", response_model=List[AllergyOut])
def list_allergies(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _require_premium(db, current_user.id)
    return db.query(UserAllergy).filter(UserAllergy.user_id == current_user.id).all()
