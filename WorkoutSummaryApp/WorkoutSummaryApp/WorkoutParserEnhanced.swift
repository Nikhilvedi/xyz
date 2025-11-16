//
//  WorkoutParserEnhanced.swift
//  WorkoutSummaryApp
//
//  Enhanced parser with advanced parsing capabilities:
//  - Weight/load parsing (e.g., "3x10 @ 135lbs")
//  - Superset support (e.g., "3x10 pull ups + 3x10 dips")
//  - Rest time parsing (e.g., "3x10 (90s rest)")
//  - Miles support (e.g., "3 mi run")
//  - Tempo/pace parsing (e.g., "5k @ 5:30/km")
//  - RPE support (e.g., "3x10 @ RPE 8")
//  - Natural language (e.g., "ran 5k", "did 3 sets of 10 pull ups")
//

import Foundation

extension WorkoutParser {
    
    // MARK: - Natural Language Parsing
    
    func parseNaturalLanguage(_ line: String) -> Exercise? {
        // Pattern: "ran 5k" or "ran 5 km" or "cycled 10 mi"
        if let match = try? NSRegularExpression(
            pattern: #"^(ran|cycled|swam|rowed|walked|hiked)\s+(\d+(?:\.\d+)?)\s*(k|km|mi|miles?)(?:\s+@\s+(.+))?$"#,
            options: .caseInsensitive
        ).firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
            
            guard let activityRange = Range(match.range(at: 1), in: line),
                  let quantityRange = Range(match.range(at: 2), in: line),
                  let unitRange = Range(match.range(at: 3), in: line) else {
                return nil
            }
            
            let activity = String(line[activityRange]).lowercased()
            let quantity = Double(line[quantityRange])
            var unit = String(line[unitRange]).lowercased()
            
            // Extract tempo if present
            var tempo: String? = nil
            if match.range(at: 4).location != NSNotFound,
               let tempoRange = Range(match.range(at: 4), in: line) {
                tempo = String(line[tempoRange]).trimmingCharacters(in: .whitespaces)
            }
            
            // Normalize units
            if unit == "miles" || unit == "mile" {
                unit = "mi"
            }
            
            // Map activity to movement
            let movement: String
            switch activity {
            case "ran": movement = "run"
            case "cycled": movement = "cycle"
            case "swam": movement = "swim"
            case "rowed": movement = "row"
            case "walked": movement = "walk"
            case "hiked": movement = "hike"
            default: movement = activity
            }
            
            return Exercise(
                rawText: line,
                quantity: quantity,
                unit: unit,
                movement: movement,
                tempo: tempo
            )
        }
        
        // Pattern: "did 3 sets of 10 pull ups" or "did 3 sets of 10 pull ups @ 135lbs"
        if let match = try? NSRegularExpression(
            pattern: #"^did\s+(\d+)\s+sets?\s+of\s+(\d+)\s+(.+?)(?:\s+@\s+(\d+(?:\.\d+)?)\s*(lbs?|kgs?|kg))?$"#,
            options: .caseInsensitive
        ).firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
            
            guard let setsRange = Range(match.range(at: 1), in: line),
                  let repsRange = Range(match.range(at: 2), in: line),
                  let movementRange = Range(match.range(at: 3), in: line) else {
                return nil
            }
            
            let sets = Int(line[setsRange])
            let reps = Int(line[repsRange])
            let movement = String(line[movementRange]).trimmingCharacters(in: .whitespaces)
            
            // Extract weight if present
            var weight: Double? = nil
            var weightUnit: String? = nil
            if match.range(at: 4).location != NSNotFound,
               let weightRange = Range(match.range(at: 4), in: line),
               let weightUnitRange = Range(match.range(at: 5), in: line) {
                weight = Double(line[weightRange])
                weightUnit = String(line[weightUnitRange]).lowercased()
                if weightUnit == "lb" {
                    weightUnit = "lbs"
                }
            }
            
            return Exercise(
                rawText: line,
                sets: sets,
                reps: reps,
                movement: movement,
                weight: weight,
                weightUnit: weightUnit
            )
        }
        
        return nil
    }
    
    // MARK: - Enhanced Strength Sets Parsing
    
    func parseStrengthSetsEnhanced(_ line: String) -> Exercise? {
        // Pattern: 3x10 pull ups @ 135lbs (90s rest) RPE 8
        // Captures: sets, reps, movement, weight, rest, RPE
        let pattern = #"^(\d+)\s*x\s*(\d+)\s+(.+?)(?:\s+@\s+(\d+(?:\.\d+)?)\s*(lbs?|kgs?|kg))?(?:\s+\((\d+)s?\s*rest\))?(?:\s+@?\s*RPE\s+(\d+))?$"#
        
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
        
        // Extract weight if present
        var weight: Double? = nil
        var weightUnit: String? = nil
        if match.range(at: 4).location != NSNotFound,
           let weightRange = Range(match.range(at: 4), in: line),
           let weightUnitRange = Range(match.range(at: 5), in: line) {
            weight = Double(line[weightRange])
            weightUnit = String(line[weightUnitRange]).lowercased()
            if weightUnit == "lb" {
                weightUnit = "lbs"
            }
        }
        
        // Extract rest time if present
        var restTime: Int? = nil
        if match.range(at: 6).location != NSNotFound,
           let restRange = Range(match.range(at: 6), in: line) {
            restTime = Int(line[restRange])
        }
        
        // Extract RPE if present
        var rpe: Int? = nil
        if match.range(at: 7).location != NSNotFound,
           let rpeRange = Range(match.range(at: 7), in: line) {
            rpe = Int(line[rpeRange])
        }
        
        return Exercise(
            rawText: line,
            sets: sets,
            reps: reps,
            movement: movement,
            weight: weight,
            weightUnit: weightUnit,
            restTime: restTime,
            rpe: rpe
        )
    }
    
    // MARK: - Enhanced Cardio Parsing
    
    func parseCardioEnhanced(_ line: String) -> Exercise? {
        // Pattern 1: Distance with optional tempo (e.g., "5k run @ 5:30/km" or "3 mi run")
        let distancePattern = #"^(\d+(?:\.\d+)?)\s*(k|km|mi|miles?)\s+(.+?)(?:\s+@\s+(.+))?$"#
        if let regex = try? NSRegularExpression(pattern: distancePattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
            
            guard let quantityRange = Range(match.range(at: 1), in: line),
                  let unitRange = Range(match.range(at: 2), in: line),
                  let movementRange = Range(match.range(at: 3), in: line) else {
                return nil
            }
            
            let quantity = Double(line[quantityRange])
            var unit = String(line[unitRange]).lowercased()
            let movement = String(line[movementRange]).trimmingCharacters(in: .whitespaces)
            
            // Normalize unit
            if unit == "miles" || unit == "mile" {
                unit = "mi"
            }
            
            // Extract tempo if present
            var tempo: String? = nil
            if match.range(at: 4).location != NSNotFound,
               let tempoRange = Range(match.range(at: 4), in: line) {
                tempo = String(line[tempoRange]).trimmingCharacters(in: .whitespaces)
            }
            
            return Exercise(
                rawText: line,
                quantity: quantity,
                unit: unit,
                movement: movement,
                tempo: tempo
            )
        }
        
        // Pattern 2: Time with optional intensity (e.g., "30 min cycle @ RPE 7")
        let timePattern = #"^(\d+(?:\.\d+)?)\s*min\s+(.+?)(?:\s+@\s*RPE\s+(\d+))?$"#
        if let regex = try? NSRegularExpression(pattern: timePattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
            
            guard let quantityRange = Range(match.range(at: 1), in: line),
                  let movementRange = Range(match.range(at: 2), in: line) else {
                return nil
            }
            
            let quantity = Double(line[quantityRange])
            let movement = String(line[movementRange]).trimmingCharacters(in: .whitespaces)
            
            // Extract RPE if present
            var rpe: Int? = nil
            if match.range(at: 3).location != NSNotFound,
               let rpeRange = Range(match.range(at: 3), in: line) {
                rpe = Int(line[rpeRange])
            }
            
            return Exercise(
                rawText: line,
                quantity: quantity,
                unit: "min",
                movement: movement,
                rpe: rpe
            )
        }
        
        return nil
    }
}
