# Full-Stack Project Management System (Web & Mobile)

A production-ready, full-stack Project Management System built with a shared Node.js/Express REST API backend, PostgreSQL database (via Prisma ORM), and a cross-platform Flutter application serving both Web and Android form factors.

---

## 🌟 Key Features

- **🔐 Dual-Platform Authentication**:
  - Secure registration, login, logout, and token validation.
  - Shared account credentials work seamlessly across Web and Mobile.
  - Passwords hashed with `bcryptjs` (10 salt rounds).
  - JWT authorization tokens with secure mobile device storage (`Android Keystore` / `iOS Keychain`).
  - Rate limiting on auth endpoints (10 requests per 15 minutes per IP).

- **📁 Project Management (CRUD)**:
  - Full CRUD operations for project entities (Name, Description, Status, Start Date, End Date).
  - Search by project name and filter by status (`NOT_STARTED`, `IN_PROGRESS`, `COMPLETED`).
  - Strict user data isolation guarantee (users only access their owned projects).
  - Cascading delete logic removes associated tasks automatically.

- **✅ Task Management (CRUD)**:
  - Full CRUD operations for tasks linked to projects.
  - Priority levels (`LOW`, `MEDIUM`, `HIGH`) and Status workflow (`PENDING`, `IN_PROGRESS`, `COMPLETED`).
  - Quick-toggle status checkboxes and due date tracking.
  - Multi-attribute search and filtering (by name, status, priority, project).

- **📊 Interactive Dashboard**:
  - Real-time aggregated statistics (Total Projects, Projects In Progress, Total Tasks, Completed Tasks, Pending Tasks).
  - Responsive layout with pull-to-refresh (`RefreshIndicator`) on mobile.

- **🌐 Network Error & Offline Handling**:
  - Clear user-facing notifications for network drops and connection timeouts.
  - Automatic session recovery and token expiration (401) handling returning users to login screen smoothly.

- **🐳 Dockerized Environment**:
  - One-command startup via Docker Compose (`PostgreSQL 16` database + `Express` backend API).

---

## 🏗 System Architecture & Monorepo Structure

```
.
├── backend/                  # Node.js + Express REST API Backend
│   ├── prisma/               # Database Schema, Migrations & Seeder
│   │   ├── schema.prisma     # Relational Database Models
│   │   └── seed.js           # Test Data Seeder
│   ├── src/
│   │   ├── config/           # Environment configuration
│   │   ├── controllers/      # Express Route Handlers (Auth, Projects, Tasks, Dashboard)
│   │   ├── middleware/       # JWT Auth, Validation, Error Handling, Rate Limiter
│   │   ├── routes/           # REST API Endpoint Routers
│   │   ├── services/         # Business Logic Layer
│   │   ├── utils/            # Logger, ApiError, JWT, Pagination
│   │   └── validators/       # Zod Request Validation Schemas
│   ├── tests/                # Jest Integration & Unit Tests (64 passing test cases)
│   ├── Dockerfile            # Alpine Linux Container Definition
│   └── package.json
│
├── mobile/                   # Cross-Platform Flutter App (Web + Android)
│   ├── lib/
│   │   ├── models/           # Data Models (User, Project, Task, DashboardStats)
│   │   ├── providers/        # Riverpod State Management Notifiers
│   │   ├── screens/          # Material 3 UI Screens
│   │   ├── services/         # Dio ApiService, StorageService, Feature Services
│   │   ├── utils/            # GoRouter configuration & Constants
│   │   └── widgets/          # Reusable Dialogs & Cards
│   └── test/                 # Flutter Widget & Model Unit Tests (11 passing tests)
│
├── docs/                     # Technical Documentation
│   ├── SETUP.md              # Installation & Setup Guide
│   ├── API.md                # Full REST API Reference
│   ├── DATABASE.md           # ER Diagram & Schema Details
│   └── MOBILE.md             # Mobile Architecture & Build Guide
│
├── docker-compose.yml        # Multi-container orchestration
└── README.md
```

---

## ⚡ Quickstart Guide

### 1. Start Database & Backend with Docker Compose
```bash
docker compose up --build -d
```
- **Backend API**: `http://localhost:3000/api`
- **Health Check**: `http://localhost:3000/api/health`

### 2. Run the Flutter App

#### Web Mode (Chrome)
```bash
cd mobile
flutter run -d chrome --web-port 3000
```

#### Android Mode (Emulator / Connected Device)
```bash
cd mobile
flutter run -d android
```

---

## 🧪 Testing

### Backend Test Suite (Jest & Supertest)
```bash
cd backend
npm test
```
*Result: 7 test suites, 64 tests passing (Auth, Projects, Tasks, Dashboard, Validators, JWT, Pagination).*

### Flutter Test Suite (Widget & Unit Tests)
```bash
cd mobile
flutter test
```
*Result: 11 tests passing (Models, Riverpod State Providers, Form Validation, UI Widget Rendering).*

---

## 📚 Technical Documentation

For detailed technical documentation, please refer to the `docs/` folder:
- [Setup & Environment Guide](file:///Users/harini/Desktop/shalu/docs/SETUP.md)
- [REST API Specification](file:///Users/harini/Desktop/shalu/docs/API.md)
- [Database Schema & ER Diagram](file:///Users/harini/Desktop/shalu/docs/DATABASE.md)
- [Mobile Architecture & Deployment](file:///Users/harini/Desktop/shalu/docs/MOBILE.md)

---

## 📜 License & Author

- **Author**: Saalini Thirunavukkarasu
- **Repository**: [https://github.com/saalini-t/ISMO_photonics.git](https://github.com/saalini-t/ISMO_photonics.git)
- **License**: MIT
