# iOS Health-App Setup Guide (MacInCloud)

*For: Scott Hastings*  
*Last updated: 31 May 2025*

---

## 1 Install & Launch Xcode on MacInCloud
1. Log in to your **MacInCloud Managed Server** (or Dedicated Server) via Remote Desktop.
2. Open **“Managed Software Center”** → install the latest **Xcode** (or run `xcode-select --install` in Terminal if command-line tools are missing).  
   • Current stable: Xcode 15.x  
3. After installation, start **Xcode** from the Dock.  
4. Accept the license when prompted and let Xcode finish installing extra components (~2 GB).

---

## 2 Create a New SwiftUI Project
1. Xcode → **File ▸ New ▸ Project…**  
2. Template: **App**  
3. Product Name: `HealthIndex`  
4. Interface: **SwiftUI**   Language: **Swift**  
5. Team: _Select your developer team_ (see section 6)  
6. Bundle Identifier: `com.<yourcompany>.HealthIndex`  
7. Leave all other options default and **Create**.

---

## 3 Enable HealthKit Capability
1. Select project root in the Navigator → **Signing & Capabilities** tab.  
2. Press **+ Capability** → add **HealthKit**.  
3. Expand HealthKit section:  
   • Check **HealthKit** and **Background Delivery**.  
4. In **Info.plist** add the usage strings:  
   • `NSHealthShareUsageDescription` → “HealthIndex reads your activity and biomarker data.”  
   • `NSHealthUpdateUsageDescription` → “HealthIndex logs your diet and achievements.”

---

## 4 Recommended Project Structure
```
HealthIndex/
 ├── App/                 ← @main struct, AppDelegate
 ├── Services/
 │     ├── HealthKitService.swift      ← HKObserverQuery & AnchoredObjectQuery
 │     ├── MockDataService.swift       ← Simulator/mock helpers
 │     └── CoreDataStack.swift         ← NSPersistentContainer wrapper
 ├── Models/
 │     ├── CoreData/    ← .xcdatamodeld (see section 8)
 │     └── DTO/         ← small structs for UI binding
 ├── ViewModels/
 ├── Views/
 │     ├── Dashboard/
 │     ├── Competition/
 │     ├── Profile/
 │     └── Components/
 └── Resources/          ← Assets, JSON seeds
```

Keep **Services** “dumb” (no SwiftUI) and **ViewModels** observable; this will make unit testing easier.

---

## 5 Testing on MacInCloud
| Task | How |
|------|-----|
| Run the app | Xcode toolbar: Device › **iPhone 15 Pro (simulator)** → ⏵ |
| HealthKit data | Simulator shows empty Health app. Use **Features ▸ Health Data…** to inject samples (or call `MockDataService` to seed Core Data). |
| Background delivery | Simulate with **Debug ▸ Simulate Background Fetch**. |
| Multiple devices | Add additional simulators via **Window ▸ Device & Simulators**. |

🔑 **Tip:** For realistic charts, seed ~30 days of steps/HR in the simulator using `HKQuantitySample`.

---

## 6 Apple Developer Account
1. **Free account**: Good for simulator only.  
2. **Paid Developer Program ($99/yr)**: Needed to run on a physical iPhone, enable TestFlight, and ship to App Store.  
3. Sign in to Xcode (Settings ▸ Accounts ▸ **+ Apple ID**).  
4. Create an **App ID** & **Bundle ID** in **Certificates & IDs** portal if you intend to sign on devices later.

---

## 7 Initial Project Configuration
- **Deployment Target:** iOS 17.0 (Settings ▸ General) – gives SwiftUI 3 goodies.
- **Swift Concurrency:** Add `@MainActor` to view-models; enable strict concurrency checks (`OTHER_SWIFT_FLAGS: -Xfrontend -enable-actor-data-race-checks`).
- **Git:** `git init`, `.gitignore` from Xcode template, push to GitHub when comfortable.

---

## 8 Core Data Setup (Health Database)
1. **File ▸ New ▸ File… ▸ Data Model** → `HealthModel.xcdatamodeld`.
2. Add **Entities** (inheritance allowed):
   - `BiomarkerSample` (abstract)  
     • `value: Double` • `measuredAt: Date` • `device: String?`
   - `PhysicalSample`, `BloodSample`, `WellnessSample`, `DietEntry` → **Parent:** `BiomarkerSample`
   - Lookup tables: `BiomarkerDefinition`, `DataSource`, `ScoreWeight`, `HealthScore`
3. In **CoreDataStack.swift** create:
```swift
lazy var container: NSPersistentContainer = {
    let c = NSPersistentContainer(name: "HealthModel")
    c.loadPersistentStores { _, err in
        if let err = err { fatalError("CD load \(err)") }
    }
    c.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return c
}()
```
4. Seed `BiomarkerDefinition` & friends from bundled JSON on first launch.

---

## 9 Mock Data Strategy
HealthKit ≠ available on real watch in the cloud. Use **Conditional Compilation**:
```swift
#if targetEnvironment(simulator)
HealthKitService.shared.useMockData = true
#endif
```
- **MockDataService** generates daily steps, HR, calories:  
  `HKQuantitySample(type: .stepCount, quantity: .init(unit: .count(), doubleValue: 8500), …)`
- Inject lab/checkup JSON via the “Import Demo Data” toggle in Settings screen.
- Store mocks in Core Data; UI renders exactly as it will with live data.

---

## 10 Next Steps
1. **Implement HealthKitService**: request auth, anchored queries for steps/HR/energy.
2. **Build DashboardView**: circular health score, recent activity list.
3. **Competition Module**: static JSON until backend is ready.
4. **ProfileView**: basic info + token balance (no redemption yet).
5. **Unit Tests**: start with Core Data CRUD & HealthKit mocks.
6. **CI**: Enable Xcode Cloud or GitHub Actions for `xcodebuild test -scheme HealthIndex`.
7. **Prepare backend**: REST/GraphQL endpoints for competitions & token ledger.

You now have a fully reproducible environment on MacInCloud to kick-start development. Happy building!  
