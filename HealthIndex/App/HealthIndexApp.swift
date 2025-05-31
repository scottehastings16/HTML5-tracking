//
//  HealthIndexApp.swift
//  HealthIndex
//
//  Created for Scott Hastings on 5/31/2025.
//

import SwiftUI
import CoreData
import HealthKit

@main
struct HealthIndexApp: App {
    // MARK: - State
    @StateObject private var coreDataStack = CoreDataStack.shared
    @StateObject private var healthKitService = HealthKitService.shared
    @StateObject private var userProfileManager = UserProfileManager()
    @StateObject private var competitionManager = CompetitionManager()
    @StateObject private var tokenManager = TokenManager()
    
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - Initialization
    init() {
        // Register app lifecycle observers
        setupAppearance()
        
        // Log app launch
        print("HealthIndex App launching - \(Date())")
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            if userProfileManager.isUserLoggedIn {
                MainTabView()
                    .environment(\.managedObjectContext, coreDataStack.viewContext)
                    .environmentObject(healthKitService)
                    .environmentObject(userProfileManager)
                    .environmentObject(competitionManager)
                    .environmentObject(tokenManager)
                    .onAppear {
                        requestHealthKitAuthorization()
                    }
            } else {
                OnboardingView()
                    .environmentObject(userProfileManager)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    // MARK: - Methods
    private func setupAppearance() {
        // Configure global UI appearance
        UINavigationBar.appearance().tintColor = UIColor(Color("PrimaryColor"))
        UITabBar.appearance().tintColor = UIColor(Color("PrimaryColor"))
    }
    
    private func requestHealthKitAuthorization() {
        Task {
            do {
                try await healthKitService.requestAuthorization()
                await healthKitService.setupBackgroundDelivery()
                await healthKitService.fetchLatestData()
            } catch {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            print("App became active")
            Task {
                await healthKitService.fetchLatestData()
                await competitionManager.refreshActiveCompetitions()
            }
            
        case .inactive:
            print("App became inactive")
            
        case .background:
            print("App entered background")
            coreDataStack.saveContext() // Save any pending changes
            
        @unknown default:
            print("Unknown scene phase")
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            CompetitionsView()
                .tabItem {
                    Label("Compete", systemImage: "trophy.fill")
                }
                .tag(1)
            
            AddDataView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(Color("PrimaryColor"))
    }
}

// MARK: - Core Data Stack
class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "HealthModel")
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error.localizedDescription)")
            }
            
            // Configure the Core Data stack
            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            // Seed initial data if needed
            self.seedInitialDataIfNeeded()
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func seedInitialDataIfNeeded() {
        // Check if we need to seed data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BiomarkerCategory")
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try viewContext.count(for: fetchRequest)
            if count == 0 {
                // No data exists, seed initial data
                seedBiomarkerCategories()
                seedDataSources()
                seedBiomarkerDefinitions()
                seedScoreWeights()
                
                // Save the context
                try viewContext.save()
                print("Initial data seeding complete")
            }
        } catch {
            print("Error checking for existing data: \(error.localizedDescription)")
        }
    }
    
    private func seedBiomarkerCategories() {
        let categories = [
            ("Physical", "Biomarkers from yearly checkups"),
            ("Blood", "Biomarkers from lab tests"),
            ("Wellness", "Biomarkers from Apple Watch and daily habits")
        ]
        
        for (name, description) in categories {
            let category = NSEntityDescription.insertNewObject(forEntityName: "BiomarkerCategory", into: viewContext) as! NSManagedObject
            category.setValue(UUID(), forKey: "id")
            category.setValue(name, forKey: "name")
            category.setValue(description, forKey: "description")
            category.setValue(Date(), forKey: "createdAt")
        }
    }
    
    private func seedDataSources() {
        let sources = [
            ("appleWatch", "Apple", "Apple Watch data"),
            ("lab", "Quest Diagnostics", "Lab test results"),
            ("checkup", "Annual Physical", "Yearly medical checkup"),
            ("userInput", "User", "Manually entered data")
        ]
        
        for (name, organization, description) in sources {
            let source = NSEntityDescription.insertNewObject(forEntityName: "DataSource", into: viewContext) as! NSManagedObject
            source.setValue(UUID(), forKey: "id")
            source.setValue(name, forKey: "name")
            source.setValue(organization, forKey: "organization")
            source.setValue(description, forKey: "description")
            source.setValue(Date(), forKey: "createdAt")
        }
    }
    
    private func seedBiomarkerDefinitions() {
        // This would be populated from a JSON file in a real app
        // For now, just add a few examples
        let physicalCategory = fetchCategory(name: "Physical")
        let bloodCategory = fetchCategory(name: "Blood")
        let wellnessCategory = fetchCategory(name: "Wellness")
        
        // Physical biomarkers
        createBiomarker(categoryId: physicalCategory, code: "BMI", displayName: "Body Mass Index", 
                        unit: "kg/m²", isDependent: true, min: 18.5, max: 24.9)
        createBiomarker(categoryId: physicalCategory, code: "WHR", displayName: "Waist-to-Hip Ratio", 
                        unit: "ratio", isDependent: true, min: 0.8, max: 0.9)
        createBiomarker(categoryId: physicalCategory, code: "RHR", displayName: "Resting Heart Rate", 
                        unit: "bpm", isDependent: true, min: 60, max: 100)
        
        // Blood biomarkers
        createBiomarker(categoryId: bloodCategory, code: "GLUC", displayName: "Fasting Glucose", 
                        unit: "mg/dL", isDependent: true, min: 70, max: 100)
        createBiomarker(categoryId: bloodCategory, code: "HDL", displayName: "HDL Cholesterol", 
                        unit: "mg/dL", isDependent: true, min: 40, max: 60)
        
        // Wellness biomarkers
        createBiomarker(categoryId: wellnessCategory, code: "STEPS", displayName: "Daily Steps", 
                        unit: "count", isDependent: false, min: 7000, max: 10000)
        createBiomarker(categoryId: wellnessCategory, code: "ACTIVE", displayName: "Active Energy", 
                        unit: "kcal", isDependent: false, min: 300, max: 600)
        createBiomarker(categoryId: wellnessCategory, code: "DIET", displayName: "Diet Quality", 
                        unit: "score", isDependent: false, min: 0, max: 100)
    }
    
    private func seedScoreWeights() {
        // Assign weights to each biomarker
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "BiomarkerDefinition")
        
        do {
            let biomarkers = try viewContext.fetch(fetchRequest)
            
            // Assign weights based on biomarker code
            for biomarker in biomarkers {
                let code = biomarker.value(forKey: "code") as! String
                let weight: Double
                
                switch code {
                case "BMI", "GLUC", "HDL": weight = 0.15
                case "WHR", "RHR": weight = 0.1
                case "STEPS", "ACTIVE": weight = 0.2
                case "DIET": weight = 0.1
                default: weight = 0.05
                }
                
                let scoreWeight = NSEntityDescription.insertNewObject(forEntityName: "ScoreWeight", into: viewContext) as! NSManagedObject
                scoreWeight.setValue(UUID(), forKey: "id")
                scoreWeight.setValue(biomarker, forKey: "biomarker")
                scoreWeight.setValue(weight, forKey: "weight")
                scoreWeight.setValue(Date(), forKey: "createdAt")
            }
        } catch {
            print("Error fetching biomarkers for weight assignment: \(error.localizedDescription)")
        }
    }
    
    private func fetchCategory(name: String) -> NSManagedObject {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "BiomarkerCategory")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let category = results.first {
                return category
            }
        } catch {
            print("Error fetching category: \(error.localizedDescription)")
        }
        
        fatalError("Could not find category: \(name)")
    }
    
    private func createBiomarker(categoryId: NSManagedObject, code: String, displayName: String, 
                                unit: String, isDependent: Bool, min: Double, max: Double) {
        let biomarker = NSEntityDescription.insertNewObject(forEntityName: "BiomarkerDefinition", into: viewContext) as! NSManagedObject
        biomarker.setValue(UUID(), forKey: "id")
        biomarker.setValue(categoryId, forKey: "category")
        biomarker.setValue(code, forKey: "code")
        biomarker.setValue(displayName, forKey: "displayName")
        biomarker.setValue(unit, forKey: "unit")
        biomarker.setValue(isDependent, forKey: "isDependent")
        biomarker.setValue(min, forKey: "normalRangeMin")
        biomarker.setValue(max, forKey: "normalRangeMax")
        biomarker.setValue(Date(), forKey: "createdAt")
    }
}

// MARK: - HealthKit Service
class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    private let healthKitTypes = HealthKitTypes()
    
    @Published var isAuthorized = false
    @Published var latestSteps: Double = 0
    @Published var latestHeartRate: Double = 0
    @Published var latestActiveEnergy: Double = 0
    
    #if targetEnvironment(simulator)
    var useMockData = true
    #else
    var useMockData = false
    #endif
    
    private init() {
        // Initialize with default values
    }
    
    func requestAuthorization() async throws {
        // Request authorization for the types we want to read
        try await healthStore.requestAuthorization(toShare: [], read: healthKitTypes.typesToRead)
        
        // Update authorization status
        DispatchQueue.main.async {
            self.isAuthorized = true
        }
    }
    
    func setupBackgroundDelivery() async {
        guard isAuthorized else { return }
        
        // Set up background delivery for each type
        for type in healthKitTypes.typesToObserve {
            do {
                try await healthStore.enableBackgroundDelivery(for: type, frequency: .immediate)
                print("Background delivery enabled for \(type)")
            } catch {
                print("Failed to enable background delivery for \(type): \(error.localizedDescription)")
            }
        }
    }
    
    func fetchLatestData() async {
        if useMockData {
            await fetchMockData()
            return
        }
        
        guard isAuthorized else { return }
        
        // Fetch latest data for each type
        await fetchSteps()
        await fetchHeartRate()
        await fetchActiveEnergy()
    }
    
    private func fetchMockData() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Update with mock data
        DispatchQueue.main.async {
            self.latestSteps = Double.random(in: 6000...12000)
            self.latestHeartRate = Double.random(in: 60...85)
            self.latestActiveEnergy = Double.random(in: 250...450)
        }
    }
    
    private func fetchSteps() async {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        do {
            let steps = try await fetchLatestQuantitySample(for: stepsType, unit: HKUnit.count())
            DispatchQueue.main.async {
                self.latestSteps = steps
            }
        } catch {
            print("Error fetching steps: \(error.localizedDescription)")
        }
    }
    
    private func fetchHeartRate() async {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        do {
            let heartRate = try await fetchLatestQuantitySample(for: heartRateType, unit: HKUnit.count().unitDivided(by: .minute()))
            DispatchQueue.main.async {
                self.latestHeartRate = heartRate
            }
        } catch {
            print("Error fetching heart rate: \(error.localizedDescription)")
        }
    }
    
    private func fetchActiveEnergy() async {
        let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        do {
            let energy = try await fetchLatestQuantitySample(for: activeEnergyType, unit: HKUnit.kilocalorie())
            DispatchQueue.main.async {
                self.latestActiveEnergy = energy
            }
        } catch {
            print("Error fetching active energy: \(error.localizedDescription)")
        }
    }
    
    private func fetchLatestQuantitySample(for quantityType: HKQuantityType, unit: HKUnit) async throws -> Double {
        // Get today's start and end dates
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Create the query descriptor
        let sumDescriptor = HKStatisticsQueryDescriptor(
            predicate: predicate,
            quantityType: quantityType,
            options: .cumulativeSum
        )
        
        // Execute the query
        let statistics = try await sumDescriptor.result(for: healthStore)
        
        // Extract the sum
        if let sum = statistics.sumQuantity() {
            return sum.doubleValue(for: unit)
        } else {
            return 0
        }
    }
}

// MARK: - HealthKit Types
struct HealthKitTypes {
    // Types we want to read
    let typesToRead: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.workoutType()
    ]
    
    // Types we want to observe for background delivery
    let typesToObserve: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
}

// MARK: - User Profile Manager
class UserProfileManager: ObservableObject {
    @Published var isUserLoggedIn = false
    @Published var userName: String = ""
    @Published var userAvatar: String = ""
    @Published var healthScore: Int = 0
    @Published var tokenBalance: Int = 0
    
    init() {
        // Check if user is logged in
        // For development, set to true to skip login
        #if DEBUG
        isUserLoggedIn = true
        userName = "Scott Hastings"
        userAvatar = "SH"
        healthScore = 78
        tokenBalance = 350
        #else
        checkLoginStatus()
        #endif
    }
    
    private func checkLoginStatus() {
        // In a real app, check for stored credentials or tokens
        // For now, just set to false to show login screen
        isUserLoggedIn = false
    }
    
    func signInWithApple() {
        // In a real app, implement Sign in with Apple
        // For now, just simulate successful login
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isUserLoggedIn = true
            self.userName = "Scott Hastings"
            self.userAvatar = "SH"
            self.healthScore = 78
            self.tokenBalance = 350
        }
    }
    
    func signOut() {
        // In a real app, clear credentials and tokens
        // For now, just reset state
        isUserLoggedIn = false
        userName = ""
        userAvatar = ""
        healthScore = 0
        tokenBalance = 0
    }
}

// MARK: - Competition Manager
class CompetitionManager: ObservableObject {
    @Published var activeCompetitions: [Competition] = []
    @Published var weeklyLeaderboard: [LeaderboardEntry] = []
    
    init() {
        // Load mock data for development
        loadMockData()
    }
    
    func refreshActiveCompetitions() async {
        // In a real app, fetch from backend
        // For now, just use mock data
        DispatchQueue.main.async {
            self.loadMockData()
        }
    }
    
    private func loadMockData() {
        // Mock competitions
        activeCompetitions = [
            Competition(
                id: UUID(),
                title: "Spring Marathon Challenge",
                description: "Complete a virtual marathon in 30 days",
                type: .distance,
                startDate: Date().addingTimeInterval(-18 * 24 * 3600),
                endDate: Date().addingTimeInterval(12 * 24 * 3600),
                participants: 127,
                progress: 0.65,
                currentValue: 27.3,
                targetValue: 42.2,
                unit: "km",
                tokenReward: 500
            ),
            Competition(
                id: UUID(),
                title: "Weekly Step Challenge",
                description: "Who can walk the most steps this week?",
                type: .steps,
                startDate: Date().addingTimeInterval(-4 * 24 * 3600),
                endDate: Date().addingTimeInterval(3 * 24 * 3600),
                participants: 56,
                progress: 0.48,
                currentValue: 48235,
                targetValue: 100000,
                unit: "steps",
                tokenReward: 200
            )
        ]
        
        // Mock leaderboard
        weeklyLeaderboard = [
            LeaderboardEntry(rank: 1, name: "John Doe", initials: "JD", score: 89, tokens: 120),
            LeaderboardEntry(rank: 2, name: "Alice Smith", initials: "AS", score: 85, tokens: 80),
            LeaderboardEntry(rank: 3, name: "Robert Johnson", initials: "RJ", score: 82, tokens: 50),
            LeaderboardEntry(rank: 4, name: "Scott Hastings", initials: "SH", score: 78, tokens: 30),
            LeaderboardEntry(rank: 5, name: "Emily Martinez", initials: "EM", score: 76, tokens: 20)
        ]
    }
}

// MARK: - Token Manager
class TokenManager: ObservableObject {
    @Published var balance: Int = 0
    @Published var transactions: [TokenTransaction] = []
    
    init() {
        // Load mock data for development
        loadMockData()
    }
    
    private func loadMockData() {
        balance = 350
        
        transactions = [
            TokenTransaction(
                id: UUID(),
                title: "Weekly Challenge Winner",
                amount: 120,
                type: .earned,
                date: Date().addingTimeInterval(-3 * 24 * 3600),
                icon: "trophy"
            ),
            TokenTransaction(
                id: UUID(),
                title: "Completed 10K Steps Challenge",
                amount: 50,
                type: .earned,
                date: Date().addingTimeInterval(-8 * 24 * 3600),
                icon: "medal"
            ),
            TokenTransaction(
                id: UUID(),
                title: "Referral Bonus: Emily Martinez",
                amount: 100,
                type: .earned,
                date: Date().addingTimeInterval(-11 * 24 * 3600),
                icon: "user.plus"
            ),
            TokenTransaction(
                id: UUID(),
                title: "7-Day Activity Streak",
                amount: 25,
                type: .earned,
                date: Date().addingTimeInterval(-13 * 24 * 3600),
                icon: "heartbeat"
            )
        ]
    }
}

// MARK: - Model Structs
struct Competition: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let type: CompetitionType
    let startDate: Date
    let endDate: Date
    let participants: Int
    let progress: Double
    let currentValue: Double
    let targetValue: Double
    let unit: String
    let tokenReward: Int
    
    enum CompetitionType {
        case steps, distance, calories, activity
    }
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let initials: String
    let score: Int
    let tokens: Int
}

struct TokenTransaction: Identifiable {
    let id: UUID
    let title: String
    let amount: Int
    let type: TransactionType
    let date: Date
    let icon: String
    
    enum TransactionType {
        case earned, spent
    }
}
