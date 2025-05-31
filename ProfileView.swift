//
//  ProfileView.swift
//  HealthIndex
//
//  Created for Scott Hastings on 5/31/2025.
//

import SwiftUI
import HealthKit

struct ProfileView: View {
    // MARK: - Environment
    @EnvironmentObject private var userProfileManager: UserProfileManager
    @EnvironmentObject private var healthKitService: HealthKitService
    @EnvironmentObject private var tokenManager: TokenManager
    
    // MARK: - State
    @State private var showSignOutAlert = false
    @State private var darkModeEnabled = false
    @State private var showHealthDataOnLeaderboard = true
    @State private var showNameOnLeaderboard = true
    @State private var notificationsEnabled = true
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Profile Header
                    profileHeader
                    
                    // Account Settings
                    accountSettingsCard
                    
                    // Health Data Settings
                    healthDataCard
                    
                    // App Settings
                    appSettingsCard
                    
                    // Sign Out Button
                    signOutButton
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Profile")
            .background(Color(.systemGroupedBackground))
            .alert(isPresented: $showSignOutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        userProfileManager.signOut()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        CardView {
            VStack(spacing: 20) {
                HStack {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 80, height: 80)
                        
                        Text(userProfileManager.userAvatar)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // User Info
                    VStack(alignment: .leading, spacing: 5) {
                        Text(userProfileManager.userName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Health Score: \(userProfileManager.healthScore)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Token Balance
                        HStack {
                            Image(systemName: "coins.fill")
                                .foregroundColor(.yellow)
                            
                            Text("\(tokenManager.balance) Tokens")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.yellow)
                        }
                        .padding(.top, 2)
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                }
                
                // Edit Profile Button
                Button(action: {
                    // Action for editing profile
                }) {
                    Text("Edit Profile")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Account Settings Card
    private var accountSettingsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Account Settings")
                    .font(.headline)
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Personal Information
                NavigationLink(destination: Text("Personal Information Settings")) {
                    SettingsRow(icon: "person.fill", iconColor: .green, title: "Personal Information")
                }
                
                Divider()
                    .padding(.leading, 56)
                
                // Notifications
                NavigationLink(destination: Text("Notifications Settings")) {
                    SettingsRow(
                        icon: "bell.fill",
                        iconColor: .orange,
                        title: "Notifications",
                        trailingContent: {
                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                        }
                    )
                }
                
                Divider()
                    .padding(.leading, 56)
                
                // Privacy & Security
                NavigationLink(destination: Text("Privacy & Security Settings")) {
                    SettingsRow(icon: "lock.fill", iconColor: .blue, title: "Privacy & Security")
                }
                
                Divider()
                    .padding(.leading, 56)
                
                // Tokens & Rewards
                NavigationLink(destination: Text("Tokens & Rewards Settings")) {
                    SettingsRow(icon: "coins.fill", iconColor: .yellow, title: "Tokens & Rewards")
                }
            }
            .padding(.bottom)
        }
    }
    
    // MARK: - Health Data Card
    private var healthDataCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Health Data")
                    .font(.headline)
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Connected Devices
                NavigationLink(destination: Text("Connected Devices Settings")) {
                    SettingsRow(icon: "heart.fill", iconColor: .red, title: "Connected Devices")
                }
                
                Divider()
                    .padding(.leading, 56)
                
                // Import Health Data
                NavigationLink(destination: Text("Import Health Data")) {
                    SettingsRow(icon: "arrow.down.doc.fill", iconColor: .purple, title: "Import Health Data")
                }
                
                Divider()
                    .padding(.leading, 56)
                
                // Data History
                NavigationLink(destination: Text("Data History")) {
                    SettingsRow(icon: "clock.fill", iconColor: .gray, title: "Data History")
                }
                
                Divider()
                    .padding(.leading, 56)
                
                // Health Permissions
                NavigationLink(destination: Text("Health Permissions")) {
                    SettingsRow(icon: "hand.raised.fill", iconColor: .pink, title: "Health Permissions")
                }
            }
            .padding(.bottom)
        }
    }
    
    // MARK: - App Settings Card
    private var appSettingsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 0) {
                Text("App Settings")
                    .font(.headline)
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Dark Mode
                SettingsRow(
                    icon: "moon.fill",
                    iconColor: .indigo,
                    title: "Dark Mode",
                    trailingContent: {
                        Toggle("", isOn: $darkModeEnabled)
                            .labelsHidden()
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                // Show Name on Leaderboard
                SettingsRow(
                    icon: "person.2.fill",
                    iconColor: .blue,
                    title: "Show My Name on Leaderboards",
                    trailingContent: {
                        Toggle("", isOn: $showNameOnLeaderboard)
                            .labelsHidden()
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                // Show Health Data
                SettingsRow(
                    icon: "chart.bar.fill",
                    iconColor: .green,
                    title: "Share My Health Score",
                    trailingContent: {
                        Toggle("", isOn: $showHealthDataOnLeaderboard)
                            .labelsHidden()
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                // About
                NavigationLink(destination: Text("About Health Index App")) {
                    SettingsRow(icon: "info.circle.fill", iconColor: .gray, title: "About")
                }
            }
            .padding(.bottom)
        }
    }
    
    // MARK: - Sign Out Button
    private var signOutButton: some View {
        Button(action: {
            showSignOutAlert = true
        }) {
            HStack {
                Spacer()
                
                HStack {
                    Image(systemName: "arrow.right.square.fill")
                        .font(.system(size: 18))
                    
                    Text("Sign Out")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
                
                Spacer()
            }
            .foregroundColor(.red)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Settings Row
struct SettingsRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let trailingContent: (() -> Content)?
    
    init(icon: String, iconColor: Color, title: String, trailingContent: (() -> Content)? = nil) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.system(.body, design: .rounded))
                .padding(.leading, 10)
            
            Spacer()
            
            if let trailingContent = trailingContent {
                trailingContent()
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserProfileManager())
            .environmentObject(HealthKitService.shared)
            .environmentObject(TokenManager())
    }
}
