from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, Date, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base
from app.models.user_profile import GoalEnum, TrainingModeEnum


class FitnessProgram(Base):
    __tablename__ = "fitness_programs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    goal = Column(Enum(GoalEnum), nullable=False)
    training_mode = Column(Enum(TrainingModeEnum), nullable=False)
    estimated_weeks_to_results = Column(Integer, nullable=True)
    total_weeks = Column(Integer, default=4)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", backref="fitness_programs")


class ProgramExercise(Base):
    __tablename__ = "program_exercises"

    id = Column(Integer, primary_key=True, index=True)
    program_id = Column(Integer, ForeignKey("fitness_programs.id"), nullable=False)
    week_number = Column(Integer, nullable=False, default=1)
    day_of_week = Column(Integer, nullable=False)
    name = Column(String, nullable=False)
    sets = Column(Integer, nullable=True)
    reps = Column(Integer, nullable=True)
    duration_minutes = Column(Integer, nullable=True)

    program = relationship("FitnessProgram", backref="exercises")


class ProgramExerciseLog(Base):
    __tablename__ = "program_exercise_logs"

    id = Column(Integer, primary_key=True, index=True)
    program_exercise_id = Column(Integer, ForeignKey("program_exercises.id"), nullable=False)
    log_date = Column(Date, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    exercise = relationship("ProgramExercise", backref="logs")
