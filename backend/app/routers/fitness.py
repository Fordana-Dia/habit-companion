from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.core.fitness_engine import generate_program_exercises, get_estimated_weeks, TOTAL_PROGRAM_WEEKS
from app.models.user import User
from app.models.user_profile import UserProfile
from app.models.fitness_program import FitnessProgram, ProgramExercise, ProgramExerciseLog
from app.models.points import UserPoints, PointTransaction
from app.schemas.fitness_program import FitnessProgramOut, ExerciseLogCreate, ExerciseLogOut

router = APIRouter(prefix="/fitness", tags=["fitness"])

POINTS_PER_EXERCISE_DONE = 5


@router.post("/generate", response_model=FitnessProgramOut, status_code=status.HTTP_201_CREATED)
def generate_program(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    profile = db.query(UserProfile).filter(UserProfile.user_id == current_user.id).first()
    if not profile or not profile.goal or not profile.training_mode:
        raise HTTPException(
            status_code=400,
            detail="Complète d'abord ton profil (objectif et mode d'entraînement) avant de générer un programme.",
        )

    db.query(FitnessProgram).filter(
        FitnessProgram.user_id == current_user.id, FitnessProgram.is_active == True
    ).update({"is_active": False})

    program = FitnessProgram(
        user_id=current_user.id,
        goal=profile.goal,
        training_mode=profile.training_mode,
        estimated_weeks_to_results=get_estimated_weeks(profile.goal),
        total_weeks=TOTAL_PROGRAM_WEEKS,
        is_active=True,
    )
    db.add(program)
    db.commit()
    db.refresh(program)

    exercises_template = generate_program_exercises(profile.goal, profile.training_mode)
    for week, day, name, sets, reps, duration in exercises_template:
        exercise = ProgramExercise(
            program_id=program.id,
            week_number=week,
            day_of_week=day,
            name=name,
            sets=sets,
            reps=reps,
            duration_minutes=duration,
        )
        db.add(exercise)
    db.commit()
    db.refresh(program)

    return program


@router.get("/active", response_model=FitnessProgramOut)
def get_active_program(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    program = (
        db.query(FitnessProgram)
        .filter(FitnessProgram.user_id == current_user.id, FitnessProgram.is_active == True)
        .first()
    )
    if not program:
        raise HTTPException(status_code=404, detail="Aucun programme actif. Génère-en un d'abord.")
    return program


def _get_owned_exercise(exercise_id: int, db: Session, current_user: User) -> ProgramExercise:
    exercise = (
        db.query(ProgramExercise)
        .join(FitnessProgram)
        .filter(ProgramExercise.id == exercise_id, FitnessProgram.user_id == current_user.id)
        .first()
    )
    if not exercise:
        raise HTTPException(status_code=404, detail="Exercice introuvable")
    return exercise


def _award_points(db: Session, user_id: int, points: int, reason: str):
    user_points = db.query(UserPoints).filter(UserPoints.user_id == user_id).first()
    if user_points is None:
        user_points = UserPoints(user_id=user_id, total_points=0)
        db.add(user_points)
        db.flush()
    user_points.total_points += points
    db.add(PointTransaction(user_id=user_id, points=points, reason=reason))


@router.post("/exercises/{exercise_id}/complete", response_model=ExerciseLogOut, status_code=status.HTTP_201_CREATED)
def complete_exercise(
    exercise_id: int,
    payload: ExerciseLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    exercise = _get_owned_exercise(exercise_id, db, current_user)

    existing = (
        db.query(ProgramExerciseLog)
        .filter(
            ProgramExerciseLog.program_exercise_id == exercise.id,
            ProgramExerciseLog.log_date == payload.log_date,
        )
        .first()
    )
    if existing:
        raise HTTPException(status_code=400, detail="Cet exercice a déjà été validé pour cette date.")

    log = ProgramExerciseLog(program_exercise_id=exercise.id, log_date=payload.log_date)
    db.add(log)

    _award_points(
        db,
        current_user.id,
        POINTS_PER_EXERCISE_DONE,
        f"Exercice '{exercise.name}' complété le {payload.log_date}",
    )

    db.commit()
    db.refresh(log)
    return log
