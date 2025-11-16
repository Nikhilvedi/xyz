//
//  MuscleGroup.swift
//  WorkoutSummaryApp
//
//  Muscle group mapping and analysis
//

import Foundation
import SwiftUI

// MARK: - Muscle Groups

enum MuscleGroup: String, CaseIterable {
    case chest
    case shoulders
    case biceps
    case triceps
    case forearms
    case abs
    case obliques
    case upperBack
    case lowerBack
    case lats
    case quads
    case hamstrings
    case glutes
    case calves
    case cardio
    
    var displayName: String {
        switch self {
        case .upperBack: return "Upper Back"
        case .lowerBack: return "Lower Back"
        case .cardio: return "Cardio"
        default: return rawValue.capitalized
        }
    }
}

// MARK: - Muscle Mapper

class MuscleMapper {
    
    // Maps exercise keywords to muscle groups
    private static let exerciseMuscleMap: [String: [MuscleGroup]] = [
        // Chest
        "bench press": [.chest, .triceps, .shoulders],
        "push up": [.chest, .triceps, .shoulders],
        "push-up": [.chest, .triceps, .shoulders],
        "pushup": [.chest, .triceps, .shoulders],
        "chest press": [.chest, .triceps],
        "chest fly": [.chest],
        "dips": [.chest, .triceps],
        "dip": [.chest, .triceps],
        
        // Back
        "pull up": [.lats, .upperBack, .biceps],
        "pull-up": [.lats, .upperBack, .biceps],
        "pullup": [.lats, .upperBack, .biceps],
        "row": [.upperBack, .lats, .biceps],
        "deadlift": [.lowerBack, .glutes, .hamstrings, .upperBack],
        "lat pulldown": [.lats, .biceps],
        "back extension": [.lowerBack],
        
        // Shoulders
        "shoulder press": [.shoulders, .triceps],
        "overhead press": [.shoulders, .triceps],
        "lateral raise": [.shoulders],
        "front raise": [.shoulders],
        "rear delt": [.shoulders, .upperBack],
        
        // Arms
        "curl": [.biceps],
        "tricep": [.triceps],
        "triceps": [.triceps],
        
        // Legs
        "squat": [.quads, .glutes, .hamstrings],
        "lunge": [.quads, .glutes, .hamstrings],
        "leg press": [.quads, .glutes],
        "leg extension": [.quads],
        "leg curl": [.hamstrings],
        "calf raise": [.calves],
        
        // Core
        "plank": [.abs, .obliques],
        "crunch": [.abs],
        "sit up": [.abs],
        "sit-up": [.abs],
        "situp": [.abs],
        "russian twist": [.obliques, .abs],
        
        // Cardio
        "run": [.cardio],
        "cycle": [.cardio],
        "bike": [.cardio],
        "swim": [.cardio],
        "walk": [.cardio],
        "jog": [.cardio],
        "sprint": [.cardio],
    ]
    
    // Determine muscle groups worked by an exercise
    static func getMuscleGroups(for exercise: Exercise) -> [MuscleGroup] {
        let movementLower = exercise.movement.lowercased()
        
        // Check for exact matches or partial matches
        var matchedGroups: Set<MuscleGroup> = []
        
        for (keyword, groups) in exerciseMuscleMap {
            if movementLower.contains(keyword) {
                matchedGroups.formUnion(groups)
            }
        }
        
        return Array(matchedGroups)
    }
    
    // Calculate workout intensity for each muscle group
    static func calculateMuscleIntensity(for workoutDays: [WorkoutDay]) -> [MuscleGroup: Double] {
        var muscleWorkload: [MuscleGroup: Double] = [:]
        
        for day in workoutDays {
            for exercise in day.exercises {
                let muscles = getMuscleGroups(for: exercise)
                
                // Calculate workload based on exercise type
                var workload: Double = 1.0
                
                if let sets = exercise.sets, let reps = exercise.reps {
                    // Strength training: sets × reps gives volume
                    workload = Double(sets * reps) / 30.0 // Normalize by typical volume
                } else if let reps = exercise.reps {
                    // Bodyweight: just reps
                    workload = Double(reps) / 50.0 // Normalize
                } else if let quantity = exercise.quantity {
                    // Cardio: distance or time
                    workload = quantity / 10.0 // Normalize
                }
                
                // Cap workload at reasonable max
                workload = min(workload, 3.0)
                
                // Distribute workload across all targeted muscles
                let workloadPerMuscle = workload / Double(muscles.count)
                
                for muscle in muscles {
                    muscleWorkload[muscle, default: 0] += workloadPerMuscle
                }
            }
        }
        
        // Normalize to 0-1 range for heatmap
        if let maxWorkload = muscleWorkload.values.max(), maxWorkload > 0 {
            for muscle in muscleWorkload.keys {
                muscleWorkload[muscle]! = min(muscleWorkload[muscle]! / maxWorkload, 1.0)
            }
        }
        
        return muscleWorkload
    }
    
    // Get color for intensity level
    static func getColor(for intensity: Double) -> Color {
        if intensity == 0 {
            return Color.gray.opacity(0.2)
        } else if intensity < 0.3 {
            return Color.yellow.opacity(0.4)
        } else if intensity < 0.6 {
            return Color.orange.opacity(0.6)
        } else {
            return Color.red.opacity(0.8)
        }
    }
    
    // Get description for intensity level
    static func getIntensityDescription(for intensity: Double) -> String {
        if intensity == 0 {
            return "Not Targeted"
        } else if intensity < 0.3 {
            return "Light"
        } else if intensity < 0.6 {
            return "Moderate"
        } else {
            return "Heavy"
        }
    }
}
