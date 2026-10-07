Phase 1: Backend + Database Foundation
    Set up project structure (monorepo or separate repos)
    PostgreSQL schema design + ER diagram
    Prisma models & migrations
    Auth endpoints (register, login, logout, me)
    JWT middleware, bcrypt hashing, rate limiting
    Input validation (e.g., Zod or Joi)
    Error handling & logging middleware
Phase 2: Backend — Projects & Tasks API
    Full CRUD for Projects (/api/projects)
    Full CRUD for Tasks (/api/tasks)
    Authorization (users can only access their own data)
    Dashboard endpoint (/api/dashboard)
    Search & filtering (query params for name, status, priority)
    API documentation
Phase 3: Web Frontend (Next.js)
    Auth pages (register, login, logout)
    Dashboard page with stats
    Projects list + detail + create/edit/delete
    Tasks list within projects + create/edit/delete + status toggle
    Search & filter UI
    Responsive design, loading states, error handling
    Form validation
Phase 4: Mobile App (Flutter)
    Auth screens (register, login, logout)
    Secure token storage (Android Keystore / iOS Keychain)
    Dashboard screen
    Projects list + tasks under each project
    Task CRUD, status/priority changes
    Search & filter
    Pull-to-refresh, offline/no-network handling, token expiry handling
Phase 5: Polish, Bonus & Deployment
    Docker support (Compose for backend + DB)
    Unit & integration tests
    Pagination & sorting
    Refresh tokens (if not done in Phase 1)
    Deploy backend + web (e.g., Railway/Render + Vercel)
    Build Android APK
    README, setup docs, env var docs
    ER diagram export
    Screen recording