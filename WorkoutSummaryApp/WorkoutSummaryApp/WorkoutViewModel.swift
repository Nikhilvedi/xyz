//
//  WorkoutViewModel.swift
//  WorkoutSummaryApp
//
//  ViewModel for managing workout data and parsing
//

import Foundation
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var workoutDays: [WorkoutDay] = []
    @Published var isParsed: Bool = false
    @Published var weeklyGoals: [WorkoutGoal] = [] {
        didSet {
            saveGoals()
            updateGoalCompletion()
        }
    }
    
    private let parser = WorkoutParser()
    private let goalsKey = "weeklyGoals"
    
    init() {
        loadGoals()
    }
    
    func parseWorkout() {
        let previousGoals = weeklyGoals
        
        workoutDays = parser.parse(inputText)
        isParsed = !workoutDays.isEmpty
        updateGoalCompletion()
        
        // Check for newly completed goals and send notifications
        checkForCompletedGoals(previous: previousGoals, current: weeklyGoals)
    }
    
    func clearAll() {
        inputText = ""
        workoutDays = []
        isParsed = false
    }
    
    func loadSharedText(_ text: String) {
        inputText = text
    }
    
    // MARK: - Goals Management
    
    private func updateGoalCompletion() {
        weeklyGoals = GoalMatcher.updateGoalCompletion(goals: weeklyGoals, workoutDays: workoutDays)
    }
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(weeklyGoals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }
    
    private func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([WorkoutGoal].self, from: data) {
            weeklyGoals = decoded
        }
    }
    
    func resetWeeklyGoals() {
        for i in 0..<weeklyGoals.count {
            weeklyGoals[i].completedCount = 0
            weeklyGoals[i].isCompleted = false
        }
    }
    
    // MARK: - Notification Handling
    
    private func checkForCompletedGoals(previous: [WorkoutGoal], current: [WorkoutGoal]) {
        for (index, currentGoal) in current.enumerated() {
            // Find matching previous goal
            if index < previous.count {
                let previousGoal = previous[index]
                
                // Check if goal was just completed
                if !previousGoal.isCompleted && currentGoal.isCompleted {
                    NotificationManager.shared.scheduleGoalCompletionNotification(goalName: currentGoal.name)
                }
            }
        }
    }
}
