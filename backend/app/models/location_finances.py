from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base


class UserLocation(Base):
    __tablename__ = "user_locations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    city = Column(String, nullable=True)
    neighborhood = Column(String, nullable=True)

    user = relationship("User", backref="location", uselist=False)


class UserFinances(Base):
    __tablename__ = "user_finances"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    weekly_budget = Column(Float, nullable=True)
    monthly_budget = Column(Float, nullable=True)
    currency = Column(String, default="XAF")

    user = relationship("User", backref="finances", uselist=False)
