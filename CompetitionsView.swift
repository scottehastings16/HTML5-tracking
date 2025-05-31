//
//  CompetitionsView.swift
//  HealthIndex
//
//  Created for Scott Hastings on 5/31/2025.
//

import SwiftUI

struct CompetitionsView: View {
    // MARK: - Environment
    @EnvironmentObject private var competitionManager: CompetitionManager
    @EnvironmentObject private var userProfileManager: UserProfileManager
    
    // MARK: - State
    @State private var isRefreshing = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Active Competitions
                    ForEach(competitionManager.activeCompetitions) { competition in
                        NavigationLink(destination: CompetitionDetailView(competition: competition)) {
                            CompetitionCard(competition: competition)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Weekly Leaderboard
                    weeklyLeaderboardSection
                }
                .padding(.horizontal)
                .padding(.bottom)
                .refreshable {
                    await refreshData()
                }
            }
            .navigationTitle("Competitions")
            .background(Color(.systemGroupedBackground))
            .onAppear {
                Task {
                    await refreshData()
                }
            }
        }
    }
    
    // MARK: - Weekly Leaderboard Section
    private var weeklyLeaderboardSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Weekly Leaderboard")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 10)
            
            CardView {
                VStack(spacing: 0) {
                    ForEach(competitionManager.weeklyLeaderboard) { entry in
                        LeaderboardRow(entry: entry)
                        
                        if entry.id != competitionManager.weeklyLeaderboard.last?.id {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Methods
    private func refreshData() async {
        isRefreshing = true
        await competitionManager.refreshActiveCompetitions()
        isRefreshing = false
    }
}

// MARK: - Competition Card
struct CompetitionCard: View {
    let competition: Competition
    
    var body: some View {
        CardView {
            VStack(spacing: 0) {
                // Competition Image/Header
                competitionHeader
                
                // Competition Details
                competitionDetails
            }
            .cornerRadius(16)
            .clipped()
        }
    }
    
    private var competitionHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image/color
            Rectangle()
                .fill(competition.type == .distance ? Color.green.opacity(0.8) : Color.blue.opacity(0.8))
                .frame(height: 150)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.4)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Title and description
            VStack(alignment: .leading, spacing: 5) {
                Text(competition.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(competition.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(20)
        }
    }
    
    private var competitionDetails: some View {
        VStack(spacing: 15) {
            // Competition stats
            HStack {
                StatView(value: "\(competition.participants)", label: "Participants")
                Spacer()
                StatView(value: "\(daysLeft)", label: "Days Left")
                Spacer()
                StatView(value: "\(competition.tokenReward)", label: "Token Prize")
            }
            .padding(.top, 15)
            
            // Progress bar
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Your Progress")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.1f", competition.currentValue)) / \(String(format: "%.1f", competition.targetValue)) \(competition.unit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressBar(value: competition.progress)
                    .frame(height: 8)
            }
            
            // Action button
            Button(action: {
                // Action for continuing challenge
            }) {
                Text("Continue Challenge")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.top, 5)
        }
        .padding(20)
        .background(Color(.systemBackground))
    }
    
    private var daysLeft: Int {
        let components = Calendar.current.dateComponents([.day], from: Date(), to: competition.endDate)
        return components.day ?? 0
    }
}

// MARK: - Supporting Views
struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

struct ProgressBar: View {
    let value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.2)
                    .foregroundColor(Color.green)
                    .cornerRadius(geometry.size.height / 2)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color.green)
                    .cornerRadius(geometry.size.height / 2)
                    .animation(.linear, value: value)
            }
        }
    }
}

// MARK: - Competition Detail View
struct CompetitionDetailView: View {
    let competition: Competition
    
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Competition Header
                ZStack(alignment: .bottomLeading) {
                    // Background image/color
                    Rectangle()
                        .fill(competition.type == .distance ? Color.green.opacity(0.8) : Color.blue.opacity(0.8))
                        .frame(height: 200)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Title and description
                    VStack(alignment: .leading, spacing: 5) {
                        Text(competition.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(competition.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(20)
                }
                
                // Tabs
                HStack {
                    ForEach(["Overview", "Leaderboard", "Rewards"], id: \.self) { tab in
                        Button(action: {
                            withAnimation {
                                selectedTab = ["Overview", "Leaderboard", "Rewards"].firstIndex(of: tab) ?? 0
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(tab)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(selectedTab == ["Overview", "Leaderboard", "Rewards"].firstIndex(of: tab) ? .green : .secondary)
                                
                                if selectedTab == ["Overview", "Leaderboard", "Rewards"].firstIndex(of: tab) {
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(height: 2)
                                        .matchedGeometryEffect(id: "activeTab", in: namespace)
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 2)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .background(Color(.systemBackground))
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    // Overview Tab
                    overviewTab
                        .tag(0)
                    
                    // Leaderboard Tab
                    leaderboardTab
                        .tag(1)
                    
                    // Rewards Tab
                    rewardsTab
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: UIScreen.main.bounds.height * 0.7)
            }
            .edgesIgnoringSafeArea(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(competition.title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
    }
    
    @Namespace private var namespace
    
    // MARK: - Overview Tab
    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress Card
                CardView {
                    VStack(spacing: 15) {
                        Text("Your Progress")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Progress bar
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Distance Completed")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(String(format: "%.1f", competition.currentValue)) / \(String(format: "%.1f", competition.targetValue)) \(competition.unit)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            ProgressBar(value: competition.progress)
                                .frame(height: 8)
                        }
                        
                        // Stats
                        HStack {
                            StatView(value: "\(daysLeft)", label: "Days Left")
                            Spacer()
                            StatView(value: "\(String(format: "%.1f", dailyGoal)) \(competition.unit)", label: "Daily Goal")
                            Spacer()
                            StatView(value: "\(String(format: "%.1f", remaining)) \(competition.unit)", label: "Remaining")
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                }
                
                // Description Card
                CardView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Challenge Description")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Complete a full marathon distance (42.2 km) over the course of 30 days. Track your progress with your Apple Watch or other connected devices. Daily walks and runs count toward your total distance.")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Text("The top 3 finishers will receive token rewards, and everyone who completes the full distance will earn a completion badge and 50 bonus tokens.")
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.top, 5)
                    }
                    .padding()
                }
                
                // Participants Card
                CardView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Participants (\(competition.participants))")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Top participants
                        VStack(spacing: 15) {
                            ParticipantRow(
                                initials: "JD",
                                name: "John Doe",
                                status: "38.5 km completed",
                                rank: "1st"
                            )
                            
                            Divider()
                            
                            ParticipantRow(
                                initials: "AS",
                                name: "Alice Smith",
                                status: "35.2 km completed",
                                rank: "2nd"
                            )
                            
                            Divider()
                            
                            ParticipantRow(
                                initials: "RJ",
                                name: "Robert Johnson",
                                status: "32.8 km completed",
                                rank: "3rd"
                            )
                            
                            Divider()
                            
                            ParticipantRow(
                                initials: "SH",
                                name: "Scott Hastings",
                                status: "\(String(format: "%.1f", competition.currentValue)) km completed",
                                rank: "8th"
                            )
                        }
                        
                        Button(action: {
                            // View all participants
                        }) {
                            Text("View All Participants")
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
    
    // MARK: - Leaderboard Tab
    private var leaderboardTab: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(1...10, id: \.self) { index in
                    LeaderboardRow(entry: LeaderboardEntry(
                        rank: index,
                        name: mockName(for: index),
                        initials: mockInitials(for: index),
                        score: 100 - ((index - 1) * 3),
                        tokens: index == 1 ? 250 : (index == 2 ? 150 : (index == 3 ? 100 : 0))
                    ))
                    .padding(.horizontal)
                    
                    if index != 10 {
                        Divider()
                            .padding(.leading, 80)
                            .padding(.trailing, 20)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Rewards Tab
    private var rewardsTab: some View {
        ScrollView {
            VStack(spacing: 15) {
                // First Place Reward
                RewardCard(
                    icon: "trophy.fill",
                    iconColor: .yellow,
                    title: "1st Place: 250 Tokens",
                    description: "Top finisher with fastest completion time"
                )
                
                // Second Place Reward
                RewardCard(
                    icon: "medal.fill",
                    iconColor: .yellow,
                    title: "2nd Place: 150 Tokens",
                    description: "Second place finisher"
                )
                
                // Third Place Reward
                RewardCard(
                    icon: "award.fill",
                    iconColor: .yellow,
                    title: "3rd Place: 100 Tokens",
                    description: "Third place finisher"
                )
                
                // Completion Reward
                RewardCard(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Completion: 50 Tokens",
                    description: "Everyone who completes the full 42.2 km"
                )
            }
            .padding()
        }
    }
    
    // MARK: - Helper Properties
    private var daysLeft: Int {
        let components = Calendar.current.dateComponents([.day], from: Date(), to: competition.endDate)
        return components.day ?? 0
    }
    
    private var remaining: Double {
        return competition.targetValue - competition.currentValue
    }
    
    private var dailyGoal: Double {
        guard daysLeft > 0 else { return 0 }
        return remaining / Double(daysLeft)
    }
    
    // MARK: - Mock Data Helpers
    private func mockName(for index: Int) -> String {
        let names = [
            "John Doe", "Alice Smith", "Robert Johnson", "Scott Hastings", "Emily Martinez",
            "Michael Brown", "Sarah Wilson", "David Miller", "Jennifer Davis", "James Anderson"
        ]
        return names[index - 1]
    }
    
    private func mockInitials(for index: Int) -> String {
        let initials = ["JD", "AS", "RJ", "SH", "EM", "MB", "SW", "DM", "JD", "JA"]
        return initials[index - 1]
    }
}

// MARK: - Supporting Views
struct ParticipantRow: View {
    let initials: String
    let name: String
    let status: String
    let rank: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                
                Text(initials)
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                
                Text(status)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 5)
            
            Spacer()
            
            Text(rank)
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundColor(rank == "1st" ? .green : .secondary)
        }
    }
}

struct RewardCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                
                Text(description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(iconColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview
struct CompetitionsView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionsView()
            .environmentObject(CompetitionManager())
    }
}
