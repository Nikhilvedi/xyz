//
//  WorkoutGoal.swift
//  WorkoutSummaryApp
//
//  Models for workout goals and tracking
//

import Foundation

// MARK: - Goal Types

enum GoalType: String, Codable, CaseIterable {
    case strength = "Strength"
    case cardioDistance = "Cardio (Distance)"
    case cardioTime = "Cardio (Time)"
    case bodyweight = "Bodyweight"
    
    var icon: String {
        switch self {
        case .strength: return "💪"
        case .cardioDistance: return "🏃"
        case .cardioTime: return "⏱️"
        case .bodyweight: return "🤸"
        }
    }
}

// MARK: - Workout Goal

struct WorkoutGoal: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: GoalType
    var targetValue: Double // sets, reps, distance, or time
    var targetUnit: String? // "sets", "reps", "k", "km", "min"
    var frequency: Int // times per week
    var isCompleted: Bool
    var completedCount: Int
    
    init(id: UUID = UUID(), name: String, type: GoalType, targetValue: Double, targetUnit: String? = nil, frequency: Int = 1) {
        self.id = id
        self.name = name
        self.type = type
        self.targetValue = targetValue
        self.targetUnit = targetUnit
        self.frequency = frequency
        self.isCompleted = false
        self.completedCount = 0
    }
    
    var displayTarget: String {
        let valueStr = targetValue.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(targetValue)) : String(targetValue)
        
        if let unit = targetUnit {
            return "\(valueStr)\(unit)"
        }
        return valueStr
    }
    
    var progressPercentage: Double {
        guard frequency > 0 else { return 0 }
        return min(Double(completedCount) / Double(frequency), 1.0)
    }
}

// MARK: - Goal Matcher

class GoalMatcher {
    
    // Check if an exercise matches a goal
    static func matches(exercise: Exercise, goal: WorkoutGoal) -> Bool {
        let exerciseLower = exercise.movement.lowercased()
        let goalLower = goal.name.lowercased()
        
        // Check if exercise name contains goal name
        if !exerciseLower.contains(goalLower) && !goalLower.contains(exerciseLower) {
            // Try to match keywords
            let exerciseWords = exerciseLower.components(separatedBy: .whitespaces)
            let goalWords = goalLower.components(separatedBy: .whitespaces)
            
            var hasMatch = false
            for goalWord in goalWords {
                if exerciseWords.contains(where: { $0.contains(goalWord) || goalWord.contains($0) }) {
                    hasMatch = true
                    break
                }
            }
            
            if !hasMatch {
                return false
            }
        }
        
        // Verify type matches
        switch goal.type {
        case .strength:
            return exercise.sets != nil && exercise.reps != nil
            
        case .cardioDistance:
            return (exercise.unit == "k" || exercise.unit == "km") && exercise.quantity != nil
            
        case .cardioTime:
            return exercise.unit == "min" && exercise.quantity != nil
            
        case .bodyweight:
            return exercise.reps != nil && exercise.sets == nil
        }
    }
    
    // Check if exercise meets goal target
    static func meetsTarget(exercise: Exercise, goal: WorkoutGoal) -> Bool {
        guard matches(exercise: exercise, goal: goal) else { return false }
        
        switch goal.type {
        case .strength:
            if let sets = exercise.sets, let reps = exercise.reps {
                let totalVolume = Double(sets * reps)
                return totalVolume >= goal.targetValue
            }
            return false
            
        case .cardioDistance:
            if let quantity = exercise.quantity {
                // Normalize to km
                let distance = exercise.unit == "k" ? quantity : quantity
                return distance >= goal.targetValue
            }
            return false
            
        case .cardioTime:
            if let quantity = exercise.quantity {
                return quantity >= goal.targetValue
            }
            return false
            
        case .bodyweight:
            if let reps = exercise.reps {
                return Double(reps) >= goal.targetValue
            }
            return false
        }
    }
    
    // Update goal completion based on workout days
    static func updateGoalCompletion(goals: [WorkoutGoal], workoutDays: [WorkoutDay]) -> [WorkoutGoal] {
        var updatedGoals = goals
        
        for i in 0..<updatedGoals.count {
            var completedCount = 0
            
            for day in workoutDays {
                var dayCompleted = false
                
                for exercise in day.exercises {
                    if meetsTarget(exercise: exercise, goal: updatedGoals[i]) {
                        dayCompleted = true
                        break
                    }
                }
                
                if dayCompleted {
                    completedCount += 1
                }
            }
            
            updatedGoals[i].completedCount = completedCount
            updatedGoals[i].isCompleted = completedCount >= updatedGoals[i].frequency
        }
        
        return updatedGoals
    }
}
