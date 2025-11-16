//
//  SettingsView.swift
//  WorkoutSummaryApp
//
//  Settings screen for notifications, HealthKit, and preferences
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var showingPermissionAlert = false
    @State private var showingHealthKitAlert = false
    @State private var healthKitAlertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // HealthKit Integration Section
                Section(header: Text("HealthKit Integration")) {
                    Toggle("Enable HealthKit Sync", isOn: $healthKitManager.healthKitEnabled)
                        .onChange(of: healthKitManager.healthKitEnabled) { newValue in
                            if newValue && !healthKitManager.isAuthorized {
                                requestHealthKitPermission()
                            }
                        }
                    
                    if healthKitManager.healthKitEnabled {
                        Toggle("Auto-sync on app launch", isOn: $healthKitManager.autoSyncEnabled)
                        
                        Text("Automatically import workouts from Apple Health including running, cycling, swimming, strength training, and more.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                
                // HealthKit Info
                if healthKitManager.healthKitEnabled {
                    Section(header: Text("Supported Activities")) {
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(icon: "figure.run", text: "Running, Walking, Hiking")
                            InfoRow(icon: "bicycle", text: "Cycling")
                            InfoRow(icon: "figure.pool.swim", text: "Swimming")
                            InfoRow(icon: "dumbbell.fill", text: "Strength Training")
                            InfoRow(icon: "flame.fill", text: "HIIT, Cross Training")
                            InfoRow(icon: "figure.mind.and.body", text: "Yoga, Pilates")
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Notifications Section
                Section(header: Text("Weekly Summary Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationManager.notificationsEnabled)
                        .onChange(of: notificationManager.notificationsEnabled) { newValue in
                            if newValue && !notificationManager.isAuthorized {
                                requestNotificationPermission()
                            }
                        }
                    
                    if notificationManager.notificationsEnabled {
                        Picker("Day", selection: $notificationManager.notificationDay) {
                            ForEach(0..<7, id: \.self) { day in
                                Text(notificationManager.dayName(for: day)).tag(day)
                            }
                        }
                        
                        Picker("Time", selection: $notificationManager.notificationHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(notificationManager.formatTime(hour: hour)).tag(hour)
                            }
                        }
                        
                        Text("You'll receive a weekly summary every \(notificationManager.dayName(for: notificationManager.notificationDay)) at \(notificationManager.formatTime(hour: notificationManager.notificationHour))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                
                // Notification Info
                Section(header: Text("About Notifications")) {
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(icon: "bell.fill", text: "Weekly summary of your workouts and goals")
                        InfoRow(icon: "target", text: "Goal completion alerts")
                        InfoRow(icon: "chart.bar.fill", text: "Muscle group coverage insights")
                    }
                    .padding(.vertical, 4)
                }
                
                // App Info
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.1")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Notification Permission", isPresented: $showingPermissionAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enable notifications in Settings to receive weekly summaries.")
            }
            .alert("HealthKit", isPresented: $showingHealthKitAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(healthKitAlertMessage)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func requestNotificationPermission() {
        notificationManager.requestAuthorization { granted in
            if !granted {
                notificationManager.notificationsEnabled = false
                showingPermissionAlert = true
            }
        }
    }
    
    private func requestHealthKitPermission() {
        healthKitManager.requestAuthorization { success, error in
            if !success {
                healthKitManager.healthKitEnabled = false
                healthKitAlertMessage = error?.localizedDescription ?? "Please enable HealthKit access in Settings."
                showingHealthKitAlert = true
            }
        }
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
