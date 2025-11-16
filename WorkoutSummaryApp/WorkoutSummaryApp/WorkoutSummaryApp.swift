//
//  WorkoutSummaryApp.swift
//  WorkoutSummaryApp
//
//  Main app entry point
//

import SwiftUI

@main
struct WorkoutSummaryApp: App {
    @StateObject private var viewModel = WorkoutViewModel()
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
                .environmentObject(notificationManager)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .onAppear {
                    notificationManager.checkAuthorizationStatus()
                }
        }
    }
    
    // Handle incoming URLs from Share Extension
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "workoutsummary" else { return }
        
        if url.host == "share" {
            // Load text from UserDefaults shared container
            if let sharedDefaults = UserDefaults(suiteName: "group.com.workoutsummary.app"),
               let sharedText = sharedDefaults.string(forKey: "sharedText") {
                viewModel.loadSharedText(sharedText)
                // Clear the shared text after loading
                sharedDefaults.removeObject(forKey: "sharedText")
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Workouts", systemImage: "list.bullet")
                }
            
            GoalsView(goals: $viewModel.weeklyGoals, workoutDays: viewModel.workoutDays)
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
