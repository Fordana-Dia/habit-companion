from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.routers import auth, habits, profile, weight, fitness, wellness, premium, meal_plan

app = FastAPI(
    title="Habit Companion API",
    version="0.1.0",
    description="API du companion d'habitudes bienveillant",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(habits.router)
app.include_router(profile.router)
app.include_router(weight.router)
app.include_router(fitness.router)
app.include_router(wellness.router)
app.include_router(premium.router)
app.include_router(meal_plan.router)


@app.get("/health")
def health_check():
    """Endpoint simple pour vérifier que l'API et sa config répondent."""
    return {"status": "ok", "env": settings.ENV}
