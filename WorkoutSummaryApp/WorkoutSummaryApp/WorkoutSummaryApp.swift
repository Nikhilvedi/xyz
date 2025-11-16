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
    @StateObject private var healthKitManager = HealthKitManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
                .environmentObject(notificationManager)
                .environmentObject(healthKitManager)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .onAppear {
                    notificationManager.checkAuthorizationStatus()
                    healthKitManager.checkAuthorizationStatus()
                    
                    // Auto-sync if enabled
                    if healthKitManager.autoSyncEnabled && healthKitManager.isAuthorized {
                        autoSyncHealthKitWorkouts()
                    }
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
    
    // Auto-sync HealthKit workouts on app launch
    private func autoSyncHealthKitWorkouts() {
        healthKitManager.syncWorkouts { text, error in
            guard let text = text, !text.isEmpty, error == nil else { return }
            
            // Only auto-fill if input is empty
            if viewModel.inputText.isEmpty {
                viewModel.inputText = text
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
