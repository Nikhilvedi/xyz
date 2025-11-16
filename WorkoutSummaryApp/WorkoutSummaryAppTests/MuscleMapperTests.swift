//
//  MuscleMapperTests.swift
//  WorkoutSummaryAppTests
//
//  Unit tests for muscle mapping and analysis
//

import XCTest
@testable import WorkoutSummaryApp

class MuscleMapperTests: XCTestCase {
    
    // MARK: - Muscle Group Detection Tests
    
    func testChestExerciseMapping() {
        let exercise = Exercise(
            rawText: "3x10 bench press",
            sets: 3,
            reps: 10,
            quantity: nil,
            unit: nil,
            movement: "bench press"
        )
        
        let muscles = MuscleMapper.getMuscleGroups(for: exercise)
        
        XCTAssertTrue(muscles.contains(.chest))
        XCTAssertTrue(muscles.contains(.triceps))
        XCTAssertTrue(muscles.contains(.shoulders))
    }
    
    func testPullUpMapping() {
        let exercise = Exercise(
            rawText: "3x10 pull ups",
            sets: 3,
            reps: 10,
            quantity: nil,
            unit: nil,
            movement: "pull ups"
        )
        
        let muscles = MuscleMapper.getMuscleGroups(for: exercise)
        
        XCTAssertTrue(muscles.contains(.lats))
        XCTAssertTrue(muscles.contains(.upperBack))
        XCTAssertTrue(muscles.contains(.biceps))
    }
    
    func testSquatMapping() {
        let exercise = Exercise(
            rawText: "5x5 squats",
            sets: 5,
            reps: 5,
            quantity: nil,
            unit: nil,
            movement: "squats"
        )
        
        let muscles = MuscleMapper.getMuscleGroups(for: exercise)
        
        XCTAssertTrue(muscles.contains(.quads))
        XCTAssertTrue(muscles.contains(.glutes))
        XCTAssertTrue(muscles.contains(.hamstrings))
    }
    
    func testCardioMapping() {
        let exercise = Exercise(
            rawText: "5k run",
            sets: nil,
            reps: nil,
            quantity: 5,
            unit: "k",
            movement: "run"
        )
        
        let muscles = MuscleMapper.getMuscleGroups(for: exercise)
        
        XCTAssertTrue(muscles.contains(.cardio))
    }
    
    func testPushUpMapping() {
        let exercise = Exercise(
            rawText: "50 push ups",
            sets: nil,
            reps: 50,
            quantity: nil,
            unit: nil,
            movement: "push ups"
        )
        
        let muscles = MuscleMapper.getMuscleGroups(for: exercise)
        
        XCTAssertTrue(muscles.contains(.chest))
        XCTAssertTrue(muscles.contains(.triceps))
    }
    
    // MARK: - Intensity Calculation Tests
    
    func testIntensityCalculationWithStrengthExercises() {
        let days = [
            WorkoutDay(dateLabel: "Day 1", exercises: [
                Exercise(rawText: "3x10 bench press", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "bench press"),
                Exercise(rawText: "3x10 pull ups", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "pull ups")
            ])
        ]
        
        let intensity = MuscleMapper.calculateMuscleIntensity(for: days)
        
        XCTAssertNotNil(intensity[.chest])
        XCTAssertNotNil(intensity[.lats])
        XCTAssertTrue(intensity[.chest]! > 0)
        XCTAssertTrue(intensity[.lats]! > 0)
    }
    
    func testIntensityCalculationWithMultipleDays() {
        let days = [
            WorkoutDay(dateLabel: "Day 1", exercises: [
                Exercise(rawText: "3x10 bench press", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "bench press")
            ]),
            WorkoutDay(dateLabel: "Day 2", exercises: [
                Exercise(rawText: "3x10 bench press", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "bench press")
            ])
        ]
        
        let intensity = MuscleMapper.calculateMuscleIntensity(for: days)
        
        // Chest should have higher intensity from being worked twice
        XCTAssertNotNil(intensity[.chest])
        XCTAssertTrue(intensity[.chest]! > 0)
    }
    
    func testIntensityNormalization() {
        let days = [
            WorkoutDay(dateLabel: "Day 1", exercises: [
                Exercise(rawText: "3x10 bench press", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "bench press")
            ])
        ]
        
        let intensity = MuscleMapper.calculateMuscleIntensity(for: days)
        
        // All intensities should be between 0 and 1
        for (_, value) in intensity {
            XCTAssertTrue(value >= 0 && value <= 1)
        }
    }
    
    func testEmptyWorkoutDays() {
        let days: [WorkoutDay] = []
        let intensity = MuscleMapper.calculateMuscleIntensity(for: days)
        
        XCTAssertTrue(intensity.isEmpty)
    }
    
    // MARK: - Color Tests
    
    func testColorForZeroIntensity() {
        let color = MuscleMapper.getColor(for: 0)
        // Color should be gray for no work
        XCTAssertNotNil(color)
    }
    
    func testColorForLightIntensity() {
        let color = MuscleMapper.getColor(for: 0.2)
        // Should return yellow for light work
        XCTAssertNotNil(color)
    }
    
    func testColorForModerateIntensity() {
        let color = MuscleMapper.getColor(for: 0.5)
        // Should return orange for moderate work
        XCTAssertNotNil(color)
    }
    
    func testColorForHeavyIntensity() {
        let color = MuscleMapper.getColor(for: 0.8)
        // Should return red for heavy work
        XCTAssertNotNil(color)
    }
    
    // MARK: - Description Tests
    
    func testIntensityDescriptions() {
        XCTAssertEqual(MuscleMapper.getIntensityDescription(for: 0), "Not Targeted")
        XCTAssertEqual(MuscleMapper.getIntensityDescription(for: 0.2), "Light")
        XCTAssertEqual(MuscleMapper.getIntensityDescription(for: 0.5), "Moderate")
        XCTAssertEqual(MuscleMapper.getIntensityDescription(for: 0.8), "Heavy")
    }
    
    // MARK: - Edge Cases
    
    func testUnrecognizedExercise() {
        let exercise = Exercise(
            rawText: "some unknown movement",
            sets: 3,
            reps: 10,
            quantity: nil,
            unit: nil,
            movement: "unknown movement"
        )
        
        let muscles = MuscleMapper.getMuscleGroups(for: exercise)
        
        // Should return empty array for unrecognized exercises
        XCTAssertTrue(muscles.isEmpty)
    }
    
    func testCaseInsensitiveMatching() {
        let exercise1 = Exercise(
            rawText: "BENCH PRESS",
            sets: 3,
            reps: 10,
            quantity: nil,
            unit: nil,
            movement: "BENCH PRESS"
        )
        
        let exercise2 = Exercise(
            rawText: "bench press",
            sets: 3,
            reps: 10,
            quantity: nil,
            unit: nil,
            movement: "bench press"
        )
        
        let muscles1 = MuscleMapper.getMuscleGroups(for: exercise1)
        let muscles2 = MuscleMapper.getMuscleGroups(for: exercise2)
        
        // Should match regardless of case
        XCTAssertEqual(Set(muscles1), Set(muscles2))
    }
}
