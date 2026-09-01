# Architecture

## Overview

AI LifeOS is a local-first iOS application with an optional backend for AI and news services.

```
iOS SwiftUI App
      |
+-----+-----+
|           |
SwiftData   API Client
(local)     (HTTPS)
              |
           Backend
         /    |    \
    PostgreSQL Redis AI/News
```

## iOS Layers

```
View → ViewModel → Service/UseCase → Repository → SwiftData
```

- **Views**: SwiftUI only, no business logic
- **ViewModels**: `@Observable`, feature state
- **Repositories**: Data access protocols
- **Services**: Scheduling, notifications, networking

## Modules

| Module | Purpose |
|--------|---------|
| `Core/DesignSystem` | Reusable UI components and theme |
| `Core/Persistence` | SwiftData models and repositories |
| `Core/Networking` | API client (no secrets in app) |
| `Core/Notifications` | Local notification scheduling |
| `Features/*` | Feature screens and ViewModels |

## Data Flow

- **Offline**: Schedule, tasks, streaks, timers work from SwiftData
- **Online**: AI chat, planning, daily news via backend proxy
- **Sync**: Local SwiftData is primary; backend serves AI/news only (MVP)

## Security

- API keys live on backend only
- Keychain for auth tokens (when accounts added)
- AI returns validated JSON; never silently overwrites schedule

See [PLAN.md](../PLAN.md) for full specification.
