//
//  WorkoutParser.swift
//  WorkoutSummaryApp
//
//  Parser to extract workout data from text
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
            } else if let exercise = parseExercise(trimmedLine) {
                // Add exercise to current day
                currentDay?.exercises.append(exercise)
            }
            // Ignore lines that don't match patterns (commentary, etc.)
        }
        
        // Add the last day
        if let day = currentDay {
            workoutDays.append(day)
        }
        
        return workoutDays
    }
    
    // MARK: - Day header parsing
    
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
        // Try strength sets pattern first: "3x10 pull ups" or "4 x 8 bench press"
        if let exercise = parseStrengthSets(line) {
            return exercise
        }
        
        // Try cardio pattern: "5k run", "30 min cycle"
        if let exercise = parseCardio(line) {
            return exercise
        }
        
        // Try bodyweight reps: "50 push ups", "max pull ups"
        if let exercise = parseBodyweightReps(line) {
            return exercise
        }
        
        return nil
    }
    
    // MARK: - Strength sets parsing
    
    private func parseStrengthSets(_ line: String) -> Exercise? {
        // Pattern: 3x10 or 3 x 10
        let pattern = #"^(\d+)\s*x\s*(\d+)\s+(.+)$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }
        
        guard let setsRange = Range(match.range(at: 1), in: line),
              let repsRange = Range(match.range(at: 2), in: line),
              let movementRange = Range(match.range(at: 3), in: line) else {
            return nil
        }
        
        let sets = Int(line[setsRange])
        let reps = Int(line[repsRange])
        let movement = String(line[movementRange]).trimmingCharacters(in: .whitespaces)
        
        return Exercise(
            rawText: line,
            sets: sets,
            reps: reps,
            quantity: nil,
            unit: nil,
            movement: movement
        )
    }
    
    // MARK: - Cardio parsing
    
    private func parseCardio(_ line: String) -> Exercise? {
        // Pattern 1: Distance (e.g., "5k run", "3 km row")
        let distancePattern = #"^(\d+(?:\.\d+)?)\s*(k|km)\s+(.+)$"#
        if let regex = try? NSRegularExpression(pattern: distancePattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
            
            guard let quantityRange = Range(match.range(at: 1), in: line),
                  let unitRange = Range(match.range(at: 2), in: line),
                  let movementRange = Range(match.range(at: 3), in: line) else {
                return nil
            }
            
            let quantity = Double(line[quantityRange])
            let unit = String(line[unitRange]).lowercased()
            let movement = String(line[movementRange]).trimmingCharacters(in: .whitespaces)
            
            return Exercise(
                rawText: line,
                sets: nil,
                reps: nil,
                quantity: quantity,
                unit: unit,
                movement: movement
            )
        }
        
        // Pattern 2: Time (e.g., "30 min cycle")
        let timePattern = #"^(\d+(?:\.\d+)?)\s*min\s+(.+)$"#
        if let regex = try? NSRegularExpression(pattern: timePattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
            
            guard let quantityRange = Range(match.range(at: 1), in: line),
                  let movementRange = Range(match.range(at: 2), in: line) else {
                return nil
            }
            
            let quantity = Double(line[quantityRange])
            let movement = String(line[movementRange]).trimmingCharacters(in: .whitespaces)
            
            return Exercise(
                rawText: line,
                sets: nil,
                reps: nil,
                quantity: quantity,
                unit: "min",
                movement: movement
            )
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
            sets: nil,
            reps: reps,
            quantity: nil,
            unit: nil,
            movement: movement
        )
    }
}
