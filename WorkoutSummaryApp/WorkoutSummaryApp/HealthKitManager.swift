//
//  HealthKitManager.swift
//  WorkoutSummaryApp
//
//  Manager for HealthKit integration and workout syncing
//

import Foundation
import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var healthKitEnabled = false {
        didSet {
            UserDefaults.standard.set(healthKitEnabled, forKey: "healthKitEnabled")
        }
    }
    
    @Published var autoSyncEnabled = false {
        didSet {
            UserDefaults.standard.set(autoSyncEnabled, forKey: "autoSyncEnabled")
        }
    }
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Settings
    
    private func loadSettings() {
        healthKitEnabled = UserDefaults.standard.bool(forKey: "healthKitEnabled")
        autoSyncEnabled = UserDefaults.standard.bool(forKey: "autoSyncEnabled")
    }
    
    // MARK: - Authorization
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let workoutType = HKObjectType.workoutType()
        
        // Types to read
        let typesToRead: Set<HKObjectType> = [
            workoutType,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .distanceSwimming)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    self.healthKitEnabled = true
                }
                completion(success, error)
            }
        }
    }
    
    func checkAuthorizationStatus() {
        let workoutType = HKObjectType.workoutType()
        let status = healthStore.authorizationStatus(for: workoutType)
        DispatchQueue.main.async {
            self.isAuthorized = (status == .sharingAuthorized)
        }
    }
    
    // MARK: - Fetch Workouts
    
    func fetchRecentWorkouts(days: Int = 7, completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        guard isAuthorized else {
            completion(nil, NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Not authorized"]))
            return
        }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let workouts = samples as? [HKWorkout] ?? []
            DispatchQueue.main.async {
                completion(workouts, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Convert to Text Format
    
    func convertWorkoutsToText(workouts: [HKWorkout]) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        
        // Group workouts by day
        var workoutsByDay: [String: [HKWorkout]] = [:]
        
        for workout in workouts {
            let dateKey = dateFormatter.string(from: workout.startDate)
            if workoutsByDay[dateKey] == nil {
                workoutsByDay[dateKey] = []
            }
            workoutsByDay[dateKey]?.append(workout)
        }
        
        // Sort days
        let sortedDays = workoutsByDay.keys.sorted { key1, key2 in
            guard let date1 = dateFormatter.date(from: key1),
                  let date2 = dateFormatter.date(from: key2) else {
                return key1 < key2
            }
            return date1 > date2
        }
        
        // Build text
        var text = ""
        for (index, dateKey) in sortedDays.enumerated() {
            text += "\(dateKey)\n"
            
            if let dayWorkouts = workoutsByDay[dateKey] {
                for workout in dayWorkouts {
                    let exerciseLine = formatWorkout(workout)
                    text += exerciseLine + "\n"
                }
            }
            
            if index < sortedDays.count - 1 {
                text += "\n"
            }
        }
        
        return text
    }
    
    private func formatWorkout(_ workout: HKWorkout) -> String {
        let activityType = workout.workoutActivityType
        let duration = workout.duration / 60.0 // Convert to minutes
        
        switch activityType {
        case .running:
            if let distance = workout.totalDistance {
                let km = distance.doubleValue(for: .meter()) / 1000.0
                return String(format: "%.1fk run", km)
            }
            return String(format: "%.0f min run", duration)
            
        case .cycling:
            if let distance = workout.totalDistance {
                let km = distance.doubleValue(for: .meter()) / 1000.0
                return String(format: "%.1fk cycle", km)
            }
            return String(format: "%.0f min cycle", duration)
            
        case .swimming:
            if let distance = workout.totalDistance {
                let km = distance.doubleValue(for: .meter()) / 1000.0
                return String(format: "%.1fk swim", km)
            }
            return String(format: "%.0f min swim", duration)
            
        case .walking:
            if let distance = workout.totalDistance {
                let km = distance.doubleValue(for: .meter()) / 1000.0
                return String(format: "%.1fk walk", km)
            }
            return String(format: "%.0f min walk", duration)
            
        case .traditionalStrengthTraining, .functionalStrengthTraining:
            return String(format: "%.0f min strength training", duration)
            
        case .highIntensityIntervalTraining:
            return String(format: "%.0f min HIIT", duration)
            
        case .yoga:
            return String(format: "%.0f min yoga", duration)
            
        case .rowing:
            if let distance = workout.totalDistance {
                let km = distance.doubleValue(for: .meter()) / 1000.0
                return String(format: "%.1fk row", km)
            }
            return String(format: "%.0f min row", duration)
            
        case .elliptical:
            return String(format: "%.0f min elliptical", duration)
            
        case .stairs:
            return String(format: "%.0f min stairs", duration)
            
        default:
            // For other workout types, use a generic format
            let activityName = workoutActivityName(for: activityType)
            return String(format: "%.0f min %@", duration, activityName)
        }
    }
    
    private func workoutActivityName(for type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "run"
        case .cycling: return "cycle"
        case .swimming: return "swim"
        case .walking: return "walk"
        case .traditionalStrengthTraining, .functionalStrengthTraining: return "strength"
        case .highIntensityIntervalTraining: return "HIIT"
        case .yoga: return "yoga"
        case .rowing: return "row"
        case .elliptical: return "elliptical"
        case .stairs: return "stairs"
        case .dancing: return "dance"
        case .boxing: return "boxing"
        case .kickboxing: return "kickboxing"
        case .martialArts: return "martial arts"
        case .pilates: return "pilates"
        case .crossTraining: return "cross training"
        case .hiking: return "hike"
        default: return "workout"
        }
    }
    
    // MARK: - Sync Methods
    
    func syncWorkouts(completion: @escaping (String?, Error?) -> Void) {
        fetchRecentWorkouts(days: 7) { workouts, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let workouts = workouts, !workouts.isEmpty else {
                completion("", nil)
                return
            }
            
            let text = self.convertWorkoutsToText(workouts: workouts)
            completion(text, nil)
        }
    }
}
