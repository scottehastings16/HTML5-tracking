//
//  DashboardView.swift
//  HealthIndex
//
//  Created for Scott Hastings on 5/31/2025.
//

import SwiftUI
import HealthKit

struct DashboardView: View {
    // MARK: - Environment
    @EnvironmentObject private var healthKitService: HealthKitService
    @EnvironmentObject private var userProfileManager: UserProfileManager
    @EnvironmentObject private var competitionManager: CompetitionManager
    
    // MARK: - State
    @State private var isRefreshing = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Health Index Card
                    healthScoreCard
                    
                    // Recent Activity Card
                    recentActivityCard
                    
                    // Quick Actions Card
                    quickActionsCard
                    
                    // Weekly Leaderboard Card
                    weeklyLeaderboardCard
                }
                .padding(.horizontal)
                .padding(.bottom)
                .refreshable {
                    await refreshData()
                }
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemGroupedBackground))
            .onAppear {
                Task {
                    await refreshData()
                }
            }
        }
    }
    
    // MARK: - Health Score Card
    private var healthScoreCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Health Index")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(alignment: .center, spacing: 20) {
                    // Circular Score
                    ZStack {
                        CircleProgressView(progress: 0.78)
                            .frame(width: 120, height: 120)
                        
                        Text("78")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    // Score Categories
                    VStack(spacing: 12) {
                        ScoreCategoryRow(title: "Physical", score: 82, maxScore: 100, fillColor: .green)
                        ScoreCategoryRow(title: "Blood", score: 75, maxScore: 100, fillColor: .blue)
                        ScoreCategoryRow(title: "Wellness", score: 68, maxScore: 100, fillColor: .indigo)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Recent Activity Card
    private var recentActivityCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ActivityRow(
                    icon: "heart.fill",
                    iconColor: .red,
                    title: "Heart Rate",
                    subtitle: "Average today",
                    value: "\(Int(healthKitService.latestHeartRate)) bpm"
                )
                
                Divider()
                
                ActivityRow(
                    icon: "figure.walk",
                    iconColor: .green,
                    title: "Steps",
                    subtitle: "Today",
                    value: "\(Int(healthKitService.latestSteps).formattedWithCommas)"
                )
                
                Divider()
                
                ActivityRow(
                    icon: "flame.fill",
                    iconColor: .orange,
                    title: "Active Energy",
                    subtitle: "Today",
                    value: "\(Int(healthKitService.latestActiveEnergy)) kcal"
                )
            }
            .padding()
        }
    }
    
    // MARK: - Quick Actions Card
    private var quickActionsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Quick Actions")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 10) {
                    NavigationLink(destination: DietEntryView()) {
                        QuickActionButton(
                            icon: "fork.knife",
                            title: "Log Diet",
                            color: .green
                        )
                    }
                    
                    NavigationLink(destination: CompetitionsView()) {
                        QuickActionButton(
                            icon: "trophy.fill",
                            title: "Compete",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: AddDataView()) {
                        QuickActionButton(
                            icon: "plus",
                            title: "Add Data",
                            color: .indigo
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Weekly Leaderboard Card
    private var weeklyLeaderboardCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Weekly Leaderboard")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ForEach(competitionManager.weeklyLeaderboard.prefix(3)) { entry in
                    LeaderboardRow(entry: entry)
                    
                    if entry.id != competitionManager.weeklyLeaderboard.prefix(3).last?.id {
                        Divider()
                    }
                }
                
                NavigationLink(destination: CompetitionsView()) {
                    Text("View All Competitions")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
        }
    }
    
    // MARK: - Methods
    private func refreshData() async {
        isRefreshing = true
        
        await healthKitService.fetchLatestData()
        await competitionManager.refreshActiveCompetitions()
        
        isRefreshing = false
    }
}

// MARK: - Supporting Views
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CircleProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.1)
                .foregroundColor(Color.green)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.green)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}

struct ScoreCategoryRow: View {
    let title: String
    let score: Int
    let maxScore: Int
    let fillColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(score)/\(maxScore)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 6)
                        .opacity(0.2)
                        .foregroundColor(fillColor)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .frame(width: geometry.size.width * CGFloat(Double(score) / Double(maxScore)), height: 6)
                        .foregroundColor(fillColor)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let value: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                
                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundColor(.green)
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
            
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(color)
        .cornerRadius(12)
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(entry.rank == 1 ? Color.yellow : Color(.systemGray5))
                    .frame(width: 30, height: 30)
                
                Text("\(entry.rank)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(entry.rank == 1 ? .black : .primary)
            }
            
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                
                Text(entry.initials)
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.leading, 5)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                
                Text("Health Score: \(entry.score)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 5)
            
            Spacer()
            
            HStack(spacing: 2) {
                Image(systemName: "coins.fill")
                    .foregroundColor(.yellow)
                
                Text("\(entry.tokens)")
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundColor(.yellow)
            }
        }
    }
}

// MARK: - Placeholder Views
struct DietEntryView: View {
    var body: some View {
        Text("Diet Entry View")
            .navigationTitle("Log Diet")
    }
}

struct AddDataView: View {
    var body: some View {
        Text("Add Data View")
            .navigationTitle("Add Health Data")
    }
}

// MARK: - Extensions
extension Int {
    var formattedWithCommas: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(HealthKitService.shared)
            .environmentObject(UserProfileManager())
            .environmentObject(CompetitionManager())
    }
}
