//
//  WorkoutParser.swift
//  WorkoutSummaryApp
//
//  Enhanced parser to extract workout data from text
//  Supports: strength sets, cardio, bodyweight, weights, rest times, RPE, supersets, and more
//

import Foundation

class WorkoutParser {
    
    // MARK: - Main parsing method
    
    func parse(_ text: String) -> [WorkoutDay] {
        var workoutDays: [WorkoutDay] = []
        let lines = text.components(separatedBy: .newlines)
        
        var currentDay: WorkoutDay?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines
            if trimmedLine.isEmpty {
                continue
            }
            
            // Check if this is a day header
            if let dayLabel = parseDayHeader(trimmedLine) {
                // Save previous day if exists
                if let day = currentDay {
                    workoutDays.append(day)
                }
                // Start new day
                currentDay = WorkoutDay(dateLabel: dayLabel, exercises: [])
            } else if let exercises = parseExerciseLine(trimmedLine) {
                // Add exercise(s) to current day (supports supersets)
                currentDay?.exercises.append(contentsOf: exercises)
            }
            // Ignore lines that don't match patterns (commentary, etc.)
        }
        
        // Add the last day
        if let day = currentDay {
            workoutDays.append(day)
        }
        
        return workoutDays
    }
    
    // MARK: - Exercise line parsing (handles supersets)
    
    private func parseExerciseLine(_ line: String) -> [Exercise]? {
        // Check for superset pattern: "3x10 pull ups + 3x10 dips"
        if line.contains("+") {
            let parts = line.components(separatedBy: "+")
            var exercises: [Exercise] = []
            
            for part in parts {
                let trimmed = part.trimmingCharacters(in: .whitespaces)
                if let exercise = parseExercise(trimmed) {
                    exercises.append(exercise)
                }
            }
            
            return exercises.isEmpty ? nil : exercises
        }
        
        // Single exercise
        if let exercise = parseExercise(line) {
            return [exercise]
        }
        
        return nil
    }
    
    private func parseDayHeader(_ line: String) -> String? {
        let lowercased = line.lowercased()
        
        // Pattern 1: "Day 1", "Day 2", etc.
        if let match = line.range(of: #"^day\s+\d+$"#, options: [.regularExpression, .caseInsensitive]) {
            return String(line[match])
        }
        
        // Pattern 2: Weekday names (full or abbreviated)
        let weekdays = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday",
                       "mon", "tue", "wed", "thu", "fri", "sat", "sun"]
        for weekday in weekdays {
            if lowercased == weekday {
                return line
            }
        }
        
        // Pattern 3: Dates in various formats
        // DD/MM/YY or DD/MM/YYYY
        if line.range(of: #"^\d{1,2}/\d{1,2}/\d{2,4}$"#, options: .regularExpression) != nil {
            return line
        }
        
        // YYYY-MM-DD (ISO format)
        if line.range(of: #"^\d{4}-\d{1,2}-\d{1,2}$"#, options: .regularExpression) != nil {
            return line
        }
        
        // DD Mon or DD Month (e.g., "17 Nov", "17 November")
        if line.range(of: #"^\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|January|February|March|April|May|June|July|August|September|October|November|December)"#, options: [.regularExpression, .caseInsensitive]) != nil {
            return line
        }
        
        return nil
    }
    
    // MARK: - Exercise parsing
    
    private func parseExercise(_ line: String) -> Exercise? {
        // Try natural language patterns first: "ran 5k", "did 3 sets of 10 pull ups"
        if let exercise = parseNaturalLanguage(line) {
            return exercise
        }
        
        // Try enhanced strength sets pattern: "3x10 pull ups @ 135lbs (90s rest) RPE 8"
        if let exercise = parseStrengthSetsEnhanced(line) {
            return exercise
        }
        
        // Try enhanced cardio pattern: "5k run @ 5:30/km", "30 min cycle @ RPE 7", "3 mi run"
        if let exercise = parseCardioEnhanced(line) {
            return exercise
        }
        
        // Try bodyweight reps: "50 push ups", "max pull ups"
        if let exercise = parseBodyweightReps(line) {
            return exercise
        }
        
        return nil
    }
    
    // MARK: - Bodyweight reps parsing
    
    private func parseBodyweightReps(_ line: String) -> Exercise? {
        // Pattern: "50 push ups" or "max pull ups"
        let pattern = #"^(\d+|max)\s+(.+)$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }
        
        guard let repsRange = Range(match.range(at: 1), in: line),
              let movementRange = Range(match.range(at: 2), in: line) else {
            return nil
        }
        
        let repsString = String(line[repsRange]).lowercased()
        let reps = repsString == "max" ? nil : Int(repsString)
        let movement = String(line[movementRange]).trimmingCharacters(in: .whitespaces)
        
        return Exercise(
            rawText: line,
            reps: reps,
            movement: movement
        )
    }
}
