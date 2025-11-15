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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onOpenURL { url in
                    handleIncomingURL(url)
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
