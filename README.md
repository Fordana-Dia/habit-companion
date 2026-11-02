![CI](https://github.com/Fordana-Dia/habit-companion/actions/workflows/ci.yml/badge.svg)

# Habit Companion — Setup initial

## Structure du projet

```
habit-companion/
├── docker-compose.yml
├── .env.example
├── .gitignore
└── backend/
    ├── Dockerfile
    ├── requirements.txt
    └── app/
        ├── main.py          # point d'entrée FastAPI
        ├── core/
        │   └── config.py    # config lue depuis .env
        ├── models/          # modèles SQLAlchemy (à venir)
        ├── routers/         # routes API (à venir)
        └── schemas/         # schémas Pydantic (à venir)
```

## Démarrage — étape par étape

### 1. Copier le fichier d'environnement
```bash
cp .env.example .env
```
Puis ouvrir `.env` avec gedit et remplacer `change_moi` par de vraies valeurs (mot de passe DB, clé JWT).

### 2. Lancer les conteneurs
```bash
docker compose up --build
```
Cette commande construit l'image du backend et démarre PostgreSQL + FastAPI ensemble.

### 3. Vérifier que ça fonctionne
Ouvrir dans le navigateur :
- `http://localhost:8000/health` → doit répondre `{"status": "ok", "env": "development"}`
- `http://localhost:8000/docs` → documentation interactive Swagger générée automatiquement

### 4. Arrêter les conteneurs
```bash
docker compose down
```
(ajouter `-v` seulement si tu veux aussi supprimer les données de la base)

## Prochaines étapes (dans l'ordre)
1. Modèle de données (utilisateurs, habitudes, suivi quotidien) dans `app/models/`
2. Auth JWT (inscription, connexion) dans `app/routers/`
3. Migrations avec Alembic
4. Moteur de règles bienveillant (logique gratuite, sans IA)
5. Intégration API IA externe (couche premium)
