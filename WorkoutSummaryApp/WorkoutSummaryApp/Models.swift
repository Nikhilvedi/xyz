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
    let unit: String? // e.g. "k", "km", "min"
    let movement: String
}
