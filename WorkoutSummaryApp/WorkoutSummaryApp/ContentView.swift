//
//  ContentView.swift
//  WorkoutSummaryApp
//
//  Main view for the workout summary app
//

import SwiftUI

// MARK: - Environment Key for Clear Action

private struct ClearWorkoutKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var clearWorkout: () -> Void {
        get { self[ClearWorkoutKey.self] }
        set { self[ClearWorkoutKey.self] = newValue }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !viewModel.isParsed {
                    // Input mode
                    inputView
                } else {
                    // Summary mode
                    summaryView
                }
            }
            .navigationTitle("Workout Summary")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Input View
    
    private var inputView: some View {
        VStack(spacing: 20) {
            // Goals progress widget
            if !viewModel.weeklyGoals.isEmpty {
                goalsProgressWidget
            }
            
            Text("Paste your workout notes below")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top)
            
            TextEditor(text: $viewModel.inputText)
                .font(.body)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.horizontal)
            
            if !viewModel.inputText.isEmpty {
                Button(action: {
                    viewModel.parseWorkout()
                }) {
                    Text("Parse Summary")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Goals Progress Widget
    
    private var goalsProgressWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("📊 Weekly Goals")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                let completed = viewModel.weeklyGoals.filter { $0.isCompleted }.count
                let total = viewModel.weeklyGoals.count
                
                Text("\(completed)/\(total)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(completed == total ? .green : .blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.weeklyGoals.prefix(5)) { goal in
                        MiniGoalCard(goal: goal)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Mini Goal Card

struct MiniGoalCard: View {
    let goal: WorkoutGoal
    
    var body: some View {
        VStack(spacing: 6) {
            Text(goal.type.icon)
                .font(.title3)
            
            Text(goal.name)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 60)
            
            Text("\(goal.completedCount)/\(goal.frequency)")
                .font(.caption2)
                .foregroundColor(goal.isCompleted ? .green : .secondary)
            
            if goal.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(goal.isCompleted ? Color.green : Color(.systemGray4), lineWidth: 2)
        )
    }
    
    // MARK: - Summary View
    
    private var summaryView: some View {
        WeeklySummaryView(workoutDays: viewModel.workoutDays)
            .environment(\.clearWorkout, viewModel.clearAll)
    }
}

// MARK: - Workout Day View

struct WorkoutDayView: View {
    let workoutDay: WorkoutDay
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(workoutDay.dateLabel)
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(workoutDay.exercises) { exercise in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .font(.body)
                    Text(exercise.rawText)
                        .font(.body)
                }
                .padding(.leading, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
