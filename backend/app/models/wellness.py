import enum
from sqlalchemy import Column, Integer, Date, ForeignKey, DateTime, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class WellnessCategoryEnum(str, enum.Enum):
    hydration = "hydration"
    hygiene = "hygiene"
    fruits = "fruits"
    sleep = "sleep"
    other = "other"


class WellnessHabit(Base):
    __tablename__ = "wellness_habits"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    category = Column(Enum(WellnessCategoryEnum), nullable=False)
    target_value = Column(Integer, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", backref="wellness_habits")


class WellnessLog(Base):
    __tablename__ = "wellness_logs"

    id = Column(Integer, primary_key=True, index=True)
    wellness_habit_id = Column(Integer, ForeignKey("wellness_habits.id"), nullable=False)
    log_date = Column(Date, nullable=False)
    value = Column(Integer, nullable=False)

    wellness_habit = relationship("WellnessHabit", backref="logs")
