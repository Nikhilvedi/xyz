//
//  NotificationManagerTests.swift
//  WorkoutSummaryAppTests
//
//  Unit tests for notification manager
//

import XCTest
@testable import WorkoutSummaryApp

class NotificationManagerTests: XCTestCase {
    
    var notificationManager: NotificationManager!
    
    override func setUp() {
        super.setUp()
        notificationManager = NotificationManager.shared
    }
    
    override func tearDown() {
        notificationManager = nil
        super.tearDown()
    }
    
    // MARK: - Day Name Tests
    
    func testDayNames() {
        XCTAssertEqual(notificationManager.dayName(for: 0), "Sunday")
        XCTAssertEqual(notificationManager.dayName(for: 1), "Monday")
        XCTAssertEqual(notificationManager.dayName(for: 2), "Tuesday")
        XCTAssertEqual(notificationManager.dayName(for: 3), "Wednesday")
        XCTAssertEqual(notificationManager.dayName(for: 4), "Thursday")
        XCTAssertEqual(notificationManager.dayName(for: 5), "Friday")
        XCTAssertEqual(notificationManager.dayName(for: 6), "Saturday")
    }
    
    // MARK: - Time Format Tests
    
    func testTimeFormatting() {
        let time8AM = notificationManager.formatTime(hour: 8)
        XCTAssertTrue(time8AM.contains("8"))
        XCTAssertTrue(time8AM.lowercased().contains("am"))
        
        let time8PM = notificationManager.formatTime(hour: 20)
        XCTAssertTrue(time8PM.contains("8"))
        XCTAssertTrue(time8PM.lowercased().contains("pm"))
        
        let time12PM = notificationManager.formatTime(hour: 12)
        XCTAssertTrue(time12PM.contains("12"))
        XCTAssertTrue(time12PM.lowercased().contains("pm"))
    }
    
    // MARK: - Settings Persistence Tests
    
    func testSettingsPersistence() {
        // Save settings
        notificationManager.notificationDay = 3 // Wednesday
        notificationManager.notificationHour = 18 // 6 PM
        
        // Verify saved
        let savedDay = UserDefaults.standard.integer(forKey: "notificationDay")
        let savedHour = UserDefaults.standard.integer(forKey: "notificationHour")
        
        XCTAssertEqual(savedDay, 3)
        XCTAssertEqual(savedHour, 18)
    }
    
    // MARK: - Notification State Tests
    
    func testNotificationEnabledToggle() {
        let initialState = notificationManager.notificationsEnabled
        notificationManager.notificationsEnabled = !initialState
        
        let savedState = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        XCTAssertEqual(savedState, !initialState)
    }
    
    // MARK: - Edge Cases
    
    func testBoundaryHours() {
        // Test midnight
        let midnight = notificationManager.formatTime(hour: 0)
        XCTAssertTrue(midnight.contains("12"))
        XCTAssertTrue(midnight.lowercased().contains("am"))
        
        // Test noon
        let noon = notificationManager.formatTime(hour: 12)
        XCTAssertTrue(noon.contains("12"))
        XCTAssertTrue(noon.lowercased().contains("pm"))
        
        // Test 11 PM
        let elevenPM = notificationManager.formatTime(hour: 23)
        XCTAssertTrue(elevenPM.contains("11"))
        XCTAssertTrue(elevenPM.lowercased().contains("pm"))
    }
}
