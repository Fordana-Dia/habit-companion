from datetime import date, timedelta
from typing import List
from app.models.habit_log import HabitLog

MESSAGES_DEBUT = [
    "Bienvenue dans cette nouvelle habitude, chaque début compte.",
    "Premier pas fait, c'est déjà une victoire.",
]

MESSAGES_RELANCE = [
    "La série s'est arrêtée, mais rien n'est perdu. On reprend aujourd'hui ?",
    "Un jour manqué ne change rien à ce que tu as déjà accompli. On repart ?",
]


def calculate_streak(logs: List[HabitLog]) -> int:
    """Calcule le nombre de jours consécutifs jusqu'à aujourd'hui (ou hier si rien fait aujourd'hui)."""
    if not logs:
        return 0

    log_dates = sorted({log.log_date for log in logs}, reverse=True)
    today = date.today()

    if log_dates[0] not in (today, today - timedelta(days=1)):
        return 0

    streak = 1
    for i in range(1, len(log_dates)):
        if log_dates[i - 1] - log_dates[i] == timedelta(days=1):
            streak += 1
        else:
            break
    return streak


def _pluriel_jour(n: int) -> str:
    return "jour" if n == 1 else "jours"


def get_encouragement_message(logs: List[HabitLog]) -> str:
    """Choisit un message selon la progression de l'utilisateur sur cette habitude."""
    streak = calculate_streak(logs)

    if not logs:
        return MESSAGES_DEBUT[0]
    if streak == 0:
        return MESSAGES_RELANCE[0]
    if streak >= 7:
        return f"{streak} {_pluriel_jour(streak)} consécutifs, c'est une vraie habitude maintenant."
    return f"{streak} {_pluriel_jour(streak)} d'affilée, tu tiens le rythme."
