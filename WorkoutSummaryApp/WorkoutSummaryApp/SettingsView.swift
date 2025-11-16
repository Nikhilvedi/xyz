//
//  SettingsView.swift
//  WorkoutSummaryApp
//
//  Settings screen for notifications and preferences
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            List {
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
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
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
