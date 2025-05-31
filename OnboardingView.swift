//
//  OnboardingView.swift
//  HealthIndex
//
//  Created for Scott Hastings on 5/31/2025.
//

import SwiftUI
import AuthenticationServices

struct OnboardingView: View {
    // MARK: - Environment
    @EnvironmentObject private var userProfileManager: UserProfileManager
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - State
    @State private var currentPage = 0
    @State private var showLogin = false
    
    // Onboarding pages content
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "chart.line.uptrend.xyaxis",
            title: "Track Your Health Index",
            description: "Monitor physical, blood, and wellness biomarkers in one comprehensive score."
        ),
        OnboardingPage(
            image: "trophy.fill",
            title: "Compete & Earn Rewards",
            description: "Join challenges, compete with friends, and earn tokens for your achievements."
        ),
        OnboardingPage(
            image: "heart.text.square.fill",
            title: "Personalized Insights",
            description: "Get actionable recommendations based on your health data and progress."
        )
    ]
    
    // MARK: - Body
    var body: some View {
        if showLogin {
            loginView
        } else {
            onboardingPagesView
        }
    }
    
    // MARK: - Login View
    private var loginView: some View {
        VStack(spacing: 30) {
            // App Logo
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
            }
            
            // App Title & Description
            VStack(spacing: 10) {
                Text("Health Index")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("Track, compete, and improve your health score")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Sign in Buttons
            VStack(spacing: 15) {
                // Apple Sign In Button
                SignInWithAppleButton(
                    .signIn,
                    onRequest: configureAppleSignIn,
                    onCompletion: handleAppleSignIn
                )
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 50)
                .cornerRadius(12)
                
                // Email Sign In Button (placeholder for future)
                Button(action: {
                    // Email sign in would go here
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.primary)
                        Text("Sign in with Email")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal)
            
            // Sign up text
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                
                Button("Sign up") {
                    // Sign up action would go here
                }
                .foregroundColor(.green)
                .fontWeight(.medium)
            }
            .padding(.top)
            
            Spacer()
                .frame(height: 40)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .transition(.opacity)
    }
    
    // MARK: - Onboarding Pages View
    private var onboardingPagesView: some View {
        VStack {
            // Skip button
            HStack {
                Spacer()
                
                Button("Skip") {
                    withAnimation {
                        showLogin = true
                    }
                }
                .foregroundColor(.secondary)
                .padding()
            }
            
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            .transition(.slide)
            
            // Pagination dots
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            // Navigation buttons
            HStack {
                Button("Back") {
                    if currentPage > 0 {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                }
                .opacity(currentPage > 0 ? 1.0 : 0.0)
                .disabled(currentPage == 0)
                
                Spacer()
                
                Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        withAnimation {
                            showLogin = true
                        }
                    }
                }
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.green)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
    
    // MARK: - Methods
    private func configureAppleSignIn(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // In a real app, you would:
                // 1. Verify the identity token with your server
                // 2. Create or fetch the user account
                // 3. Sign the user in
                
                print("Successfully authenticated with Apple ID: \(appleIDCredential.user)")
                
                // For demo purposes, just call the sign in method
                userProfileManager.signInWithApple()
            }
        case .failure(let error):
            print("Apple Sign In failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Supporting Types
struct OnboardingPage {
    let image: String
    let title: String
    let description: String
}

// MARK: - Supporting Views
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Image
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Image(systemName: page.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.green)
                    .frame(width: 100, height: 100)
            }
            
            // Text
            VStack(spacing: 10) {
                Text(page.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(UserProfileManager())
    }
}
