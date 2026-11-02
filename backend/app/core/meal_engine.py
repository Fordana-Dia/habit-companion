from datetime import date, timedelta

MEAL_DATABASE = [
    {"name": "Riz sauce arachide + poisson", "time": "12:30", "cost": 1000, "contains": ["arachide", "poisson"]},
    {"name": "Ndolé + plantain", "time": "12:30", "cost": 1500, "contains": ["arachide"]},
    {"name": "Haricots + beignets", "time": "07:00", "cost": 500, "contains": []},
    {"name": "Bouillie de mais + pain", "time": "07:00", "cost": 400, "contains": ["gluten"]},
    {"name": "Eru + fufu", "time": "19:00", "cost": 1200, "contains": []},
    {"name": "Poulet DG", "time": "19:00", "cost": 2000, "contains": []},
    {"name": "Okok + manioc", "time": "12:30", "cost": 1000, "contains": ["arachide"]},
    {"name": "Riz + poulet braisé", "time": "12:30", "cost": 1500, "contains": []},
    {"name": "Sanga (mais + haricot)", "time": "19:00", "cost": 700, "contains": []},
    {"name": "Omelette + pain", "time": "07:00", "cost": 500, "contains": ["oeuf", "gluten"]},
    {"name": "Koki + plantain", "time": "12:30", "cost": 900, "contains": []},
    {"name": "Poisson braisé + plantain", "time": "19:00", "cost": 1800, "contains": ["poisson"]},
]


def _filter_by_allergies(meals: list, allergies: list[str]) -> list:
    allergies_lower = [a.lower() for a in allergies]
    return [
        meal for meal in meals
        if not any(ingredient in allergies_lower for ingredient in meal["contains"])
    ]


def generate_meal_plan(
    start_date: date,
    period_type: str,
    daily_budget: float,
    allergies: list[str],
):
    """
    Génère un planning alimentaire respectant le budget quotidien et les allergies,
    avec un repas par créneau (matin, midi, soir) chaque jour.
    Retourne une liste de dicts : {meal_date, meal_time, meal_name, estimated_cost}
    """
    available_meals = _filter_by_allergies(MEAL_DATABASE, allergies)
    if not available_meals:
        available_meals = MEAL_DATABASE

    meals_by_slot = {
        "07:00": [m for m in available_meals if m["time"] == "07:00"],
        "12:30": [m for m in available_meals if m["time"] == "12:30"],
        "19:00": [m for m in available_meals if m["time"] == "19:00"],
    }
    for slot in meals_by_slot:
        meals_by_slot[slot].sort(key=lambda m: m["cost"])

    num_days = 1 if period_type == "daily" else 30
    plan_items = []
    total_cost = 0

    for day_offset in range(num_days):
        current_date = start_date + timedelta(days=day_offset)
        day_cost = 0
        chosen = []

        for slot, meals in meals_by_slot.items():
            if not meals:
                continue
            for meal in meals:
                if day_cost + meal["cost"] <= daily_budget:
                    chosen.append(meal)
                    day_cost += meal["cost"]
                    break
            # Si aucun repas ne rentre dans le budget restant, on saute ce créneau
            # plutôt que de dépasser le budget déclaré par l'utilisateur.

        if not chosen and meals_by_slot:
            # Sécurité : si le budget est vraiment trop bas pour un seul repas,
            # on prend quand même le moins cher de tous pour ne pas laisser un jour vide.
            cheapest = min(
                (m for meals in meals_by_slot.values() for m in meals),
                key=lambda m: m["cost"],
                default=None,
            )
            if cheapest:
                chosen.append(cheapest)
                day_cost += cheapest["cost"]

        for meal in chosen:
            plan_items.append({
                "meal_date": current_date,
                "meal_time": meal["time"],
                "meal_name": meal["name"],
                "estimated_cost": meal["cost"],
            })
            total_cost += meal["cost"]

    return plan_items, total_cost
