//
//  WeeklySummaryView.swift
//  WorkoutSummaryApp
//
//  Weekly workout summary with muscle group analysis
//

import SwiftUI

struct WeeklySummaryView: View {
    let workoutDays: [WorkoutDay]
    
    @State private var selectedTab = 0
    @Environment(\.clearWorkout) var clearWorkout
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            Picker("View", selection: $selectedTab) {
                Text("Daily").tag(0)
                Text("Muscle Map").tag(1)
                Text("Stats").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Content based on selected tab
            ScrollView {
                if selectedTab == 0 {
                    dailyView
                } else if selectedTab == 1 {
                    muscleMapView
                } else {
                    statisticsView
                }
            }
            
            // Bottom button
            Button(action: {
                clearWorkout()
            }) {
                Text("New Input")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    // MARK: - Daily View
    
    private var dailyView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(workoutDays) { day in
                WorkoutDayView(workoutDay: day)
            }
        }
        .padding()
    }
    
    // MARK: - Muscle Map View
    
    private var muscleMapView: some View {
        let muscleIntensity = MuscleMapper.calculateMuscleIntensity(for: workoutDays)
        
        return VStack(spacing: 20) {
            // Week overview
            VStack(spacing: 10) {
                Text("Week Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(workoutDays.count) workout days")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(totalExercises) total exercises")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Body heatmap
            BodyHeatmapView(muscleIntensity: muscleIntensity)
        }
        .padding()
    }
    
    // MARK: - Statistics View
    
    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Overall stats
            VStack(alignment: .leading, spacing: 15) {
                Text("Overall Statistics")
                    .font(.title2)
                    .fontWeight(.bold)
                
                statRow(label: "Total Workout Days", value: "\(workoutDays.count)")
                statRow(label: "Total Exercises", value: "\(totalExercises)")
                statRow(label: "Strength Exercises", value: "\(strengthExerciseCount)")
                statRow(label: "Cardio Sessions", value: "\(cardioExerciseCount)")
                statRow(label: "Total Volume", value: "\(totalVolume)")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Exercise breakdown by day
            VStack(alignment: .leading, spacing: 15) {
                Text("Daily Breakdown")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ForEach(workoutDays) { day in
                    dayStatCard(for: day)
                }
            }
        }
        .padding()
    }
    
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
    }
    
    private func dayStatCard(for day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day.dateLabel)
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(day.exercises.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading) {
                    Text("Muscles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(uniqueMusclesWorked(in: day))")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Computed Properties
    
    private var totalExercises: Int {
        workoutDays.reduce(0) { $0 + $1.exercises.count }
    }
    
    private var strengthExerciseCount: Int {
        workoutDays.reduce(0) { count, day in
            count + day.exercises.filter { $0.sets != nil || $0.reps != nil }.count
        }
    }
    
    private var cardioExerciseCount: Int {
        workoutDays.reduce(0) { count, day in
            count + day.exercises.filter { 
                $0.unit == "k" || $0.unit == "km" || $0.unit == "min"
            }.count
        }
    }
    
    private var totalVolume: String {
        let volume = workoutDays.reduce(0) { total, day in
            total + day.exercises.reduce(0) { dayTotal, exercise in
                if let sets = exercise.sets, let reps = exercise.reps {
                    return dayTotal + (sets * reps)
                }
                return dayTotal
            }
        }
        return "\(volume) reps"
    }
    
    private func uniqueMusclesWorked(in day: WorkoutDay) -> Int {
        var muscles = Set<MuscleGroup>()
        for exercise in day.exercises {
            let exerciseMuscles = MuscleMapper.getMuscleGroups(for: exercise)
            muscles.formUnion(exerciseMuscles)
        }
        return muscles.count
    }
}

// MARK: - Preview

struct WeeklySummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleDays = [
            WorkoutDay(dateLabel: "Day 1", exercises: [
                Exercise(rawText: "3x10 pull ups", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "pull ups"),
                Exercise(rawText: "3x10 dips", sets: 3, reps: 10, quantity: nil, unit: nil, movement: "dips"),
                Exercise(rawText: "5k run", sets: nil, reps: nil, quantity: 5, unit: "k", movement: "run")
            ]),
            WorkoutDay(dateLabel: "Day 2", exercises: [
                Exercise(rawText: "4x8 bench press", sets: 4, reps: 8, quantity: nil, unit: nil, movement: "bench press"),
                Exercise(rawText: "30 min cycle", sets: nil, reps: nil, quantity: 30, unit: "min", movement: "cycle")
            ])
        ]
        
        WeeklySummaryView(workoutDays: sampleDays)
    }
}
