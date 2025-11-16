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
        workoutDays = parser.parse(inputText)
        isParsed = !workoutDays.isEmpty
        updateGoalCompletion()
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
}
