# Project Setup & Execution Guide

This document provides step-by-step instructions for running the **Project Management System** (Backend, Database, and Flutter Mobile/Web App).

---

## 1. Prerequisites

Ensure you have the following installed on your development system:

- **Node.js**: v18.0.0 or higher (v20+ recommended)
- **Docker & Docker Compose**: Desktop v24+
- **Flutter SDK**: 3.19.0 or higher
- **PostgreSQL**: Optional for local native runs (v16 recommended if running outside Docker)
- **Git**: Latest version

---

## 2. Quickstart with Docker Compose (Recommended)

The simplest way to bring up the database and Node.js backend is using Docker Compose.

```bash
# 1. Clone the repository
git clone https://github.com/saalini-t/ISMO_photonics.git
cd ISMO_photonics

# 2. Start PostgreSQL & Backend services in containerized environment
docker compose up --build -d

# 3. Verify services status
docker compose ps
```

The services will be available at:
- **Backend API**: `http://localhost:3000/api`
- **Health Check**: `http://localhost:3000/api/health`
- **PostgreSQL**: `localhost:5432` (database: `project_mgmt`, user: `postgres`, password: `postgres`)

To view container logs:
```bash
docker compose logs -f backend
```

---

## 3. Local Backend Setup (Without Docker)

If you prefer to run the Node.js backend directly on your host system:

### Step 1: Start PostgreSQL
Ensure PostgreSQL is running locally on port 5432, or set your custom database URL in `backend/.env`.

### Step 2: Configure Environment Variables
Copy the example environment file:
```bash
cd backend
cp .env.example .env
```

Default `.env` configuration:
```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/project_mgmt"
JWT_SECRET="secret"
JWT_EXPIRES_IN="24h"
PORT=3000
NODE_ENV="development"
CORS_ORIGIN="*"
```

### Step 3: Install Dependencies & Run Database Migrations
```bash
# Install NPM packages
npm install

# Run Prisma schema migrations to apply database tables
npm run prisma:migrate

# (Optional) Seed the database with sample users, projects, and tasks
npm run prisma:seed
```

### Step 4: Start the Backend Server
```bash
# Start in development mode with nodemon auto-reloading
npm run dev

# Or start in production mode
npm start
```

### Step 5: Run Backend Tests
```bash
npm test
```

---

## 4. Flutter Mobile & Web Setup

The `mobile/` application is a cross-platform Flutter codebase supporting Android and Web form factors.

### Step 1: Install Dependencies
```bash
cd mobile
flutter pub get
```

### Step 2: Configure Network Endpoint
The Flutter app automatically resolves the correct API base URL based on target platform in `lib/utils/constants.dart`:
- **Android Emulator**: Uses `http://10.0.2.2:3000/api`
- **Web / iOS Simulator / Desktop**: Uses `http://localhost:3000/api`

If running on a physical Android device over Wi-Fi, update `lib/utils/constants.dart` with your machine's local IP address (e.g., `http://192.168.1.100:3000/api`).

### Step 3: Run the Flutter App

#### Run on Chrome (Web)
```bash
flutter run -d chrome --web-port 3000
```

#### Run on Android Emulator / Connected Device
```bash
flutter run -d android
```

### Step 4: Run Flutter Tests
```bash
flutter test
```

---

## 5. Environment Variables Reference

| Variable | Description | Default / Example Value | Required |
|---|---|---|---|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://postgres:postgres@localhost:5432/project_mgmt` | Yes |
| `JWT_SECRET` | Secret key for signing authentication tokens | `super-secret-jwt-key-change-in-production-2024` | Yes |
| `JWT_EXPIRES_IN` | Token expiration duration | `24h` | Yes |
| `PORT` | Node.js Express server listening port | `3000` | No (Default: 3000) |
| `NODE_ENV` | Application environment (`development`, `test`, `production`) | `development` | No |
| `CORS_ORIGIN` | Allowed CORS origins for web requests | `*` | No |

