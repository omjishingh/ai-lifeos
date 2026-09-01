# AI LifeOS

A polished iOS personal operating system for college, coding, tasks, sleep, and daily AI news.

## Install on iPhone (E-Sign — Bina Apple ID)

**[BUILD_IPA_WINDOWS.md](BUILD_IPA_WINDOWS.md)** — GitHub se unsigned IPA → E-Sign se install

```
GitHub push → Actions → Download AILifeOS-unsigned.ipa → E-Sign install
```

Koi Apple ID / GitHub Secret **nahi** chahiye.

## Install on iPhone (Mac hai to)
1. Open `ios/AILifeOS.xcodeproj` in **Xcode on Mac**
2. Connect your iPhone
3. Set Signing Team → Press **⌘R**
4. Trust developer certificate on iPhone
5. Complete onboarding in the app

## Features (MVP)

- Onboarding with automatic schedule generation
- Today dashboard with timeline & streaks
- Tasks (create, edit, complete, delete, notifications)
- Schedule with recurring blocks & Sunday holiday
- Focus timer & coding sessions
- Sleep mode & music player
- AI Coach chat
- Daily 10 AI news briefing
- College dashboard
- Export / delete data
- Dark mode, Dynamic Type, VoiceOver labels

## Backend (optional)

```bash
cd backend
cp .env.example .env
npm install
npm start
```

API: `http://localhost:3000/api/v1`

## Project Structure

```
├── ios/          SwiftUI app (open in Xcode)
├── backend/      Node.js API for AI + News
├── INSTALL.md    iPhone install guide
├── PLAN.md       Full specification
└── PROGRESS.md   Build status
```

## Requirements

- iOS 17+, Xcode 15+, Swift 5.9+
- Mac required to build and install on iPhone
