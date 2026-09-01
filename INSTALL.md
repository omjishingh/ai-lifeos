# AI LifeOS — iPhone Install Guide

## Requirements

| Item | Details |
|------|---------|
| **Mac** | macOS with Xcode 15+ (required to build iOS apps) |
| **iPhone** | iOS 17.0 or later |
| **Apple ID** | Free Apple ID works for personal device install |
| **Cable** | USB/Lightning or USB-C to connect iPhone to Mac |

> **Note:** iOS apps cannot be built on Windows alone. You need a Mac with Xcode, or a cloud Mac service (MacStadium, GitHub Actions with macOS runner, etc.).

---

## Quick Install (5 steps)

### 1. Open project in Xcode
```bash
open ios/AILifeOS.xcodeproj
```

### 2. Select your iPhone
- Connect iPhone via cable
- Trust the computer on your iPhone
- In Xcode toolbar, select your **iPhone** as the run destination (not simulator)

### 3. Set signing team
- Click project **AILifeOS** in left sidebar
- Select target **AILifeOS** → **Signing & Capabilities**
- Check **Automatically manage signing**
- Choose your **Team** (your Apple ID)
- Bundle ID: `com.ailifeos.app` (change if needed)

### 4. Build & Run
- Press **⌘R** (or click Play button)
- First time: On iPhone go to **Settings → General → VPN & Device Management** → Trust your developer certificate

### 5. Complete onboarding
- Open the app → follow onboarding → tap **Build My Schedule**

---

## Optional: Backend (AI + News)

The app works offline for schedule/tasks. For live AI and news:

```bash
cd backend
cp .env.example .env
npm install
npm start
```

Server runs at `http://localhost:3000/api/v1`

### Connect iPhone to backend
1. Find your Mac's local IP: `ifconfig | grep inet`
2. In Xcode, edit `APIClient.swift` base URL:
   ```swift
   baseURL: URL = URL(string: "http://YOUR_MAC_IP:3000/api/v1")!
   ```
3. For simulator use `http://localhost:3000/api/v1`
4. Rebuild and run

> Add `GEMINI_API_KEY` to `backend/.env` for real AI (never in iOS app).

---

## Create IPA for distribution

### Ad Hoc / Development IPA
1. Xcode → **Product → Archive**
2. **Distribute App** → Development or Ad Hoc
3. Follow wizard to export `.ipa`
4. Install via Apple Configurator, Xcode Devices window, or TestFlight

### TestFlight (recommended for sharing)
1. Enroll in [Apple Developer Program](https://developer.apple.com) ($99/year)
2. Archive → Distribute → App Store Connect
3. Upload to TestFlight
4. Invite testers via email

---

## App Features (MVP)

- ✅ Onboarding with schedule generation
- ✅ Today dashboard with timeline
- ✅ Tasks (create, edit, complete, delete)
- ✅ Schedule (recurring blocks, Sunday holiday)
- ✅ Focus timer + coding sessions
- ✅ Sleep mode + music player
- ✅ AI Coach chat (backend or offline mock)
- ✅ Daily 10 AI news briefing
- ✅ Local notifications
- ✅ Streak tracking
- ✅ College dashboard
- ✅ Export / delete data
- ✅ Dark mode + Dynamic Type

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Untrusted Developer" | Settings → General → VPN & Device Management → Trust |
| Build fails signing | Select Team in Signing & Capabilities |
| Notifications not showing | Allow notifications when prompted in onboarding |
| Schedule empty | Complete onboarding → Build My Schedule |
| AI shows mock data | Start backend server, update API URL |

---

## Project Structure

```
SHADULE IPA/
├── ios/AILifeOS.xcodeproj   ← Open this in Xcode
├── backend/                  ← Optional API server
├── INSTALL.md                ← This file
├── PLAN.md                   ← Full specification
└── PROGRESS.md               ← Build status
```
