from typing import Optional, List
from pydantic import BaseModel


class LocationUpdate(BaseModel):
    city: Optional[str] = None
    neighborhood: Optional[str] = None


class LocationOut(BaseModel):
    city: Optional[str] = None
    neighborhood: Optional[str] = None

    class Config:
        from_attributes = True


class FinancesUpdate(BaseModel):
    weekly_budget: Optional[float] = None
    monthly_budget: Optional[float] = None
    currency: Optional[str] = None


class FinancesOut(BaseModel):
    weekly_budget: Optional[float] = None
    monthly_budget: Optional[float] = None
    currency: str

    class Config:
        from_attributes = True


class AllergyCreate(BaseModel):
    allergy_name: str


class AllergyOut(BaseModel):
    id: int
    allergy_name: str

    class Config:
        from_attributes = True


class SubscriptionOut(BaseModel):
    is_active: bool

    class Config:
        from_attributes = True
