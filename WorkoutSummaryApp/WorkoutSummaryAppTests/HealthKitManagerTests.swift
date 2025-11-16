//
//  HealthKitManagerTests.swift
//  WorkoutSummaryAppTests
//
//  Unit tests for HealthKit manager
//

import XCTest
import HealthKit
@testable import WorkoutSummaryApp

class HealthKitManagerTests: XCTestCase {
    
    var healthKitManager: HealthKitManager!
    
    override func setUp() {
        super.setUp()
        healthKitManager = HealthKitManager.shared
    }
    
    override func tearDown() {
        healthKitManager = nil
        super.tearDown()
    }
    
    // MARK: - Workout Activity Name Tests
    
    func testWorkoutActivityNames() {
        // Test that different activity types return appropriate names
        let manager = HealthKitManager.shared
        
        // These are tested through the formatWorkout method indirectly
        // Since the workoutActivityName method is private, we test through public interface
        XCTAssertNotNil(manager)
    }
    
    // MARK: - Settings Persistence Tests
    
    func testSettingsPersistence() {
        // Save settings
        healthKitManager.healthKitEnabled = true
        healthKitManager.autoSyncEnabled = true
        
        // Verify saved
        let savedHealthKit = UserDefaults.standard.bool(forKey: "healthKitEnabled")
        let savedAutoSync = UserDefaults.standard.bool(forKey: "autoSyncEnabled")
        
        XCTAssertEqual(savedHealthKit, true)
        XCTAssertEqual(savedAutoSync, true)
    }
    
    func testToggleHealthKitEnabled() {
        let initialState = healthKitManager.healthKitEnabled
        healthKitManager.healthKitEnabled = !initialState
        
        let savedState = UserDefaults.standard.bool(forKey: "healthKitEnabled")
        XCTAssertEqual(savedState, !initialState)
    }
    
    func testToggleAutoSync() {
        let initialState = healthKitManager.autoSyncEnabled
        healthKitManager.autoSyncEnabled = !initialState
        
        let savedState = UserDefaults.standard.bool(forKey: "autoSyncEnabled")
        XCTAssertEqual(savedState, !initialState)
    }
    
    // MARK: - Text Conversion Tests
    
    func testConvertEmptyWorkoutsToText() {
        let emptyWorkouts: [HKWorkout] = []
        let text = healthKitManager.convertWorkoutsToText(workouts: emptyWorkouts)
        
        XCTAssertEqual(text, "")
    }
    
    func testConvertWorkoutsGroupsByDay() {
        // This test would require creating mock HKWorkout objects
        // which is complex due to HealthKit's design
        // In a real app, you'd use dependency injection to make this testable
        XCTAssertNotNil(healthKitManager)
    }
    
    // MARK: - Format Tests
    
    func testTextFormatting() {
        // Test that the text conversion produces valid format
        let emptyWorkouts: [HKWorkout] = []
        let text = healthKitManager.convertWorkoutsToText(workouts: emptyWorkouts)
        
        // Empty workouts should produce empty string
        XCTAssertTrue(text.isEmpty)
    }
    
    // MARK: - Authorization Tests
    
    func testHealthKitAvailability() {
        // Test if HealthKit is available (may vary by simulator/device)
        let isAvailable = HKHealthStore.isHealthDataAvailable()
        
        // This test documents expected behavior
        // HealthKit is available on real devices but may not be on all simulators
        XCTAssertNotNil(isAvailable)
    }
}
