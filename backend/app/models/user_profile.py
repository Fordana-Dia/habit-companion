import enum
from sqlalchemy import Column, Integer, String, Float, Enum, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class GoalEnum(str, enum.Enum):
    lose_weight = "lose_weight"
    gain_weight = "gain_weight"
    maintain_weight = "maintain_weight"


class TrainingModeEnum(str, enum.Enum):
    gym = "gym"
    home = "home"


class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    first_name = Column(String, nullable=True)
    last_name = Column(String, nullable=True)
    current_weight_kg = Column(Float, nullable=True)
    height_cm = Column(Float, nullable=True)
    goal = Column(Enum(GoalEnum), nullable=True)
    training_mode = Column(Enum(TrainingModeEnum), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", backref="profile", uselist=False)
