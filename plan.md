# AI LifeOS — iOS Application
## Cursor Master Plan / Production Build Specification

> **Goal:** Build a polished, responsive iOS-first personal operating system that manages college, personal work, coding, tasks, reminders, streaks, sleep, music, and a daily briefing of exactly 10 AI-related news updates. The app should feel like a premium native iOS product, not a basic CRUD calendar.

---

# 1. Product Vision

Build one application that answers:

- What do I need to do right now?
- What do I need to finish today?
- How much time should I give my personal coding?
- What did I miss?
- How should missed work be rescheduled?
- What is my current streak?
- How is my week going?
- What are today's 10 important AI updates?
- Can AI help me break a project into actionable steps?
- When should I sleep/wake up?
- What music should play while sleeping?
- How can my college timetable coexist with my personal work?

The app must be **local-first**, fast, offline-capable for core scheduling, and designed so cloud/AI features can be added safely.

---

# 2. Important Product Rules

1. Never hard-code API keys into the iOS app.
2. AI requests must go through a secure backend/proxy.
3. News must come from a reliable news/search ingestion layer; the AI model is used for classification, summarization, ranking and explanation, not as the sole source of current news.
4. Core schedule/task functionality must work without internet.
5. Notifications must be scheduled locally whenever possible.
6. User data must be private by default.
7. Sunday must be configurable as a college holiday and default to OFF.
8. The user must be able to edit every generated schedule.
9. AI suggestions must never silently overwrite the user's schedule.
10. The UI must support Dynamic Type, VoiceOver, Dark Mode, reduced motion, and all supported iPhone sizes.

---

# 3. Recommended Stack

## iOS

- Swift
- SwiftUI
- Swift Concurrency / async-await
- SwiftData for local persistence
- UserNotifications for reminders
- WidgetKit for widgets
- App Intents for Siri/Shortcuts integration
- AVFoundation for sleep audio
- EventKit for optional Apple Calendar integration
- BackgroundTasks where appropriate
- CloudKit/iCloud as an optional sync layer

## Backend

Recommended:

- TypeScript
- Node.js
- Fastify or Express
- PostgreSQL
- Redis for caching/rate limiting
- Scheduled worker/cron for daily AI-news ingestion
- REST API initially
- Server-side AI provider integration

A small Python service can be introduced later if required for advanced AI/news processing.

## AI

Create a provider abstraction:

```text
AIProvider
 ├── GeminiProvider
 ├── OpenAIProvider (optional future)
 └── MockAIProvider
```

Do not tightly couple the entire app to one AI provider.

## News

Create:

```text
NewsProvider
 ├── NewsAPIProvider
 ├── RSSProvider
 └── SearchProvider
```

Use source URLs and publication metadata so every news item has attribution.

---

# 4. High-Level Architecture

```text
                   iOS SwiftUI App
                         |
              +----------+----------+
              |                     |
        Local App State         API Client
              |                     |
          SwiftData             HTTPS/TLS
              |                     |
      +-------+-------+             |
      |               |             |
 Schedule/Tasks   Notifications     |
                                  Backend
                                    |
                 +------------------+------------------+
                 |                  |                  |
             PostgreSQL          Redis            AI Provider
                 |                                   |
                 +------------------+------------------+
                                    |
                               News Providers
                                    |
                              Daily 10 AI News
```

---

# 5. Core Modules

The app should be split into feature modules.

```text
App
Core
  ├── DesignSystem
  ├── Networking
  ├── Persistence
  ├── Notifications
  ├── Analytics
  ├── Security
  └── Utilities

Features
  ├── Onboarding
  ├── Today
  ├── Schedule
  ├── Tasks
  ├── Goals
  ├── Streaks
  ├── AI Coach
  ├── AI News
  ├── Focus
  ├── Sleep
  ├── College
  ├── Insights
  └── Settings

Widgets
  ├── TodayWidget
  ├── NextTaskWidget
  ├── StreakWidget
  └── AI News Widget
```

---

# 6. Main Navigation

Use a premium five-tab structure:

```text
Today
Schedule
Tasks
AI
Profile
```

The Today screen is the default landing screen.

---

# 7. Today Dashboard

The Today screen must be the most polished screen.

## Header

```text
Good Evening, [Name]

Tuesday, September 1

🔥 7 day streak
```

## Current Task Card

Show:

- task title
- category
- remaining time
- progress
- start/complete button
- snooze button
- reschedule button

Example:

```text
NOW

💻 Personal Coding
6:00 PM — 8:30 PM

01:42:19 remaining

[ Focus ] [ Complete ]
```

## Today's Goals

Display progress:

```text
Today's Progress
██████████░░ 78%

4 / 5 goals completed
```

## Timeline

Show the entire day vertically.

## Quick Actions

```text
+ Task
+ Event
+ Goal
AI Plan
Focus
```

---

# 8. User's Default Routine

Provide onboarding defaults based on the current requirements:

```text
06:30 Wake Up
07:00 Morning routine
07:30 Bath
08:00 Breakfast / preparation
08:30 Travel
09:00 College
16:30 College ends
17:30 Reach home
17:30–18:00 Rest / freshen up
18:00–20:30 Personal Coding
20:30–21:30 Cooking + Dinner
21:30–22:00 Dinner / cleanup
22:00–23:30 Personal Coding / Deep Work
23:30 Wind Down
23:45 Sleep
```

These are only onboarding defaults. Every time must be editable.

College:

```text
Monday–Saturday: 09:00–16:30
Sunday: Holiday
Travel home: until approximately 17:30
```

Allow the user to change these values.

---

# 9. Schedule Engine

Create a scheduling engine instead of simply storing calendar events.

Inputs:

```text
Fixed Events
Recurring Events
Tasks
Task Duration
Priority
Deadline
Available Time
Sleep Window
College Window
Personal Preferences
```

Output:

```text
Recommended Schedule
```

## Scheduling Rules

Priority order:

1. Fixed commitments
2. Sleep
3. Deadlines
4. High-priority personal work
5. College work
6. Personal coding
7. Routine tasks
8. Optional activities

But the user must be able to change priorities.

## No silent changes

When the AI/scheduler proposes a new schedule:

```text
Schedule updated proposal

6:00–7:30 Coding
7:30–8:00 Dinner
8:00–9:00 Coding

[Apply] [Edit] [Cancel]
```

---

# 10. Task System

Each task should support:

```text
id
title
description
category
priority
estimatedDuration
deadline
scheduledStart
scheduledEnd
status
repeatRule
goalId
projectId
createdAt
completedAt
notes
```

Statuses:

```text
planned
inProgress
completed
skipped
missed
postponed
cancelled
```

Task actions:

- Start
- Complete
- Snooze
- Reschedule
- Skip
- Duplicate
- Break into subtasks
- Ask AI

---

# 11. Personal Coding System

Create a dedicated Coding section.

Features:

- Coding projects
- Project goals
- Tasks
- Sessions
- Focus timer
- Time tracking
- Streak
- Weekly coding hours
- AI project planning

Example:

```text
Project: My AI App

Goal:
Build MVP

Today:
☐ Build onboarding
☐ Create task model
☐ Implement notifications
☐ Test AI endpoint
```

---

# 12. Focus Mode

Focus screen:

```text
PERSONAL CODING

01:42:12

Build notification system

Today's coding:
2h 14m / 3h target

[Pause]
[Finish]
```

When focus begins:

- Schedule local notification
- Start timer
- Track session
- Update productivity statistics
- Optionally integrate with Focus/Shortcuts where Apple APIs permit

---

# 13. POP-POP Notification Engine

Create a NotificationScheduler service.

Reminder types:

```text
Before task:
5 min
10 min
15 min
30 min
Custom

At start

Before end:
5 min
10 min

Missed task

Daily morning briefing

Night wind-down

Sleep

Wake-up
```

Example:

```text
🔔 Coding starts in 15 minutes
```

At task start:

```text
💻 Coding Time
Your planned session has started.
```

Missed:

```text
⚠️ You missed this task.

[Start Now]
[Move to Later]
[Tomorrow]
```

Important: iOS notification behavior is constrained by Apple's notification APIs. Do not promise arbitrary alarm-like behavior for every notification. Use proper local notifications, sound, critical-alert capabilities only where Apple approval/entitlement permits, and standard notification interaction otherwise.

---

# 14. Streak Engine

Streaks should be based on configurable rules.

Examples:

```text
Coding Streak
Daily coding target completed

Task Streak
Daily goal completion >= configured percentage

Sleep Streak
Sleep window followed within tolerance

Overall Streak
Daily minimum score reached
```

Store:

```text
currentStreak
longestStreak
lastQualifiedDate
streakType
```

Do not punish the user for manually configured rest days.

Add:

```text
Rest Day
Recovery Day
Vacation Mode
```

These can protect streaks according to user settings.

---

# 15. AI Coach

Create an AI chat interface with structured actions.

The AI should receive only the minimum context necessary:

```text
Today's schedule
Available time
Tasks
Goals
Recent completion statistics
User preferences
```

Capabilities:

### Plan my day

User:

```text
Aaj mere paas 4 ghante hain.
```

AI returns structured JSON:

```json
{
  "suggestions": [
    {
      "title": "Personal Coding",
      "durationMinutes": 120,
      "priority": "high"
    }
  ]
}
```

The app renders this and asks for confirmation.

### Break task down

```text
Build my login system
```

Returns:

```text
1. Design auth flow
2. Create data model
3. Implement login
4. Add validation
5. Test
```

### Idea generation

```text
Mere project me next kya feature add karu?
```

### Schedule repair

If tasks are missed:

```text
Repair my evening schedule
```

AI proposes a new schedule without overwriting existing data until confirmed.

---

# 16. AI Safety / Reliability

Never allow AI to:

- Directly delete all user data
- Directly overwrite a full schedule
- Make purchases
- Send external messages without explicit user action
- Expose API keys
- Access unrelated private data

AI should return validated structured data.

Use:

```text
JSON Schema validation
Zod on backend
Codable models on iOS
```

Reject malformed AI output.

---

# 17. Daily AI News — Exactly 10

This is a major feature.

Every day create exactly 10 curated AI news items.

Categories:

```text
1. Major AI company update
2. New AI model
3. AI coding tools
4. AI apps/products
5. Open-source AI
6. Research
7. AI agents
8. AI business/industry
9. AI policy/safety
10. Important AI trend
```

The exact category distribution can change based on available news.

## Pipeline

```text
News sources
   ↓
Fetch
   ↓
Normalize
   ↓
Deduplicate
   ↓
Relevance scoring
   ↓
AI classification
   ↓
AI summarization
   ↓
Ranking
   ↓
Select exactly 10
   ↓
Publish daily briefing
```

Every item should store:

```text
id
title
summary
whyItMatters
sourceName
sourceUrl
publishedAt
category
imageUrl
tags
```

## News UI

```text
AI DAILY

Tuesday, September 1

10 important updates

01
OpenAI ...
Why it matters...
[Read]

02
Google ...
...
```

Actions:

- Save
- Share
- Read source
- Ask AI
- Mark read

Do not scrape websites in ways that violate their terms. Prefer licensed APIs, RSS feeds where permitted, and compliant search/news providers.

---

# 18. AI News Notifications

Optional daily notification:

```text
🤖 Your 10 AI updates are ready
```

Allow:

```text
Morning
Afternoon
Evening
Off
```

---

# 19. Sleep Module

Sleep dashboard:

```text
Sleep Goal
11:45 PM → 06:30 AM

7h 45m target
```

Features:

- Bedtime reminder
- Wind-down mode
- Wake-up schedule
- Sleep music
- Sleep timer
- Sleep history
- Sleep streak

Sleep music must use properly licensed or user-provided audio.

---

# 20. Sleep Music Player

Player:

```text
🌙 Sleep Mode

Rain
Forest
Ocean
White Noise
Ambient

15m 30m 45m 60m

[Play]
```

Use AVFoundation.

If background playback is required, configure the correct audio session/background mode and follow Apple's platform rules.

---

# 21. College Module

College dashboard:

```text
TODAY

09:00 College
16:30 Finish
17:30 Home

Classes
Assignments
Exams
Notes
```

Features:

- Weekly timetable
- Subject list
- Assignments
- Exam dates
- Attendance tracking
- College holidays
- Sunday holiday by default
- Custom holidays

---

# 22. Calendar Integration

Optional Apple Calendar integration:

- Read calendars only after permission
- Create events only after permission
- Sync selected calendar
- Do not duplicate events

Provide:

```text
Settings → Calendar Integration
```

---

# 23. Analytics

Daily:

```text
Tasks completed
Coding minutes
Focus sessions
Schedule adherence
Sleep consistency
```

Weekly:

```text
Coding hours
Completion %
Missed tasks
Best productivity day
Streaks
```

Monthly:

```text
Trend
Goals
Coding growth
Consistency
```

---

# 24. AI Weekly Review

Every Sunday:

```text
YOUR WEEK

Coding: 17h 40m
Tasks: 38 / 46
Completion: 83%

AI Insight

You performed best between 7 PM and 10 PM.

Next week suggestion:
Protect 7–9 PM for personal coding.
```

The user must be able to disable AI analysis.

---

# 25. Onboarding

Screens:

### Welcome

```text
Your day.
Under control.
```

### Name

### Wake-up time

### Sleep time

### College schedule

Default:

```text
Mon-Sat
09:00–16:30
```

### Travel time

Default:

```text
60 minutes
```

### Personal coding target

Default:

```text
3 hours/day
```

### Notification preferences

### AI preferences

### News briefing time

### Sleep music preference

Finish:

```text
Build My Schedule
```

Generate the initial schedule.

---

# 26. Design System

Create a reusable design system.

Components:

```text
AppButton
PrimaryButton
SecondaryButton
GlassCard
TaskCard
TimelineCard
ProgressRing
StreakBadge
Chip
BottomSheet
TimePicker
DurationPicker
EmptyState
LoadingView
ErrorView
NewsCard
AIMessageBubble
FocusTimer
```

Do not duplicate styling in individual screens.

---

# 27. Visual Design Direction

Premium modern iOS.

Use:

- Large rounded cards
- Strong typography hierarchy
- Generous spacing
- Subtle gradients
- Material/blur effects where appropriate
- Smooth transitions
- SF Symbols
- System colors where possible
- Dark Mode
- Light Mode

Avoid:

- Excessive gradients
- Tiny text
- Too many colors
- Cluttered dashboards
- Web-like UI inside the iOS app

---

# 28. Responsive Design

The application must work across:

- iPhone SE-class compact screens
- Standard iPhones
- Large iPhones
- Dynamic Island devices
- Portrait
- Landscape where applicable
- Dynamic Type sizes
- Dark/Light Mode

Use:

```swift
GeometryReader
ViewThatFits
Layout
safeAreaInset
ScrollView
LazyVStack
```

Do not use fixed absolute positioning for important UI.

Test with:

```text
Small
Medium
Large
Accessibility text sizes
Dark mode
Light mode
```

---

# 29. Accessibility

Required:

- VoiceOver labels
- Dynamic Type
- Sufficient contrast
- Reduce Motion support
- Reduce Transparency support
- Hit targets at least approximately 44x44 pt
- Don't rely only on color
- Accessible progress descriptions

---

# 30. Data Models

Suggested local models:

```text
UserProfile
Task
Subtask
ScheduleBlock
RecurringRule
Goal
Project
CodingSession
Streak
SleepSchedule
SleepSession
NewsArticle
SavedArticle
NotificationRule
CollegeEvent
Subject
Assignment
FocusSession
AIConversation
AIMessage
AppSettings
```

Use UUID identifiers.

Dates must be stored consistently and displayed using the user's local timezone.

---

# 31. Local Persistence

SwiftData.

Repositories:

```text
TaskRepository
ScheduleRepository
GoalRepository
ProjectRepository
NewsRepository
SleepRepository
CollegeRepository
SettingsRepository
```

Views should not directly perform database operations.

Use:

```text
View
 ↓
ViewModel / Feature State
 ↓
Use Case / Service
 ↓
Repository
 ↓
SwiftData
```

---

# 32. Networking

Create:

```text
APIClient
RequestBuilder
AuthInterceptor
NetworkMonitor
APIError
```

Endpoints:

```text
GET  /v1/news/today
GET  /v1/news/:id
POST /v1/ai/chat
POST /v1/ai/plan
POST /v1/ai/breakdown
POST /v1/ai/repair-schedule
POST /v1/analytics/weekly-review
```

Never place provider secrets in the iOS binary.

---

# 33. Backend API

Example:

```text
/api/v1
  /health
  /news
    /today
    /:id
  /ai
    /chat
    /plan
    /breakdown
    /repair
  /sync
  /analytics
```

Use authentication if cloud sync/accounts are implemented.

---

# 34. Database

PostgreSQL tables:

```text
users
tasks
goals
projects
schedule_blocks
coding_sessions
streaks
sleep_schedules
news_articles
saved_articles
ai_conversations
ai_messages
notification_preferences
college_events
```

Indexes:

```text
tasks(user_id, scheduled_start)
tasks(user_id, status)
news_articles(published_at)
news_articles(category)
news_articles(source_url)
```

---

# 35. Security

Required:

- HTTPS only
- API key only on backend
- Secure token storage using Keychain
- Input validation
- Rate limiting
- Request logging without sensitive content
- Database encryption/managed encryption where applicable
- Minimal permissions
- Clear privacy policy
- User data deletion/export support

Never log:

- AI provider API keys
- Authentication tokens
- Private user notes
- Full AI conversation content unless explicitly required and protected

---

# 36. Offline-First Behavior

Offline features:

- View schedule
- Create tasks
- Edit tasks
- Complete tasks
- View streaks
- Run timers
- Local notifications
- Sleep music if cached/local
- View previously downloaded AI news

Online-only:

- Fresh AI news
- AI chat
- AI planning
- Cloud sync

When connection returns:

```text
Local changes
   ↓
Sync queue
   ↓
Server
   ↓
Conflict resolution
```

---

# 37. Sync Strategy

If iCloud is used, avoid creating two independent sources of truth.

Recommended MVP:

```text
Local SwiftData = primary app state
Backend = AI/news service
Optional CloudKit = user data sync
```

Implement conflict handling using:

```text
updatedAt
revision/version
last-write rules
```

For important schedule conflicts, show the user a conflict UI rather than silently destroying data.

---

# 38. App States

Every major screen needs:

```text
Loading
Loaded
Empty
Error
Offline
Permission denied
```

Example:

```text
No tasks today

You are free 🎉

[Add a task]
[Ask AI to plan]
```

---

# 39. Error Handling

Human-friendly messages.

Bad:

```text
HTTP 500
```

Good:

```text
AI is temporarily unavailable.
Your schedule is safe.

[Try Again]
```

The schedule must remain usable when AI fails.

---

# 40. Testing Strategy

## Unit Tests

Test:

- Scheduling algorithm
- Recurring tasks
- Streak calculations
- Time calculations
- Missed-task logic
- Notification scheduling
- News selection
- JSON decoding
- AI response validation

## UI Tests

Test:

- Onboarding
- Add task
- Complete task
- Reschedule
- Focus mode
- AI chat
- News
- Settings
- Dark mode
- Accessibility sizes

## Integration Tests

Test:

```text
iOS → Backend → AI
Backend → News provider
iOS → Notification service
iOS → Calendar
```

---

# 41. Scheduling Algorithm Tests

Examples:

### Case 1

College:

```text
09:00–16:30
```

Travel:

```text
16:30–17:30
```

Available:

```text
17:30–23:45
```

Coding target:

```text
3h
```

Expected:

```text
Coding receives approximately 3h
Dinner/rest/sleep protected
```

### Case 2

Task deadline is tomorrow.

Expected:

High-priority task gets scheduled before optional tasks.

### Case 3

Task missed.

Expected:

System proposes the next available slot.

---

# 42. Notification Testing

Test:

- Timezone changes
- Device restart
- Notification permission denied
- Multiple reminders
- Recurring reminders
- Rescheduled tasks
- Deleted tasks
- Completed tasks

When a task is completed, its future one-time reminders must be cancelled.

---

# 43. Widgets

Build:

### Today Widget

```text
TODAY

💻 Coding
6:00 PM

3 tasks left
78%
```

### Next Task Widget

```text
NEXT

Dinner
8:30 PM
```

### Streak Widget

```text
🔥 7 DAYS
```

### AI News Widget

```text
🤖 10 AI updates
Today
```

Keep widgets lightweight and compliant with WidgetKit limitations.

---

# 44. Siri / Shortcuts

Where supported:

```text
"Add task"
"Start coding"
"Show today's schedule"
"Complete current task"
"Plan my day"
```

Use App Intents.

---

# 45. Settings

Sections:

```text
Profile
Schedule
College
Notifications
AI
AI News
Sleep
Music
Calendar
Appearance
Privacy
Data
About
```

Actions:

```text
Export data
Delete data
Reset schedule
Reset onboarding
```

---

# 46. MVP Scope

Build first:

1. Onboarding
2. Today dashboard
3. Task CRUD
4. Schedule/timeline
5. Recurring routines
6. College schedule
7. Sunday holiday
8. Notifications
9. Coding timer
10. Coding streak
11. Sleep schedule
12. Sleep music
13. AI Coach
14. Daily 10 AI news
15. Settings
16. Dark/Light mode
17. Widget
18. Offline local storage

---

# 47. Phase 2

Add:

- Apple Calendar sync
- Cloud sync
- Advanced analytics
- Weekly AI review
- Siri/Shortcuts
- Advanced schedule optimization
- Multiple projects
- Advanced focus statistics
- Better news personalization

---

# 48. Phase 3

Optional:

- iPad support
- Mac Catalyst
- Apple Watch companion
- Advanced AI agent
- Natural-language schedule editing
- Smart automation
- More news providers
- Family/shared schedules if ever required

---

# 49. Cursor Project Structure

Recommended:

```text
AI-LifeOS/
├── README.md
├── plan.md
├── .gitignore
├── docs/
│   ├── architecture.md
│   ├── api.md
│   ├── database.md
│   ├── notifications.md
│   └── ai.md
│
├── ios/
│   ├── App/
│   ├── Core/
│   │   ├── DesignSystem/
│   │   ├── Networking/
│   │   ├── Persistence/
│   │   ├── Notifications/
│   │   ├── Security/
│   │   └── Utilities/
│   │
│   ├── Features/
│   │   ├── Onboarding/
│   │   ├── Today/
│   │   ├── Schedule/
│   │   ├── Tasks/
│   │   ├── Goals/
│   │   ├── Projects/
│   │   ├── Focus/
│   │   ├── AI/
│   │   ├── News/
│   │   ├── Sleep/
│   │   ├── College/
│   │   ├── Insights/
│   │   └── Settings/
│   │
│   └── Widgets/
│
├── backend/
│   ├── src/
│   │   ├── routes/
│   │   ├── services/
│   │   ├── providers/
│   │   ├── jobs/
│   │   ├── db/
│   │   └── middleware/
│   ├── package.json
│   └── .env.example
│
└── tests/
```

---

# 50. Cursor Build Rules

Cursor must follow these rules:

### Rule 1
Do not create a fake UI with non-functional buttons.

### Rule 2
Every button must either work or be explicitly marked as a future feature.

### Rule 3
Do not hard-code secrets.

### Rule 4
Do not put business logic directly inside SwiftUI Views.

### Rule 5
Use protocols for services that need mocking.

### Rule 6
Write tests for scheduling, streaks and notifications.

### Rule 7
Use SwiftUI previews for major reusable components.

### Rule 8
Keep UI responsive.

### Rule 9
Respect iOS conventions.

### Rule 10
Do not silently change user schedules.

---

# 51. Cursor Implementation Order

Execute in this order.

## Step 1 — Project foundation

Create:

- SwiftUI app
- folders
- design system
- dependency boundaries
- SwiftData
- app environment
- basic navigation

Verify build.

## Step 2 — Onboarding

Implement:

- profile
- wake time
- sleep time
- college
- travel
- coding target
- notifications

Generate initial routine.

Verify build.

## Step 3 — Today

Implement:

- greeting
- progress
- current task
- timeline
- quick actions

Add previews and UI tests.

## Step 4 — Tasks

Implement:

- CRUD
- priorities
- durations
- deadlines
- recurring tasks
- subtasks

## Step 5 — Scheduling

Implement scheduling engine.

Add unit tests before adding AI scheduling.

## Step 6 — Notifications

Implement notification service.

Test rescheduling/cancellation.

## Step 7 — Coding

Implement projects, sessions, timer and streak.

## Step 8 — Sleep

Implement sleep settings and music player.

## Step 9 — AI backend

Create secure backend.

Implement provider abstraction.

## Step 10 — AI Coach

Implement:

- chat
- planning
- task breakdown
- schedule repair

Validate structured responses.

## Step 11 — News pipeline

Implement:

```text
fetch → normalize → dedupe → rank → summarize → exactly 10
```

Add source attribution.

## Step 12 — Widgets

Implement Today, Next Task, Streak and News widgets.

## Step 13 — Analytics

Implement weekly statistics.

## Step 14 — Polish

Add:

- animations
- haptics
- empty states
- error states
- accessibility
- performance improvements

## Step 15 — QA

Run all tests.

Test on real iPhone hardware.

---

# 52. Definition of Done

The MVP is not complete until:

- App builds successfully
- No critical compiler errors
- Onboarding works
- User can create/edit/delete tasks
- Schedule works offline
- Recurring tasks work
- College schedule works
- Sunday holiday works
- Notifications work
- Coding timer works
- Streaks calculate correctly
- Sleep schedule works
- Music player works with permitted audio
- AI Coach works through backend
- AI cannot expose API keys
- Daily briefing contains exactly 10 items when enough valid source material exists
- Every news item has attribution/source
- News failure does not break the schedule
- Dark Mode works
- Dynamic Type works
- VoiceOver labels exist
- Small and large iPhones are tested
- Widgets work
- Data export/delete works
- App has no placeholder buttons in production screens

---

# 53. Important AI-News Fallback

If fewer than 10 trustworthy AI stories are available:

Do NOT invent news.

Instead:

```text
Use additional configured reputable sources
→ broaden date window according to product rules
→ rank valid stories
→ if still insufficient, display fewer than 10 with a clear explanation
```

Never hallucinate a tenth article merely to satisfy the number 10.

---

# 54. Privacy UX

On first permission use, explain why access is needed.

Examples:

```text
Notifications
Used to remind you about tasks and routines.

Calendar
Used to show your existing calendar events.

Music
Used for sleep playback.
```

Do not request every permission during onboarding if it is not immediately needed.

---

# 55. Performance

Targets:

- Today screen should feel instant from local data.
- Schedule scrolling must remain smooth.
- Avoid unnecessary network requests.
- Cache daily news.
- Debounce AI chat requests.
- Paginate long histories.
- Use background work carefully.
- Avoid keeping large media in memory.

---

# 56. Release Preparation

Before App Store submission:

- App icon
- Launch screen
- Privacy manifest requirements as applicable
- Permission descriptions
- Privacy policy
- Terms
- App Store screenshots
- App description
- Support URL
- Account deletion flow if accounts exist
- Data export
- Crash monitoring
- Production environment
- Backend rate limits
- AI usage limits/cost controls

---

# 57. Final Product Experience

The ideal flow:

```text
06:30
☀️ Wake up

07:00
Morning routine

09:00
🎓 College

16:30
College ends

17:30
🏠 Home

18:00
💻 Personal Coding
🔥 Streak +1 if target completed

20:30
🍳 Dinner

22:00
💻 Deep Work

23:30
🌙 Wind Down

23:45
😴 Sleep

Next morning

🤖 10 AI updates
+
🎯 Today's schedule
+
🔥 Streak
```

The user should always know:

**WHAT → WHEN → WHY → HOW LONG → WHAT NEXT**

---

# 58. First Cursor Prompt

After creating the project, give Cursor this instruction:

```text
Read plan.md completely before writing code.

You are the lead iOS architect and senior SwiftUI engineer.

Build this application according to plan.md.

Requirements:
1. Use SwiftUI.
2. Use SwiftData for local persistence.
3. Use MVVM/service/repository separation.
4. Build a reusable DesignSystem first.
5. Do not put business logic inside Views.
6. Make the app offline-first.
7. Implement the scheduling engine with unit tests before AI scheduling.
8. Implement local notifications correctly.
9. Never hard-code API keys.
10. AI requests must use a backend abstraction.
11. Build the daily AI news feature using a provider abstraction and source attribution.
12. Do not invent news.
13. Make all screens responsive for different iPhone sizes.
14. Support Light Mode, Dark Mode, Dynamic Type and VoiceOver.
15. Use realistic empty/loading/error states.
16. No fake buttons.
17. Every major feature must have tests.
18. Use Swift Concurrency.
19. Keep code modular and maintainable.
20. Follow plan.md as the source of truth.

Start with Phase 1 only.

First:
- inspect the repository
- create/update the project structure
- create the DesignSystem
- create SwiftData models
- create dependency/service protocols
- create navigation shell
- create onboarding foundation

Then build and test.

Do not jump to later phases until the current phase builds successfully.
After each phase, report:
- files created
- files changed
- features completed
- tests added
- remaining issues
- exact next step
```

---

# 59. Final Instruction to Cursor

Do not attempt to build the entire application in one giant generated file.

Build it incrementally.

Prefer:

```text
small modules
+
testable services
+
reusable components
+
clear data models
+
real persistence
+
real notifications
+
secure backend
```

The goal is a maintainable production application, not a demo.

