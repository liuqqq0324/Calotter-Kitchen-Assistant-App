# Personal Sous Chef

A **home-kitchen assistant** delivered mainly as a **mobile app**: manage pantry and leftovers, generate **AI-backed menus** from what you have, follow **step-by-step cooking**, and track **nutrition**. Households let family members share one kitchen context (inventory, leftovers, invites).

---

## What the product does (features)

### Account and profile
- **Sign up / sign in** — Create an account; credentials and session data are persisted on the device so you can reopen the app quickly.
- **Diet and health** — Set allergies, diet habits, ingredients to avoid, and health goals (e.g. daily calories). These feed **AI menu generation** and **nutrition targets**.

### Household collaboration
- **Create or join a household** — Start a household or join another with an **invite code** or **QR scan** (as implemented in the app).
- **Switch active household** — Inventory, leftovers, and invites follow the **currently selected** household when a user belongs to more than one.
- **Member management** — Owners can invite or remove members (exact UI flows are in the household screens).

### Pantry inventory
- **Ingredients** — Pick from a **standard catalog**, set quantity, unit, storage (e.g. fridge / freezer), optional expiry.
- **Spices and utensils** — Same pattern; used when generating menus and cooking so the app knows **what you have at home**.
- **Leftovers** — After a meal, uneaten food can be stored as leftovers; later you can log how much you ate and tie it to nutrition and remaining quantity.

### AI menus and cooking
- **Generate menus** — Uses household stock, servings, tastes, allergies, and health goals to propose **multiple menu options** (requires a **configured backend** with AI keys).
- **Start cooking** — Opens a **cooking session** with step-by-step instructions and ingredients.
- **Finish cooking** — Confirms completion; the backend updates stock, creates or updates leftovers as designed, and records nutrition when that flow runs.

### Nutrition and health
- **Today’s intake** — See what you logged today from recipes, leftovers, or manual entries.
- **Manual snacks / meals** — Enter a food name and rough portion; the server **estimates** calories and macros and stores a log.
- **Leftover intake** — Pick a household leftover and use a **percentage slider**; nutrition and leftover weight update together.
- **Daily / weekly views** — Compare **targets vs consumed** to pace your week.

### Smart assistance while cooking (on cooking-related screens)
- **Voice** — Hands-free commands for next/previous step, timers, etc. (**Microphone** permission required.)
- **Gestures** — Camera-based simple gestures to move through steps (**Camera** permission required.)
- **Photo ingredient recognition** — Take a photo to suggest ingredients (local model and/or cloud vision, depending on build and configuration).

### Model training (team / advanced)
- The **`yolo-training`** folder is for **retraining** ingredient-detection models. Typical end users only install a **prebuilt app** and do not need this.

---

## How end users typically use it

1. **Install the app** — From your team’s build (APK/TestFlight/internal store) or a published store listing.
2. **Register and sign in** — On first use, set **allergies** and basic **health goals** so AI and nutrition stay safe and meaningful.
3. **Create or join a household** — First user creates a household and shares the invite; others join via code or QR.
4. **Add pantry items** — In inventory, add ingredients, spices, and utensils; add expiry dates where it helps you use food in time.
5. **Generate a menu** — On the recipe generation screen, set people, taste, time, etc., then generate and pick a menu to cook.
6. **Cook and finish** — Follow steps; use **voice or gestures** if you want hands-free control; complete the **finish** flow so stock and leftovers stay accurate.
7. **Log nutrition when needed** — Add manual items for snacks/takeout; log leftover portions with the slider; check daily/weekly summaries occasionally.

If you only use a **team-hosted server**, you do not need the developer steps below—your admin must give you a reachable **API base URL** baked into or configurable for your build.

---

## Technical overview

| Layer | Technology | Location |
|-------|------------|----------|
| Mobile app | Flutter (Dart SDK **^3.10.1**), HTTP, local preferences, camera, speech, pose ML Kit, local YOLO via `flutter_vision`, optional Gemini client | `frontend-app/` |
| API server | **Java 17**, **Spring Boot 3.2.0**, Spring Data JPA, PostgreSQL, Spring AI (Gemini) for menus, Groq-style HTTP for manual nutrition estimates | `backend-calotter/` |
| Database | PostgreSQL **15** (Docker) | `backend-calotter/docker-compose.yml` (recommended for local dev) |
| Training | Python, Ultralytics YOLOv8 | `yolo-training/` |

Backend is a **modular monolith**: `calotter-common`, `calotter-user`, `calotter-inventory`, `calotter-cooking`, `calotter-health`, runnable **`calotter-start`**. APIs return a JSON envelope **`Result<T>`** (`code`, `message`, `data`). Deeper architecture and API tables: [`backend-calotter/README.md`](./backend-calotter/README.md) and [`PROJECT_OVERVIEW.md`](./PROJECT_OVERVIEW.md) (Chinese, broader project notes).

---

## Repository layout

| Path | Purpose |
|------|---------|
| `frontend-app/` | Flutter application source |
| `backend-calotter/` | Maven multi-module Spring Boot API |
| `yolo-training/` | Dataset + scripts to train/validate YOLO models |
| `docker-compose.yml` (repo root) | Alternate Postgres (`souschef_db` / user `chef`). Default Spring config targets DB **`calotter`** — align credentials or prefer backend compose only. Root compose references `./database/init.sql`; if that file is missing, remove the volume line or add the script before `docker compose up`. |
| `.github/workflows/deploy.yml` | CI: build JAR under `backend-calotter`, deploy to a server (branch and secrets are defined in the workflow file). |

---

## Developer quick start

### Prerequisites
- **JDK 17**, **Maven 3.6+**, **Docker** (for Postgres), **Flutter** compatible with the app’s `pubspec.yaml` SDK constraint.

### 1) Database (recommended)

```bash
cd backend-calotter
docker compose up -d
```

Default from [`backend-calotter/docker-compose.yml`](./backend-calotter/docker-compose.yml): database **`calotter`**, user **`postgres`**, password **`123`**, port **5432**. Matches the JDBC URL in [`calotter-start/.../application.yml`](./backend-calotter/calotter-start/src/main/resources/application.yml).

### 2) Environment variables (AI)

```bash
cd backend-calotter
cp env.template .env
# Edit .env — at minimum GEMINI_API_KEY and GROQ_API_KEY (see env.template).
# If your Google setup requires it, set GEMINI_PROJECT_ID as well.
```

Do **not** commit `.env`. Spring loads it via [`DotenvConfig`](./backend-calotter/calotter-start/src/main/java/com/calotter/config/DotenvConfig.java) when present under `backend-calotter/`.

### 3) Run the API

```bash
cd backend-calotter/calotter-start
mvn spring-boot:run
```

Default: **http://0.0.0.0:8080**. JPA **`ddl-auto: update`** plus **`data.sql`** seed standard catalogs on startup (see `application.yml`).

### 4) Run the Flutter app

```bash
cd frontend-app
flutter pub get
flutter run
```

Point the client at your API in [`frontend-app/lib/core/config/api_config.dart`](./frontend-app/lib/core/config/api_config.dart):

- **Android emulator → host machine:** `serverIp = "10.0.2.2"`, port **8080**.
- **Physical device:** use your PC’s **LAN IP**; phone and PC must be on the same Wi‑Fi; host firewall must allow **8080**.

Grant **camera** and **microphone** where the OS prompts, for gesture/voice features.

### 5) Optional: train YOLO

Follow [`yolo-training/README.md`](./yolo-training/README.md) (`pip install ultralytics`, prepare `dataset/`, run `train.py`).

---

## Security and privacy (short)

- Do not share passwords or invite codes with untrusted people.  
- Keep **API keys and DB passwords** in environment variables or a secret manager; never commit them to git.  
- **Rotate** any key that was ever committed by mistake.  
- Review Spring Security / JWT settings before exposing the API to the public internet; prefer **HTTPS** in production.  
- For client-side cloud keys (e.g. Gemini in Flutter), prefer **build-time defines** or remote config instead of hardcoding keys in source.

---

## More documentation

| Document | Contents |
|----------|----------|
| [`backend-calotter/README.md`](./backend-calotter/README.md) | Detailed backend setup, DB reset, API listing, ER notes |
| [`PROJECT_OVERVIEW.md`](./PROJECT_OVERVIEW.md) | Chinese project-wide overview and risks |
| [`yolo-training/README.md`](./yolo-training/README.md) | Training parameters and troubleshooting |

Add a root **`LICENSE`** if you distribute or open-source the project.
