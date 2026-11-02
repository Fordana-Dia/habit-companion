from app.models.user_profile import GoalEnum, TrainingModeEnum

# Modèles d'exercices de BASE (semaine 1) par objectif + mode d'entraînement
# Chaque entrée : (jour_de_semaine, nom, sets, reps, duree_minutes)

BASE_TEMPLATES = {
    (GoalEnum.lose_weight, TrainingModeEnum.home): [
        (1, "Marche rapide", None, None, 20),
        (2, "Squats", 3, 10, None),
        (3, "Repos actif / étirements", None, None, 15),
        (4, "Jumping jacks + gainage", 3, 12, None),
        (5, "Marche rapide", None, None, 20),
        (6, "Squats + fentes", 3, 10, None),
        (7, "Repos", None, None, None),
    ],
    (GoalEnum.lose_weight, TrainingModeEnum.gym): [
        (1, "Cardio (tapis/vélo)", None, None, 20),
        (2, "Circuit training", 3, 10, None),
        (3, "Repos actif", None, None, 15),
        (4, "Cardio + abdominaux", None, None, 20),
        (5, "Circuit training", 3, 10, None),
        (6, "Cardio", None, None, 20),
        (7, "Repos", None, None, None),
    ],
    (GoalEnum.gain_weight, TrainingModeEnum.home): [
        (1, "Pompes + squats", 3, 8, None),
        (2, "Repos", None, None, None),
        (3, "Gainage + fentes", 3, 8, None),
        (4, "Repos", None, None, None),
        (5, "Pompes + squats + dips", 3, 8, None),
        (6, "Repos actif", None, None, 15),
        (7, "Repos", None, None, None),
    ],
    (GoalEnum.gain_weight, TrainingModeEnum.gym): [
        (1, "Musculation - haut du corps", 3, 8, None),
        (2, "Musculation - bas du corps", 3, 8, None),
        (3, "Repos", None, None, None),
        (4, "Musculation - haut du corps", 3, 8, None),
        (5, "Musculation - bas du corps", 3, 8, None),
        (6, "Repos actif", None, None, 15),
        (7, "Repos", None, None, None),
    ],
    (GoalEnum.maintain_weight, TrainingModeEnum.home): [
        (1, "Marche + étirements", None, None, 20),
        (2, "Circuit léger", 3, 10, None),
        (3, "Repos", None, None, None),
        (4, "Marche + étirements", None, None, 20),
        (5, "Circuit léger", 3, 10, None),
        (6, "Activité libre", None, None, 15),
        (7, "Repos", None, None, None),
    ],
    (GoalEnum.maintain_weight, TrainingModeEnum.gym): [
        (1, "Cardio léger", None, None, 20),
        (2, "Musculation légère", 3, 10, None),
        (3, "Repos", None, None, None),
        (4, "Cardio léger", None, None, 20),
        (5, "Musculation légère", 3, 10, None),
        (6, "Activité libre", None, None, 15),
        (7, "Repos", None, None, None),
    ],
}

ESTIMATED_WEEKS = {
    GoalEnum.lose_weight: 8,
    GoalEnum.gain_weight: 12,
    GoalEnum.maintain_weight: 4,
}

TOTAL_PROGRAM_WEEKS = 4  # nombre de semaines générées à l'avance, avec progression


def _progress_value(value, increment, week_number):
    """Augmente une valeur (reps ou minutes) selon la semaine, si elle existe."""
    if value is None:
        return None
    return value + increment * (week_number - 1)


def generate_program_exercises(goal: GoalEnum, training_mode: TrainingModeEnum):
    """
    Génère les exercices pour TOUTES les semaines du programme (TOTAL_PROGRAM_WEEKS),
    avec une intensité progressive :
    - +2 répétitions par semaine (si l'exercice a des reps)
    - +5 minutes par semaine (si l'exercice a une durée)
    Retourne une liste de tuples (week_number, day_of_week, name, sets, reps, duration_minutes)
    """
    base = BASE_TEMPLATES.get((goal, training_mode), [])
    result = []

    for week in range(1, TOTAL_PROGRAM_WEEKS + 1):
        for day, name, sets, reps, duration in base:
            new_reps = _progress_value(reps, 2, week)
            new_duration = _progress_value(duration, 5, week)
            result.append((week, day, name, sets, new_reps, new_duration))

    return result


def get_estimated_weeks(goal: GoalEnum) -> int:
    return ESTIMATED_WEEKS.get(goal, 8)
