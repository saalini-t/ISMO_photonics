# REST API Documentation

The Project Management System backend exposes a RESTful JSON API.

## Base URL
- **Local / Container**: `http://localhost:3000/api`
- **Android Emulator**: `http://10.0.2.2:3000/api`

---

## Authentication & Headers

All protected endpoints require a JWT Bearer token in the `Authorization` header:

```http
Authorization: Bearer <your-jwt-token>
Content-Type: application/json
```

Standard API Response Envelope:
```json
{
  "success": true,
  "message": "Optional response summary message",
  "data": { ... }
}
```

Standard Error Response Envelope:
```json
{
  "success": false,
  "message": "Error description",
  "errors": [
    { "field": "email", "message": "Invalid email address" }
  ]
}
```

---

## 1. Authentication Endpoints

### Register User
- **POST** `/api/auth/register`
- **Auth Required**: No (Rate limited: 10 requests / 15 min)

#### Request Body
```json
{
  "fullName": "Jane Doe",
  "email": "jane@example.com",
  "password": "securepassword123"
}
```

#### Response (201 Created)
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "u123-uuid",
      "fullName": "Jane Doe",
      "email": "jane@example.com",
      "createdAt": "2024-10-07T20:00:00.000Z",
      "updatedAt": "2024-10-07T20:00:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsIn..."
  }
}
```

---

### Login User
- **POST** `/api/auth/login`
- **Auth Required**: No (Rate limited: 10 requests / 15 min)

#### Request Body
```json
{
  "email": "jane@example.com",
  "password": "securepassword123"
}
```

#### Response (200 OK)
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "u123-uuid",
      "fullName": "Jane Doe",
      "email": "jane@example.com"
    },
    "token": "eyJhbGciOiJIUzI1NiIsIn..."
  }
}
```

---

### Get Current User Profile
- **GET** `/api/auth/me`
- **Auth Required**: Yes

#### Response (200 OK)
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "u123-uuid",
      "fullName": "Jane Doe",
      "email": "jane@example.com"
    }
  }
}
```

---

### Logout User
- **POST** `/api/auth/logout`
- **Auth Required**: Yes

#### Response (200 OK)
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 2. Project Endpoints

### List Projects
- **GET** `/api/projects`
- **Auth Required**: Yes
- **Query Parameters**:
  - `page` (number, default: 1)
  - `limit` (number, default: 10, max: 100)
  - `search` (string, optional - filters by project name)
  - `status` (enum: `NOT_STARTED`, `IN_PROGRESS`, `COMPLETED`, optional)
  - `sortBy` (enum: `createdAt`, `name`, `status`, `startDate`, `endDate`, default: `createdAt`)
  - `sortOrder` (enum: `asc`, `desc`, default: `desc`)

#### Response (200 OK)
```json
{
  "success": true,
  "data": [
    {
      "id": "p100-uuid",
      "name": "Mobile Redesign",
      "description": "Revamp mobile UI with Flutter Material 3",
      "status": "IN_PROGRESS",
      "startDate": "2024-10-01T00:00:00.000Z",
      "endDate": "2024-11-01T00:00:00.000Z",
      "createdAt": "2024-10-07T20:00:00.000Z",
      "updatedAt": "2024-10-07T20:00:00.000Z",
      "userId": "u123-uuid",
      "_count": {
        "tasks": 4
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "totalCount": 1,
    "totalPages": 1
  }
}
```

---

### Get Project Details
- **GET** `/api/projects/:id`
- **Auth Required**: Yes

#### Response (200 OK)
```json
{
  "success": true,
  "data": {
    "id": "p100-uuid",
    "name": "Mobile Redesign",
    "description": "Revamp mobile UI with Flutter Material 3",
    "status": "IN_PROGRESS",
    "startDate": "2024-10-01T00:00:00.000Z",
    "endDate": "2024-11-01T00:00:00.000Z",
    "tasks": [
      {
        "id": "t200-uuid",
        "name": "Setup GoRouter",
        "priority": "HIGH",
        "status": "COMPLETED"
      }
    ]
  }
}
```

---

### Create Project
- **POST** `/api/projects`
- **Auth Required**: Yes

#### Request Body
```json
{
  "name": "New Photonics Platform",
  "description": "High performance simulation suite",
  "status": "NOT_STARTED",
  "startDate": "2024-10-15T00:00:00.000Z",
  "endDate": "2024-12-31T00:00:00.000Z"
}
```

#### Response (201 Created)
```json
{
  "success": true,
  "message": "Project created successfully",
  "data": {
    "id": "p101-uuid",
    "name": "New Photonics Platform",
    "status": "NOT_STARTED"
  }
}
```

---

### Update Project
- **PUT** `/api/projects/:id`
- **Auth Required**: Yes

#### Request Body
```json
{
  "status": "IN_PROGRESS"
}
```

---

### Delete Project
- **DELETE** `/api/projects/:id`
- **Auth Required**: Yes (Cascades and deletes associated tasks)

#### Response (200 OK)
```json
{
  "success": true,
  "message": "Project deleted successfully"
}
```

---

## 3. Task Endpoints

### List Tasks
- **GET** `/api/tasks`
- **Auth Required**: Yes
- **Query Parameters**: `page`, `limit`, `search`, `status` (`PENDING`, `IN_PROGRESS`, `COMPLETED`), `priority` (`LOW`, `MEDIUM`, `HIGH`), `projectId`, `sortBy`, `sortOrder`.

---

### Create Task
- **POST** `/api/tasks`
- **Auth Required**: Yes

#### Request Body
```json
{
  "name": "Implement JWT middleware",
  "description": "Add authorization interceptor to routes",
  "priority": "HIGH",
  "status": "PENDING",
  "dueDate": "2024-10-20T00:00:00.000Z",
  "projectId": "p100-uuid"
}
```

---

### Update Task
- **PUT** `/api/tasks/:id`
- **Auth Required**: Yes

---

### Delete Task
- **DELETE** `/api/tasks/:id`
- **Auth Required**: Yes

---

## 4. Dashboard Endpoint

### Get Dashboard Statistics
- **GET** `/api/dashboard`
- **Auth Required**: Yes

#### Response (200 OK)
```json
{
  "success": true,
  "data": {
    "totalProjects": 5,
    "projectsInProgress": 2,
    "totalTasks": 15,
    "completedTasks": 8,
    "pendingTasks": 4,
    "tasksInProgress": 3
  }
}
```

