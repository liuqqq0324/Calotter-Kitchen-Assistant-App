# Personal Sous Chef

**Personal Sous Chef** is a full-stack “smart kitchen” system: a **Flutter** mobile app talks to a **Spring Boot** modular monolith backed by **PostgreSQL**, with optional **YOLOv8** training for on-device ingredient detection. It supports households, pantry inventory, AI-assisted menu generation, cooking sessions, nutrition logging, and multimodal cooking assistance (voice, pose gestures, camera + local TFLite + optional cloud vision).

This README is written from the **actual files in this repository** (compose files, Maven modules, `application.yml`, workflows, and app config). For a longer Chinese narrative (risks, module map), see [`PROJECT_OVERVIEW.md`](./PROJECT_OVERVIEW.md)—but you do **not** need it to run the project.

---

## What is in this repository?

| Path | Role |
|------|------|
| [`frontend-app/`](./frontend-app/) | Flutter client (HTTP API, auth persistence, camera, STT/TTS, pose, `flutter_vision` YOLO, `google_generative_ai`). |
| [`backend-calotter/`](./backend-calotter/) | Maven multi-module Spring Boot **3.2.0** API (`calotter-start` is the runnable entry). |
| [`yolo-training/`](./yolo-training/) | Python + Ultralytics YOLOv8 train / validate / infer scripts and dataset layout. |
| [`docker-compose.yml`](./docker-compose.yml) (repo root) | Alternate Postgres stack: DB `souschef_db`, user `chef`, port `5432`. Mounts `./database/init.sql`—**that path is not present in the repo as checked**; fix or remove the volume before `docker compose up`. |
| [`backend-calotter/docker-compose.yml`](./backend-calotter/docker-compose.yml) | **Recommended for local backend dev**: Postgres 15, DB `calotter`, user `postgres`, password `123`, port `5432`, container `calotter_postgres`. |
| [`.github/workflows/deploy.yml`](./.github/workflows/deploy.yml) | CI: Maven build in `backend-calotter`, SCP JAR to server, SSH restart on port **8080** with env-injected secrets. Trigger branch is currently **`yhua`**. |

Submodule READMEs: [`backend-calotter/README.md`](./backend-calotter/README.md) (very detailed, includes API list and DB notes), [`yolo-training/README.md`](./yolo-training/README.md). The stock [`frontend-app/README.md`](./frontend-app/README.md) is still the default Flutter stub.

---

## Architecture (backend)

Maven parent [`backend-calotter/pom.xml`](./backend-calotter/pom.xml): **Java 17**, Spring Boot **3.2.0**, PostgreSQL driver **42.7.1**, Lombok, JJWT **0.12.3**.

Modules (see also backend README):

- **`calotter-common`** — shared types, `Result<T>`, global exception handling, auditing helpers, standard-library entities.
- **`calotter-user`** — users, households, JWT utilities, Spring Security configuration (verify policy in code before production).
- **`calotter-inventory`** — ingredients, spices, utensils, leftovers; standard-catalog lookups.
- **`calotter-cooking`** — AI menu generation (Spring AI + Gemini), cooking workflow, dishes/sessions, favorites.
- **`calotter-health`** — `NutritionLog`, `DailyNutrientAggregate`, `/api/nutrition` and `/api/intake`, Groq-based manual nutrition estimation, async listeners for aggregates.
- **`calotter-start`** — `CalotterApplication`, `application.yml`, `DotenvConfig` (loads `.env`).

**Typical request path:** HTTP → Controller → `@Transactional` Service → JPA Repository → PostgreSQL → JSON wrapped in `Result<T>` (`code`, `message`, `data`).

**Events:** e.g. cooking completion publishes `CookingSessionCompletedEvent`; health module creates nutrition logs and publishes `NutritionLogCreatedEvent`; a transactional after-commit async listener updates daily aggregates (see `NutritionLogEventListener`, `@Profile("!test")`).

---

## Architecture (frontend)

- **SDK:** Dart **`^3.10.1`** ([`frontend-app/pubspec.yaml`](./frontend-app/pubspec.yaml)).
- **Networking / state:** `http`, `shared_preferences` (token, user id, household id via `AuthService` and API services under `lib/services/`).
- **Multimodal:** `camera`, `google_mlkit_pose_detection`, `speech_to_text`, `flutter_tts`, `permission_handler`, `wakelock_plus`, `image_picker`, etc.
- **Vision:** local **`flutter_vision`** path package ([`frontend-app/packages/flutter_vision`](./frontend-app/packages/flutter_vision)); optional cloud vision via **`google_generative_ai`**.
- **Backend base URL:** [`frontend-app/lib/core/config/api_config.dart`](./frontend-app/lib/core/config/api_config.dart) — set `serverIp` to:
  - **`10.0.2.2`** for Android emulator → host `localhost`.
  - Your machine’s **LAN IP** for a physical device on the same Wi‑Fi.
  - A public host if you deploy the API.

---

## Prerequisites

| Component | Version / notes |
|-----------|------------------|
| JDK | **17** (matches `pom.xml`). |
| Maven | 3.6+ recommended. |
| Docker | For Postgres via compose. |
| Flutter | Compatible with **Dart SDK ^3.10.1** (`flutter --version`). |
| Python | 3.x for `yolo-training` and optional SQL helpers under backend. |

---

## Quick start: backend + database

### 1) Start PostgreSQL (recommended compose)

From [`backend-calotter/docker-compose.yml`](./backend-calotter/docker-compose.yml):

```bash
cd backend-calotter
docker compose up -d
```

This exposes **5432** with database **`calotter`**, user **`postgres`**, password **`123`** (development defaults from the file).

**Port conflict:** If another Postgres already uses 5432, stop it or change the host port mapping in compose and align `spring.datasource.url` in `application.yml`.

### 2) Configure AI keys (menu + manual nutrition)

Copy the template and fill keys **without committing `.env`**:

```bash
cd backend-calotter
cp env.template .env
# Edit .env: at least GEMINI_API_KEY and GROQ_API_KEY (see env.template comments)
```

[`backend-calotter/env.template`](./backend-calotter/env.template) documents:

- **`GEMINI_API_KEY`** — Spring AI Gemini (menu generation; `application.yml` also references `GEMINI_PROJECT_ID` for Google GenAI—set it if your account requires a project id).
- **`GROQ_API_KEY`** — manual nutrition estimation. The health module reads **`ai.nutrition.*`** in Java (`GroqManualNutritionEstimator`, `AiNutritionEstimatorConfig`); `application.yml` also contains a **`spring.nutrition`** block—if Groq fails to pick up the key, align properties or rely on **`GROQ_API_KEY`** in `.env` / the process environment (the config class checks both).

[`DotenvConfig`](./backend-calotter/calotter-start/src/main/java/com/calotter/config/DotenvConfig.java) searches for `.env` relative to the working directory / project tree when the app starts; keeping `.env` under **`backend-calotter/`** matches the template instructions.

### 3) Run the API

```bash
cd backend-calotter/calotter-start
mvn spring-boot:run
```

Default listen: **`0.0.0.0:8080`** ([`application.yml`](./backend-calotter/calotter-start/src/main/resources/application.yml)).

**Schema & seed data:**

- JPA **`ddl-auto: update`** creates/updates tables.
- **`spring.sql.init.mode: always`** + **`defer-datasource-initialization: true`** runs [`data.sql`](./backend-calotter/calotter-start/src/main/resources/data.sql) after Hibernate schema generation (standard allergens, ingredients, spices, utensils, etc.).

Full rebuild / TRUNCATE workflows and curl examples are documented in [`backend-calotter/README.md`](./backend-calotter/README.md).

### 4) Root `docker-compose.yml` (optional)

The root file starts **`souschef_db`** / user **`chef`**—**different credentials** from `backend-calotter/docker-compose.yml`. The default Spring config points at **`calotter`** on localhost; if you use the root compose, either change JDBC URL/username/password to match **or** only use the backend compose for consistency.

Also verify `./database/init.sql` exists if you keep the `volumes` entry; the repository snapshot used for this README did **not** include a `database/` tree—remove or add that file before `docker compose up` at the repo root.

---

## Quick start: Flutter app

```bash
cd frontend-app
flutter pub get
flutter run
```

**Point the app at your API:**

1. Edit [`frontend-app/lib/core/config/api_config.dart`](./frontend-app/lib/core/config/api_config.dart): `serverIp` and `port` (`8080` by default).
2. Physical device: phone and PC must share a network; OS firewall must allow inbound **8080** on the host running Spring Boot.

**Permissions:** camera, microphone, and possibly storage/photos are used for scanning and multimodal features—grant them when prompted.

**Cloud Gemini in the app:** the Flutter file may contain a **client-side API key placeholder** for cloud vision / “expert” features. **Do not ship production builds with a committed key**; prefer runtime configuration (e.g. `--dart-define`, remote config) and rotate any key that was ever committed to git.

---

## Quick start: YOLO training

See [`yolo-training/README.md`](./yolo-training/README.md).

```bash
cd yolo-training
pip install ultralytics
# Prepare dataset/ per README, then:
python train.py
```

Training exports under `runs/` (Ultralytics defaults). Integrating new weights into the mobile app is project-specific (TFLite assets + `flutter_vision`); align label indices with backend standard ingredients where applicable (backend README mentions `yolo_labels_config.dart` / `ingredient_icon_config.dart` alignment).

---

## CI / deployment

[`.github/workflows/deploy.yml`](./.github/workflows/deploy.yml):

- Runs **`mvn -B clean install -DskipTests`** in **`./backend-calotter`**.
- Copies `calotter-start/target/*.jar` to **`/opt/calotter`** on the server.
- SSH step frees **8080**, then `nohup java -jar …` with JDBC URL `jdbc:postgresql://localhost:5432/calotter` and password from **`DB_PASSWORD`** secret.

**Secrets referenced:** `SERVER_HOST`, `SERVER_USER`, `SSH_PRIVATE_KEY`, `DB_PASSWORD`, `GEMINI_API_KEY`, `GEMINI_PROJECT_ID`, `GROQ_API_KEY`.

To use this pipeline in your fork, retarget the `on.push.branches` list and mirror secrets in GitHub.

---

## API surface (short)

All JSON APIs observed in code use the shared **`Result<T>`** envelope.

Representative routes (non-exhaustive; full list in [`backend-calotter/README.md`](./backend-calotter/README.md)):

| Area | Base path | Examples |
|------|-----------|----------|
| Users / auth | `/api/user` | `POST /register`, `POST /login`, preferences, allergies, health goal. |
| Households | `/api/household` | Create/join/leave/switch, invite codes. |
| Inventory | `/api/inventory` | CRUD for ingredients/spices/utensils/leftovers; standard catalog `GET` endpoints. |
| AI & cooking | `/api/ai`, `/api/cooking`, `/api/recipes` | `POST /api/ai/generate-menus`, start/finish cooking, favorites. |
| Nutrition | `/api/nutrition`, `/api/intake` | Weekly/daily summaries, manual logs, leftover logs, today’s intakes, dish slider APIs. |

**Client usage:** many endpoints accept **`userId`** (and sometimes `householdId`) as query parameters. Treat authorization as **application-level** until you verify Spring Security filter rules in `calotter-user`—do not assume server-side isolation from IDs alone.

---

## Practical troubleshooting

| Symptom | What to check |
|---------|----------------|
| Flutter “connection refused” | Backend running? `serverIp` correct? Emulator → `10.0.2.2`; real device → LAN IP; server `server.address` is `0.0.0.0` in `application.yml`. |
| Postgres auth errors | JDBC URL must match **the** compose file you started (`calotter`+`postgres`/`123` vs `souschef_db`+`chef`). |
| AI menu or manual nutrition fails | `.env` or OS env: `GEMINI_API_KEY`, `GROQ_API_KEY`, and `GEMINI_PROJECT_ID` if required. |
| Standard tables empty | Ensure `data.sql` ran (see `spring.sql.init` + `defer-datasource-initialization`); backend README has `psql` / Python fallbacks. |
| Port 8080 busy | Stop other services or override `server.port` for local runs; deployment script kills listeners on 8080 on the server. |
| Root compose fails on init.sql | Add `database/init.sql` or remove the `./database/init.sql` bind mount from root `docker-compose.yml`. |

---

## Security & hygiene (read before production)

1. **Secrets:** rotate any API key or DB password that ever appeared in git history. Prefer environment variables or a secret manager; never commit `.env`.
2. **JWT / Spring Security:** review `SecurityConfig` and JWT filter behavior—development setups sometimes use permissive rules; lock down before exposing the API publicly.
3. **CORS / HTTPS:** front channel is plain HTTP in dev config; use TLS and strict CORS in production.
4. **Scheduler / async:** health module runs scheduled jobs (e.g. leftover conversion) and async listeners—understand DB load and idempotency when scaling horizontally.

---

## Contributing / docs map

- **Deep backend + API catalog + DB reset recipes:** [`backend-calotter/README.md`](./backend-calotter/README.md)  
- **Training pipeline & GPU tips:** [`yolo-training/README.md`](./yolo-training/README.md)  
- **Chinese high-level overview + risk notes:** [`PROJECT_OVERVIEW.md`](./PROJECT_OVERVIEW.md)  
- **License:** add a `LICENSE` file at the repo root if you open-source this project.

---

## License

No root `LICENSE` file was present when this README was generated. Add one appropriate to your organization before public distribution.
