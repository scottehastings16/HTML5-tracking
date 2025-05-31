# Manual Setup Instructions – HealthIndex iOS App  
_for MacInCloud_

Follow the steps below to recreate the full project locally on your MacInCloud server and push it to GitHub once the repo is reachable.

---

## 1 · Clone (or create) the repository on MacInCloud
1. Launch **Terminal** from the Dock.  
2. Navigate to a workspace folder (e.g. `Documents`):  
   ```bash
   cd ~/Documents
   ```
3. **If the remote repo is now accessible** run:
   ```bash
   git clone https://github.com/scottehastings16/HealthIndex-iOS.git
   cd HealthIndex-iOS
   ```
   _→ Skip to step 2._

   **If the remote is still unreachable** start locally and add the remote later:
   ```bash
   mkdir HealthIndex-iOS && cd HealthIndex-iOS
   git init
   ```

---

## 2 · Create the project folder structure
From the repo root, run:

```bash
mkdir -p HealthIndex/{App,Services,Models/CoreData,Views/{Dashboard,Competition,Profile}}
touch README.md .gitignore ios-setup-guide.md
touch HealthIndex/Info.plist
touch HealthIndex/App/HealthIndexApp.swift
touch HealthIndex/Models/CoreData/HealthModel.xcdatamodeld  # placeholder
touch HealthIndex/Views/{Dashboard/DashboardView.swift,Competition/CompetitionsView.swift,Profile/ProfileView.swift}
touch OnboardingView.swift
```

You should now have:

```
HealthIndex-iOS/
├── .gitignore
├── README.md
├── ios-setup-guide.md
├── HealthIndex
│   ├── Info.plist
│   ├── App/
│   │   └── HealthIndexApp.swift
│   ├── Services/              # (create later)
│   ├── Models/
│   │   └── CoreData/
│   │       └── HealthModel.xcdatamodeld
│   └── Views/
│       ├── Dashboard/
│       │   └── DashboardView.swift
│       ├── Competition/
│       │   └── CompetitionsView.swift
│       └── Profile/
│           └── ProfileView.swift
└── OnboardingView.swift
```

---

## 3 · Populate each file
Copy-paste the exact Swift / plist / markdown contents supplied in chat into the corresponding files above.

*Tip:* In **Visual Studio Code** (pre-installed) you can open the folder with `code .` for faster editing.

---

## 4 · Commit and push
```bash
git add .
git commit -m "Initial iOS app structure with HealthIndex MVP"
# If remote wasn’t added earlier:
git remote add origin https://github.com/scottehastings16/HealthIndex-iOS.git
git branch -M main
git push -u origin main
```

If you get a permission error, add an SSH key or use a **personal access token** when prompted.

---

## 5 · Open the project in Xcode
1. In Terminal:  
   ```bash
   open HealthIndex.xcworkspace   # if you later add SwiftPM/CocoaPods  
   # or, for now:
   open .
   ```
2. In the file dialog, double-click **HealthIndex.xcodeproj** (or create a new Xcode project inside `HealthIndex` if you haven’t yet).  
3. In the **Project Navigator** drag the folders (`App`, `Services`, `Models`, `Views`) into the target, **check “Copy items if needed”**.

### Enable Capabilities
* Select the _HealthIndex_ target → **Signing & Capabilities**  
* Press **+ Capability** → add **HealthKit**  
* In _Info.plist_ verify:
  * `NSHealthShareUsageDescription`
  * `NSHealthUpdateUsageDescription`

---

## 6 · Add the Core Data model
1. **File ▸ New ▸ File… ▸ Data Model** → save as `HealthModel` inside **Models/CoreData** (replace placeholder).  
2. Reproduce the entities described in the provided `HealthModel.xcdatamodeld` XML (or drag-drop the generated file if you saved it locally).

---

## 7 · Build & run in iOS Simulator
1. In the Xcode toolbar select **iPhone 15 Pro (Simulator)**.  
2. Press **▶ Run**.  
3. The app launches with **mock data** (steps, heart-rate, energy) so every dashboard widget populates immediately.  
4. To simulate background fetches: **Debug ▸ Simulate Background Fetch**.  
5. To inject Health data: open the **Health** app inside the simulator (**Features ▸ Health Data…**) and add samples.

---

## 8 · Troubleshooting
| Issue | Fix |
|-------|-----|
| _“HealthKit entitlements missing”_ | Re-add **HealthKit** capability and clean build (`⇧⌘K`). |
| _App crashes on launch_ | Ensure `Info.plist` keys (`NSHealthShareUsageDescription`, etc.) are present. |
| _Git push fails (auth)_ | Use **SSH key** or **Personal Access Token**; test with `git push origin main`. |

---

You now have the complete HealthIndex iOS app running on MacInCloud and version-controlled in GitHub. Happy coding!
