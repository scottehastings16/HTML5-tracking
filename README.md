# HealthIndex – iOS App

A modern iOS application that fuses Apple Watch metrics, manual inputs, and lab results into one **Health Index**.  
The MVP focuses on data ingestion, scoring, social competitions, and an internal token balance—redemption/market-place features are deferred to a later phase.

---

## 1 · Project Overview
HealthIndex helps users understand and improve their wellbeing by:
* Aggregating **Physical, Blood, and Wellness** biomarkers
* Generating a weighted **Health Score (0–100)**
* Offering weekly and event-based **activity competitions**
* Displaying personalised insights in a clean, Apple-style UI

---

## 2 · MVP Features (Implemented)
| Category | Details |
|----------|---------|
| Health data | • Apple Watch steps, heart-rate, active-energy<br>• Manual diet entries |
| Scoring | • Real-time Health Score with category breakdown |
| Social | • Virtual marathon & weekly step challenges<br>• Live leaderboards |
| Tokens | • Earn in-app tokens for competition results (balance only; no redemption yet) |
| Auth | • **Sign in with Apple** |
| Persistence | • **Core Data** local store (SQLite) |
| Mock mode | • Automatic mock data when running in Simulator |

---

## 3 · Tech Stack
* Swift 5.9 + **SwiftUI**
* **HealthKit** – HKObserver / HKAnchoredObject queries
* **Core Data** – SQLite store, lightweight migrations
* Combine + Swift Concurrency
* Xcode 15
* Target: iOS 17+

---

## 4 · Setup on MacInCloud

1. **Log in** to your MacInCloud server (RDP / web).  
2. Open **Managed Software Center** → install latest **Xcode**.  
3. Clone the repo:

```bash
git clone https://github.com/<your-org>/HealthIndex.git
cd HealthIndex
open HealthIndex.xcodeproj
```

4. On first build Xcode may ask for **developer tools** permission—approve it.  
5. Select **iPhone 15 Pro (Simulator)** in the toolbar and press ▶ Run.  
6. The Simulator starts with **mock data enabled** so all UI elements populate instantly.

> Real device testing requires an Apple Developer account; sign in via **Xcode ▸ Settings ▸ Accounts** when ready.

---

## 5 · Project Structure

```
HealthIndex/
 ├── App/                  # @main, AppDelegate
 ├── Services/             # HealthKitService, CoreDataStack, MockDataService
 ├── Models/
 │     ├── CoreData/       # HealthModel.xcdatamodeld
 │     └── DTO/            # Lightweight structs
 ├── ViewModels/
 ├── Views/
 │     ├── Dashboard/
 │     ├── Competition/
 │     ├── Profile/
 │     └── Components/
 ├── Resources/            # Assets, seeded JSON
 └── README.md
```

---

## 6 · Database Schema Overview (Core Data)

Main entities (see `HealthModel.xcdatamodeld`):

* `UserProfile` – Apple ID, demographics, token balance  
* `BiomarkerCategory` → **Physical · Blood · Wellness**  
* `BiomarkerDefinition` – master list (BMI, HDL, Steps …)  
* `BiomarkerSample` (abstract) → `PhysicalSample`, `BloodSample`, `WellnessSample`, `DietEntry`  
* `HealthScore` – composite score snapshots  
* `DataSource` – appleWatch | lab | checkup | userInput  
* `ScoreWeight` – weight per biomarker  
* `SyncState` – HealthKit anchor tracking  
* `TokenTransaction` – earned/spent history (earn-only for MVP)

All writes occur on a background context; the main context is read-only for UI binding.

---

## 7 · Mock Data

Running on Simulator sets `HealthKitService.useMockData = true`.

* Steps: **6 000–12 000** random
* HR: **60–85 bpm**
* Active energy: **250–450 kcal**
* Competitions & leaderboard pre-populated in `CompetitionManager`

This ensures every screen is functional without real HealthKit input.

---

## 8 · Future Roadmap

| Phase | Planned Work |
|-------|--------------|
| 1. Data Expansion | Sleep patterns, stress metrics, medical conditions |
| 2. Cloud Sync     | Core Data + CloudKit for multi-device continuity |
| 3. Token Utility  | Marketplace & sponsor integrations (gift cards, merch) |
| 4. Anti-Cheat     | ML-based fraud detection, device graph analysis |
| 5. Partnerships   | Lab import via FHIR, corporate wellness challenges |

---

## 9 · Requirements & Dependencies
* macOS 13+ (MacInCloud or local)
* Xcode 15+
* Swift 5.9 toolchain
* iOS 17 Simulator (bundled with Xcode)
* Apple Developer account (optional – required for device builds and TestFlight)

---

### Contributing
Pull requests are welcome! Please open an issue first to discuss changes or features.

### License
© 2025 HealthIndex. All rights reserved.
