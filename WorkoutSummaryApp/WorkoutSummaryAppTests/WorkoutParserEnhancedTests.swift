//
//  WorkoutParserEnhancedTests.swift
//  WorkoutSummaryAppTests
//
//  Unit tests for enhanced workout parser features
//

import XCTest
@testable import WorkoutSummaryApp

class WorkoutParserEnhancedTests: XCTestCase {
    
    var parser: WorkoutParser!
    
    override func setUp() {
        super.setUp()
        parser = WorkoutParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    // MARK: - Weight/Load Parsing Tests
    
    func testParseStrengthWithWeight() {
        let input = """
        Day 1
        3x10 bench press @ 135lbs
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 3)
        XCTAssertEqual(exercise.reps, 10)
        XCTAssertEqual(exercise.movement, "bench press")
        XCTAssertEqual(exercise.weight, 135.0)
        XCTAssertEqual(exercise.weightUnit, "lbs")
    }
    
    func testParseStrengthWithWeightKg() {
        let input = """
        Day 1
        4x8 squat @ 100kg
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 4)
        XCTAssertEqual(exercise.reps, 8)
        XCTAssertEqual(exercise.movement, "squat")
        XCTAssertEqual(exercise.weight, 100.0)
        XCTAssertEqual(exercise.weightUnit, "kg")
    }
    
    // MARK: - Rest Time Parsing Tests
    
    func testParseStrengthWithRestTime() {
        let input = """
        Day 1
        3x10 pull ups (90s rest)
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 3)
        XCTAssertEqual(exercise.reps, 10)
        XCTAssertEqual(exercise.movement, "pull ups")
        XCTAssertEqual(exercise.restTime, 90)
    }
    
    func testParseStrengthWithWeightAndRest() {
        let input = """
        Day 1
        5x5 deadlift @ 225lbs (180s rest)
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 5)
        XCTAssertEqual(exercise.reps, 5)
        XCTAssertEqual(exercise.movement, "deadlift")
        XCTAssertEqual(exercise.weight, 225.0)
        XCTAssertEqual(exercise.weightUnit, "lbs")
        XCTAssertEqual(exercise.restTime, 180)
    }
    
    // MARK: - RPE Parsing Tests
    
    func testParseStrengthWithRPE() {
        let input = """
        Day 1
        3x10 bench press @ RPE 8
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 3)
        XCTAssertEqual(exercise.reps, 10)
        XCTAssertEqual(exercise.movement, "bench press")
        XCTAssertEqual(exercise.rpe, 8)
    }
    
    func testParseStrengthWithWeightAndRPE() {
        let input = """
        Day 1
        4x6 squat @ 185lbs RPE 9
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 4)
        XCTAssertEqual(exercise.reps, 6)
        XCTAssertEqual(exercise.movement, "squat")
        XCTAssertEqual(exercise.weight, 185.0)
        XCTAssertEqual(exercise.weightUnit, "lbs")
        XCTAssertEqual(exercise.rpe, 9)
    }
    
    func testParseCardioWithRPE() {
        let input = """
        Day 1
        30 min cycle @ RPE 7
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.quantity, 30.0)
        XCTAssertEqual(exercise.unit, "min")
        XCTAssertEqual(exercise.movement, "cycle")
        XCTAssertEqual(exercise.rpe, 7)
    }
    
    // MARK: - Superset Parsing Tests
    
    func testParseSupersetSimple() {
        let input = """
        Day 1
        3x10 pull ups + 3x10 dips
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result[0].exercises.count, 2)
        
        let exercise1 = result[0].exercises[0]
        XCTAssertEqual(exercise1.sets, 3)
        XCTAssertEqual(exercise1.reps, 10)
        XCTAssertEqual(exercise1.movement, "pull ups")
        
        let exercise2 = result[0].exercises[1]
        XCTAssertEqual(exercise2.sets, 3)
        XCTAssertEqual(exercise2.reps, 10)
        XCTAssertEqual(exercise2.movement, "dips")
    }
    
    func testParseSupersetWithWeight() {
        let input = """
        Day 1
        4x8 bench press @ 135lbs + 4x8 rows @ 100lbs
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result[0].exercises.count, 2)
        
        let exercise1 = result[0].exercises[0]
        XCTAssertEqual(exercise1.sets, 4)
        XCTAssertEqual(exercise1.reps, 8)
        XCTAssertEqual(exercise1.movement, "bench press")
        XCTAssertEqual(exercise1.weight, 135.0)
        
        let exercise2 = result[0].exercises[1]
        XCTAssertEqual(exercise2.sets, 4)
        XCTAssertEqual(exercise2.reps, 8)
        XCTAssertEqual(exercise2.movement, "rows")
        XCTAssertEqual(exercise2.weight, 100.0)
    }
    
    // MARK: - Miles Support Tests
    
    func testParseCardioMiles() {
        let input = """
        Day 1
        3 mi run
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.quantity, 3.0)
        XCTAssertEqual(exercise.unit, "mi")
        XCTAssertEqual(exercise.movement, "run")
    }
    
    func testParseCardioMilesDecimal() {
        let input = """
        Day 1
        5.5 miles cycle
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.quantity, 5.5)
        XCTAssertEqual(exercise.unit, "mi")
        XCTAssertEqual(exercise.movement, "cycle")
    }
    
    // MARK: - Tempo/Pace Parsing Tests
    
    func testParseCardioWithTempo() {
        let input = """
        Day 1
        5k run @ 5:30/km
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.quantity, 5.0)
        XCTAssertEqual(exercise.unit, "k")
        XCTAssertEqual(exercise.movement, "run")
        XCTAssertEqual(exercise.tempo, "5:30/km")
    }
    
    func testParseCardioMilesWithPace() {
        let input = """
        Day 1
        3 mi run @ 8:00/mi
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.quantity, 3.0)
        XCTAssertEqual(exercise.unit, "mi")
        XCTAssertEqual(exercise.movement, "run")
        XCTAssertEqual(exercise.tempo, "8:00/mi")
    }
    
    // MARK: - Natural Language Parsing Tests
    
    func testParseNaturalLanguageRan() {
        let input = """
        Day 1
        ran 5k
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.quantity, 5.0)
        XCTAssertEqual(exercise.unit, "k")
        XCTAssertEqual(exercise.movement, "run")
    }
    
    func testParseNaturalLanguageCycled() {
        let input = """
        Day 1
        cycled 10 mi
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.quantity, 10.0)
        XCTAssertEqual(exercise.unit, "mi")
        XCTAssertEqual(exercise.movement, "cycle")
    }
    
    func testParseNaturalLanguageSwam() {
        let input = """
        Day 1
        swam 2k
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.quantity, 2.0)
        XCTAssertEqual(exercise.unit, "k")
        XCTAssertEqual(exercise.movement, "swim")
    }
    
    func testParseNaturalLanguageDidSets() {
        let input = """
        Day 1
        did 3 sets of 10 pull ups
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 3)
        XCTAssertEqual(exercise.reps, 10)
        XCTAssertEqual(exercise.movement, "pull ups")
    }
    
    func testParseNaturalLanguageDidSetsWithWeight() {
        let input = """
        Day 1
        did 4 sets of 8 bench press @ 135lbs
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 4)
        XCTAssertEqual(exercise.reps, 8)
        XCTAssertEqual(exercise.movement, "bench press")
        XCTAssertEqual(exercise.weight, 135.0)
        XCTAssertEqual(exercise.weightUnit, "lbs")
    }
    
    // MARK: - Complex Workout Test
    
    func testParseComplexWorkout() {
        let input = """
        Day 1
        3x5 squat @ 225lbs (180s rest) RPE 9
        4x8 bench press @ 185lbs
        3x10 pull ups + 3x10 dips
        ran 5k @ 5:30/km
        
        Day 2
        did 4 sets of 6 deadlifts @ 275lbs
        30 min cycle @ RPE 7
        50 push ups
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result.count, 2)
        
        // Day 1
        XCTAssertEqual(result[0].exercises.count, 5) // 3 strength + 2 superset exercises + 1 cardio
        
        // Squat with all attributes
        let squat = result[0].exercises[0]
        XCTAssertEqual(squat.sets, 3)
        XCTAssertEqual(squat.reps, 5)
        XCTAssertEqual(squat.weight, 225.0)
        XCTAssertEqual(squat.restTime, 180)
        XCTAssertEqual(squat.rpe, 9)
        
        // Bench press
        let bench = result[0].exercises[1]
        XCTAssertEqual(bench.sets, 4)
        XCTAssertEqual(bench.reps, 8)
        XCTAssertEqual(bench.weight, 185.0)
        
        // Superset exercises
        let pullups = result[0].exercises[2]
        XCTAssertEqual(pullups.sets, 3)
        XCTAssertEqual(pullups.reps, 10)
        
        let dips = result[0].exercises[3]
        XCTAssertEqual(dips.sets, 3)
        XCTAssertEqual(dips.reps, 10)
        
        // Cardio with tempo
        let run = result[0].exercises[4]
        XCTAssertEqual(run.quantity, 5.0)
        XCTAssertEqual(run.tempo, "5:30/km")
        
        // Day 2
        XCTAssertEqual(result[1].exercises.count, 3)
        
        // Natural language
        let deadlift = result[1].exercises[0]
        XCTAssertEqual(deadlift.sets, 4)
        XCTAssertEqual(deadlift.reps, 6)
        XCTAssertEqual(deadlift.weight, 275.0)
        
        // Cardio with RPE
        let cycle = result[1].exercises[1]
        XCTAssertEqual(cycle.quantity, 30.0)
        XCTAssertEqual(cycle.rpe, 7)
        
        // Bodyweight
        let pushups = result[1].exercises[2]
        XCTAssertEqual(pushups.reps, 50)
    }
    
    // MARK: - Backwards Compatibility Tests
    
    func testBackwardsCompatibilityStrengthSets() {
        let input = """
        Day 1
        3x10 pull ups
        """
        
        let result = parser.parse(input)
        let exercise = result[0].exercises[0]
        
        XCTAssertEqual(exercise.sets, 3)
        XCTAssertEqual(exercise.reps, 10)
        XCTAssertEqual(exercise.movement, "pull ups")
    }
    
    func testBackwardsCompatibilityCardio() {
        let input = """
        Day 1
        5k run
        30 min cycle
        """
        
        let result = parser.parse(input)
        
        XCTAssertEqual(result[0].exercises.count, 2)
        XCTAssertEqual(result[0].exercises[0].quantity, 5.0)
        XCTAssertEqual(result[0].exercises[1].quantity, 30.0)
    }
}
