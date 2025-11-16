//
//  Models.swift
//  WorkoutSummaryApp
//
//  Data models for workout tracking
//

import Foundation

struct WorkoutDay: Identifiable {
    let id = UUID()
    let dateLabel: String  // e.g. "Day 1", "Monday", "17/11/25"
    var exercises: [Exercise]
}

struct Exercise: Identifiable {
    let id = UUID()
    let rawText: String
    let sets: Int?
    let reps: Int?
    let quantity: Double?
    let unit: String? // e.g. "k", "km", "min", "mi"
    let movement: String
    let weight: Double?     // Weight/load (e.g., 135 from "135lbs")
    let weightUnit: String? // "lbs", "kg"
    let restTime: Int?      // Rest time in seconds
    let tempo: String?      // Tempo/pace (e.g., "5:30/km")
    let rpe: Int?          // Rate of Perceived Exertion (1-10)
    let notes: String?     // Additional notes
    
    init(rawText: String, sets: Int? = nil, reps: Int? = nil, 
         quantity: Double? = nil, unit: String? = nil, movement: String,
         weight: Double? = nil, weightUnit: String? = nil,
         restTime: Int? = nil, tempo: String? = nil, 
         rpe: Int? = nil, notes: String? = nil) {
        self.id = UUID()
        self.rawText = rawText
        self.sets = sets
        self.reps = reps
        self.quantity = quantity
        self.unit = unit
        self.movement = movement
        self.weight = weight
        self.weightUnit = weightUnit
        self.restTime = restTime
        self.tempo = tempo
        self.rpe = rpe
        self.notes = notes
    }
}
