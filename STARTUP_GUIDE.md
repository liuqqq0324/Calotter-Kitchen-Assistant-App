# Personal Sous Chef - Startup Guide

Complete guide to start the Personal Sous Chef project.

## Prerequisites

### Required Software
1. **Docker Desktop** - For PostgreSQL database
   - Download: https://www.docker.com/products/docker-desktop
   - Ensure Docker Desktop is running

2. **.NET SDK 10.0** - For C# backend
   - Download: https://dotnet.microsoft.com/download
   - Verify: `dotnet --version`

3. **Flutter SDK** - For Flutter frontend
   - Download: https://flutter.dev/docs/get-started/install
   - Verify: `flutter --version`

4. **Android Studio** - For Android emulator (or use physical device)

---

## Quick Start

### Step 1: Start Database (PostgreSQL)

```bash
# From project root directory
docker-compose up -d postgres

# Verify it's running
docker ps
```

### Step 2: Start Backend (C#)

```bash
cd backend-csharp

# First time: install dependencies
dotnet restore

# Start backend service
dotnet run
```

Backend will run on **port 5108**.

### Step 3: Start Frontend (Flutter)

```bash
# Open new terminal window
cd frontend-app

# First time: install dependencies
flutter pub get

# Start Flutter app
flutter run
```

---

## Service URLs

- **Backend API**: `http://localhost:5108`
- **Database**: `localhost:5432`
- **Frontend**: Running on emulator/device

---

## Troubleshooting

### Database won't start
- Ensure Docker Desktop is running
- Check port 5432 is not in use

### Backend can't connect to database
- Wait 10-30 seconds for database to fully start
- Check database logs: `docker-compose logs postgres`

### Frontend can't connect to backend
- Verify backend is running
- Check `frontend-app/lib/config/api_config.dart` for correct IP/port
- For Android emulator: use `10.0.2.2:5108`
- For physical device: use your computer's local network IP

---

## Stop Services

```bash
# Stop database
docker-compose down

# Stop backend/frontend
# Press Ctrl+C in respective terminal windows
```

---

For detailed instructions, see `启动指南.md` (Chinese version).

