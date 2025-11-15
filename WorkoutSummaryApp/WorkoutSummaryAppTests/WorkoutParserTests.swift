//
//  WorkoutParserTests.swift
//  WorkoutSummaryAppTests
//
//  Unit tests for workout parser
//

import XCTest
@testable import WorkoutSummaryApp

class WorkoutParserTests: XCTestCase {
    
    var parser: WorkoutParser!
    
    override func setUp() {
        super.setUp()
        parser = WorkoutParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    // MARK: - Day Detection Tests
    
    func testParseDayNumber() {
        let input = """
        Day 1
        3x10 pull ups
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].dateLabel, "Day 1")
        XCTAssertEqual(result[0].exercises.count, 1)
    }
    
    func testParseWeekdayFull() {
        let input = """
        Monday
        3x10 pull ups
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].dateLabel, "Monday")
        XCTAssertEqual(result[0].exercises.count, 1)
    }
    
    func testParseWeekdayAbbreviated() {
        let input = """
        Tue
        3x10 pull ups
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].dateLabel, "Tue")
        XCTAssertEqual(result[0].exercises.count, 1)
    }
    
    func testParseDateSlashFormat() {
        let input = """
        17/11/25
        3x10 pull ups
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].dateLabel, "17/11/25")
        XCTAssertEqual(result[0].exercises.count, 1)
    }
    
    func testParseDateISOFormat() {
        let input = """
        2025-11-17
        3x10 pull ups
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].dateLabel, "2025-11-17")
        XCTAssertEqual(result[0].exercises.count, 1)
    }
    
    func testParseDateMonthFormat() {
        let input = """
        17 Nov
        3x10 pull ups
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].dateLabel, "17 Nov")
        XCTAssertEqual(result[0].exercises.count, 1)
    }
    
    // MARK: - Exercise Extraction Tests
    
    func testParseMultipleExercisesUnderOneDay() {
        let input = """
        Day 1
        3x10 pull ups
        3x10 dips
        5k run
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].exercises.count, 3)
    }
    
    func testParseMultipleDays() {
        let input = """
        Day 1
        3x10 pull ups
        
        Day 2
        4x8 bench press
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].dateLabel, "Day 1")
        XCTAssertEqual(result[0].exercises.count, 1)
        XCTAssertEqual(result[1].dateLabel, "Day 2")
        XCTAssertEqual(result[1].exercises.count, 1)
    }
    
    func testIgnoreCommentaryLines() {
        let input = """
        Day 1
        felt tired today
        3x10 pull ups
        did some mobility work
        5k run
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].exercises.count, 2)
    }
    
    // MARK: - Set/Rep Parsing Tests
    
    func testParseStrengthSetsNoSpaces() {
        let input = """
        Day 1
        3x10 pull ups
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 3)
        XCTAssertEqual(exercise.reps, 10)
        XCTAssertEqual(exercise.movement, "pull ups")
        XCTAssertEqual(exercise.rawText, "3x10 pull ups")
        XCTAssertNil(exercise.quantity)
        XCTAssertNil(exercise.unit)
    }
    
    func testParseStrengthSetsWithSpaces() {
        let input = """
        Day 1
        4 x 8 bench press
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 4)
        XCTAssertEqual(exercise.reps, 8)
        XCTAssertEqual(exercise.movement, "bench press")
        XCTAssertEqual(exercise.rawText, "4 x 8 bench press")
    }
    
    func testParseStrengthSetsCompoundMovement() {
        let input = """
        Day 1
        5x5 back squats
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 5)
        XCTAssertEqual(exercise.reps, 5)
        XCTAssertEqual(exercise.movement, "back squats")
    }
    
    // MARK: - Cardio Parsing Tests
    
    func testParseCardioDistance() {
        let input = """
        Day 1
        5k run
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.quantity, 5.0)
        XCTAssertEqual(exercise.unit, "k")
        XCTAssertEqual(exercise.movement, "run")
        XCTAssertEqual(exercise.rawText, "5k run")
        XCTAssertNil(exercise.sets)
        XCTAssertNil(exercise.reps)
    }
    
    func testParseCardioDistanceKm() {
        let input = """
        Day 1
        3 km row
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.quantity, 3.0)
        XCTAssertEqual(exercise.unit, "km")
        XCTAssertEqual(exercise.movement, "row")
    }
    
    func testParseCardioTime() {
        let input = """
        Day 1
        30 min cycle
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.quantity, 30.0)
        XCTAssertEqual(exercise.unit, "min")
        XCTAssertEqual(exercise.movement, "cycle")
        XCTAssertEqual(exercise.rawText, "30 min cycle")
        XCTAssertNil(exercise.sets)
        XCTAssertNil(exercise.reps)
    }
    
    // MARK: - Bodyweight Reps Tests
    
    func testParseBodyweightReps() {
        let input = """
        Day 1
        50 push ups
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.reps, 50)
        XCTAssertEqual(exercise.movement, "push ups")
        XCTAssertEqual(exercise.rawText, "50 push ups")
        XCTAssertNil(exercise.sets)
        XCTAssertNil(exercise.quantity)
        XCTAssertNil(exercise.unit)
    }
    
    func testParseMaxReps() {
        let input = """
        Day 1
        max pull ups
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertNil(exercise.reps)
        XCTAssertEqual(exercise.movement, "pull ups")
        XCTAssertEqual(exercise.rawText, "max pull ups")
    }
    
    // MARK: - Complete Example Test
    
    func testParseCompleteExample() {
        let input = """
        Day 1
        3x10 pull ups
        3x10 dips
        5k run
        
        Day 2
        4x8 bench press
        30 min cycle
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result.count, 2)
        
        // Day 1
        XCTAssertEqual(result[0].dateLabel, "Day 1")
        XCTAssertEqual(result[0].exercises.count, 3)
        XCTAssertEqual(result[0].exercises[0].rawText, "3x10 pull ups")
        XCTAssertEqual(result[0].exercises[1].rawText, "3x10 dips")
        XCTAssertEqual(result[0].exercises[2].rawText, "5k run")
        
        // Day 2
        XCTAssertEqual(result[1].dateLabel, "Day 2")
        XCTAssertEqual(result[1].exercises.count, 2)
        XCTAssertEqual(result[1].exercises[0].rawText, "4x8 bench press")
        XCTAssertEqual(result[1].exercises[1].rawText, "30 min cycle")
    }
    
    func testEmptyInput() {
        let input = ""
        let result = parser.parse(input)
        XCTAssertEqual(result.count, 0)
    }
    
    func testOnlyDayHeaders() {
        let input = """
        Day 1
        Day 2
        """
        let result = parser.parse(input)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].exercises.count, 0)
        XCTAssertEqual(result[1].exercises.count, 0)
    }
}
