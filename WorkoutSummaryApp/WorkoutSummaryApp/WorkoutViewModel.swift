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
    
    private let parser = WorkoutParser()
    
    func parseWorkout() {
        workoutDays = parser.parse(inputText)
        isParsed = !workoutDays.isEmpty
    }
    
    func clearAll() {
        inputText = ""
        workoutDays = []
        isParsed = false
    }
    
    func loadSharedText(_ text: String) {
        inputText = text
    }
}
