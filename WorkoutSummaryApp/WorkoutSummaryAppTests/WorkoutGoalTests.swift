//
//  WorkoutGoalTests.swift
//  WorkoutSummaryAppTests
//
//  Unit tests for workout goals and tracking
//

import XCTest
@testable import WorkoutSummaryApp

class WorkoutGoalTests: XCTestCase {
    
    // MARK: - Goal Creation Tests
    
    func testGoalCreation() {
        let goal = WorkoutGoal(
            name: "pull ups",
            type: .strength,
            targetValue: 30,
            frequency: 3
        )
        
        XCTAssertEqual(goal.name, "pull ups")
        XCTAssertEqual(goal.type, .strength)
        XCTAssertEqual(goal.targetValue, 30)
        XCTAssertEqual(goal.frequency, 3)
        XCTAssertFalse(goal.isCompleted)
        XCTAssertEqual(goal.completedCount, 0)
    }
    
    func testGoalDisplayTarget() {
        let goal1 = WorkoutGoal(name: "run", type: .cardioDistance, targetValue: 5, targetUnit: "km", frequency: 2)
        XCTAssertEqual(goal1.displayTarget, "5km")
        
        let goal2 = WorkoutGoal(name: "pull ups", type: .strength, targetValue: 30, frequency: 3)
        XCTAssertEqual(goal2.displayTarget, "30")
    }
    
    func testGoalProgressPercentage() {
        var goal = WorkoutGoal(name: "run", type: .cardioDistance, targetValue: 5, targetUnit: "km", frequency: 4)
        
        XCTAssertEqual(goal.progressPercentage, 0.0)
        
        goal.completedCount = 2
        XCTAssertEqual(goal.progressPercentage, 0.5)
        
        goal.completedCount = 4
        XCTAssertEqual(goal.progressPercentage, 1.0)
        
        goal.completedCount = 6
        XCTAssertEqual(goal.progressPercentage, 1.0) // Should cap at 1.0
    }
    
    // MARK: - Goal Matching Tests
    
    func testStrengthExerciseMatching() {
        let goal = WorkoutGoal(name: "pull ups", type: .strength, targetValue: 30, frequency: 3)
        let exercise = Exercise(rawText: "3x10 pull ups", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "pull ups")
        
        XCTAssertTrue(GoalMatcher.matches(exercise: exercise, goal: goal))
    }
    
    func testCardioDistanceMatching() {
        let goal = WorkoutGoal(name: "run", type: .cardioDistance, targetValue: 5, targetUnit: "km", frequency: 2)
        let exercise = Exercise(rawText: "5k run", sets: nil, reps: nil, quantity: 5, unit: "k", movement: "run")
        
        XCTAssertTrue(GoalMatcher.matches(exercise: exercise, goal: goal))
    }
    
    func testCardioTimeMatching() {
        let goal = WorkoutGoal(name: "cycle", type: .cardioTime, targetValue: 30, targetUnit: "min", frequency: 3)
        let exercise = Exercise(rawText: "30 min cycle", sets: nil, reps: nil, quantity: 30, unit: "min", movement: "cycle")
        
        XCTAssertTrue(GoalMatcher.matches(exercise: exercise, goal: goal))
    }
    
    func testBodyweightMatching() {
        let goal = WorkoutGoal(name: "push ups", type: .bodyweight, targetValue: 50, frequency: 4)
        let exercise = Exercise(rawText: "50 push ups", sets: nil, reps: 50, quantity: nil, unit: nil, movement: "push ups")
        
        XCTAssertTrue(GoalMatcher.matches(exercise: exercise, goal: goal))
    }
    
    func testNoMatchWrongType() {
        let goal = WorkoutGoal(name: "run", type: .cardioDistance, targetValue: 5, targetUnit: "km", frequency: 2)
        let exercise = Exercise(rawText: "3x10 pull ups", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "pull ups")
        
        XCTAssertFalse(GoalMatcher.matches(exercise: exercise, goal: goal))
    }
    
    func testNoMatchWrongExercise() {
        let goal = WorkoutGoal(name: "pull ups", type: .strength, targetValue: 30, frequency: 3)
        let exercise = Exercise(rawText: "3x10 dips", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "dips")
        
        XCTAssertFalse(GoalMatcher.matches(exercise: exercise, goal: goal))
    }
    
    // MARK: - Target Meeting Tests
    
    func testMeetsTargetStrength() {
        let goal = WorkoutGoal(name: "pull ups", type: .strength, targetValue: 30, frequency: 3)
        
        let exercise1 = Exercise(rawText: "3x10 pull ups", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "pull ups")
        XCTAssertTrue(GoalMatcher.meetsTarget(exercise: exercise1, goal: goal))
        
        let exercise2 = Exercise(rawText: "2x10 pull ups", sets: 2, reps: 10, quantity: nil, unit: nil, movement: "pull ups")
        XCTAssertFalse(GoalMatcher.meetsTarget(exercise: exercise2, goal: goal))
        
        let exercise3 = Exercise(rawText: "5x10 pull ups", sets: 5, reps: 10, quantity: nil, unit: nil, movement: "pull ups")
        XCTAssertTrue(GoalMatcher.meetsTarget(exercise: exercise3, goal: goal))
    }
    
    func testMeetsTargetCardioDistance() {
        let goal = WorkoutGoal(name: "run", type: .cardioDistance, targetValue: 5, targetUnit: "km", frequency: 2)
        
        let exercise1 = Exercise(rawText: "5k run", sets: nil, reps: nil, quantity: 5, unit: "k", movement: "run")
        XCTAssertTrue(GoalMatcher.meetsTarget(exercise: exercise1, goal: goal))
        
        let exercise2 = Exercise(rawText: "3k run", sets: nil, reps: nil, quantity: 3, unit: "k", movement: "run")
        XCTAssertFalse(GoalMatcher.meetsTarget(exercise: exercise2, goal: goal))
    }
    
    func testMeetsTargetCardioTime() {
        let goal = WorkoutGoal(name: "cycle", type: .cardioTime, targetValue: 30, targetUnit: "min", frequency: 3)
        
        let exercise1 = Exercise(rawText: "30 min cycle", sets: nil, reps: nil, quantity: 30, unit: "min", movement: "cycle")
        XCTAssertTrue(GoalMatcher.meetsTarget(exercise: exercise1, goal: goal))
        
        let exercise2 = Exercise(rawText: "20 min cycle", sets: nil, reps: nil, quantity: 20, unit: "min", movement: "cycle")
        XCTAssertFalse(GoalMatcher.meetsTarget(exercise: exercise2, goal: goal))
    }
    
    func testMeetsTargetBodyweight() {
        let goal = WorkoutGoal(name: "push ups", type: .bodyweight, targetValue: 50, frequency: 4)
        
        let exercise1 = Exercise(rawText: "50 push ups", sets: nil, reps: 50, quantity: nil, unit: nil, movement: "push ups")
        XCTAssertTrue(GoalMatcher.meetsTarget(exercise: exercise1, goal: goal))
        
        let exercise2 = Exercise(rawText: "30 push ups", sets: nil, reps: 30, quantity: nil, unit: nil, movement: "push ups")
        XCTAssertFalse(GoalMatcher.meetsTarget(exercise: exercise2, goal: goal))
    }
    
    // MARK: - Goal Completion Tests
    
    func testUpdateGoalCompletion() {
        let goals = [
            WorkoutGoal(name: "pull ups", type: .strength, targetValue: 30, frequency: 2),
            WorkoutGoal(name: "run", type: .cardioDistance, targetValue: 5, targetUnit: "km", frequency: 1)
        ]
        
        let workoutDays = [
            WorkoutDay(dateLabel: "Day 1", exercises: [
                Exercise(rawText: "3x10 pull ups", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "pull ups"),
                Exercise(rawText: "5k run", sets: nil, reps: nil, quantity: 5, unit: "k", movement: "run")
            ]),
            WorkoutDay(dateLabel: "Day 2", exercises: [
                Exercise(rawText: "3x10 pull ups", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "pull ups")
            ])
        ]
        
        let updatedGoals = GoalMatcher.updateGoalCompletion(goals: goals, workoutDays: workoutDays)
        
        XCTAssertEqual(updatedGoals[0].completedCount, 2)
        XCTAssertTrue(updatedGoals[0].isCompleted)
        
        XCTAssertEqual(updatedGoals[1].completedCount, 1)
        XCTAssertTrue(updatedGoals[1].isCompleted)
    }
    
    func testUpdateGoalCompletionPartial() {
        let goals = [
            WorkoutGoal(name: "pull ups", type: .strength, targetValue: 30, frequency: 3)
        ]
        
        let workoutDays = [
            WorkoutDay(dateLabel: "Day 1", exercises: [
                Exercise(rawText: "3x10 pull ups", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "pull ups")
            ])
        ]
        
        let updatedGoals = GoalMatcher.updateGoalCompletion(goals: goals, workoutDays: workoutDays)
        
        XCTAssertEqual(updatedGoals[0].completedCount, 1)
        XCTAssertFalse(updatedGoals[0].isCompleted)
    }
    
    func testUpdateGoalCompletionNoMatch() {
        let goals = [
            WorkoutGoal(name: "squats", type: .strength, targetValue: 50, frequency: 2)
        ]
        
        let workoutDays = [
            WorkoutDay(dateLabel: "Day 1", exercises: [
                Exercise(rawText: "3x10 pull ups", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "pull ups")
            ])
        ]
        
        let updatedGoals = GoalMatcher.updateGoalCompletion(goals: goals, workoutDays: workoutDays)
        
        XCTAssertEqual(updatedGoals[0].completedCount, 0)
        XCTAssertFalse(updatedGoals[0].isCompleted)
    }
}
