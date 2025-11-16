//
//  NotificationManager.swift
//  WorkoutSummaryApp
//
//  Manager for handling local notifications
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var notificationsEnabled = false {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
                scheduleWeeklySummaryNotification()
            } else {
                cancelAllNotifications()
            }
        }
    }
    
    // Notification settings
    @Published var notificationDay: Int = 0 { // 0 = Sunday, 1 = Monday, etc.
        didSet {
            UserDefaults.standard.set(notificationDay, forKey: "notificationDay")
            if notificationsEnabled {
                scheduleWeeklySummaryNotification()
            }
        }
    }
    
    @Published var notificationHour: Int = 20 { // 8 PM default
        didSet {
            UserDefaults.standard.set(notificationHour, forKey: "notificationHour")
            if notificationsEnabled {
                scheduleWeeklySummaryNotification()
            }
        }
    }
    
    private init() {
        loadSettings()
        checkAuthorizationStatus()
    }
    
    // MARK: - Settings Persistence
    
    private func loadSettings() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        notificationDay = UserDefaults.standard.integer(forKey: "notificationDay")
        if UserDefaults.standard.object(forKey: "notificationHour") == nil {
            notificationHour = 20 // Default to 8 PM
        } else {
            notificationHour = UserDefaults.standard.integer(forKey: "notificationHour")
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.notificationsEnabled = true
                }
                completion(granted)
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Weekly Summary Notification
    
    func scheduleWeeklySummaryNotification() {
        // Cancel existing notifications first
        cancelAllNotifications()
        
        guard isAuthorized && notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📊 Weekly Workout Summary"
        content.body = "Time to review your week's progress! Check your goals and muscle group coverage."
        content.sound = .default
        content.badge = 1
        
        // Create weekly trigger
        var dateComponents = DateComponents()
        dateComponents.weekday = notificationDay + 1 // Sunday = 1 in DateComponents
        dateComponents.hour = notificationHour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weeklySummary",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Goal Completion Notification
    
    func scheduleGoalCompletionNotification(goalName: String) {
        guard isAuthorized && notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 Goal Completed!"
        content.body = "Congratulations! You've completed your \(goalName) goal for this week."
        content.sound = .default
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "goalCompleted_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Reminder Notifications
    
    func scheduleWorkoutReminder(day: String, time: Date) {
        guard isAuthorized && notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "💪 Workout Reminder"
        content.body = "Time for your \(day) workout! Don't forget to log it."
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.weekday, .hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "workoutReminder_\(day)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Notification Management
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func dayName(for index: Int) -> String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[index]
    }
    
    func formatTime(hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(hour):00"
    }
}
