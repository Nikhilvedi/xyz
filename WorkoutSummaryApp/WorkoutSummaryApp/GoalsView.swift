//
//  GoalsView.swift
//  WorkoutSummaryApp
//
//  View for managing weekly workout goals
//

import SwiftUI

struct GoalsView: View {
    @Binding var goals: [WorkoutGoal]
    let workoutDays: [WorkoutDay]
    @State private var showingAddGoal = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Weekly Goals")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showingAddGoal = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            if goals.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(goals) { goal in
                            GoalCardView(goal: goal, onDelete: {
                                deleteGoal(goal)
                            })
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView(goals: $goals)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Goals Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Set weekly workout goals to track your progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showingAddGoal = true
            }) {
                Text("Add Your First Goal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func deleteGoal(_ goal: WorkoutGoal) {
        goals.removeAll { $0.id == goal.id }
    }
}

// MARK: - Goal Card View

struct GoalCardView: View {
    let goal: WorkoutGoal
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(goal.type.icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)
                    
                    Text("\(goal.displayTarget) • \(goal.frequency)x per week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(goal.completedCount) / \(goal.frequency) completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if goal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(goal.isCompleted ? Color.green : Color.blue)
                            .frame(width: geometry.size.width * goal.progressPercentage, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Add Goal View

struct AddGoalView: View {
    @Binding var goals: [WorkoutGoal]
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var selectedType: GoalType = .strength
    @State private var targetValue: String = ""
    @State private var frequency: String = "3"
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Exercise name (e.g., pull ups, run)", text: $name)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            Text("\(type.icon) \(type.rawValue)").tag(type)
                        }
                    }
                }
                
                Section(header: Text("Target")) {
                    HStack {
                        TextField("Target value", text: $targetValue)
                            .keyboardType(.decimalPad)
                        
                        Text(unitLabel)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Times per week")
                        Spacer()
                        TextField("Frequency", text: $frequency)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Examples")) {
                    Text(exampleText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addGoal()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var unitLabel: String {
        switch selectedType {
        case .strength:
            return "total reps (sets × reps)"
        case .cardioDistance:
            return "km"
        case .cardioTime:
            return "minutes"
        case .bodyweight:
            return "reps"
        }
    }
    
    private var exampleText: String {
        switch selectedType {
        case .strength:
            return "Example: 30 reps (like 3x10) of pull ups, 3 times per week"
        case .cardioDistance:
            return "Example: 5km run, 2 times per week"
        case .cardioTime:
            return "Example: 30 minutes cycle, 3 times per week"
        case .bodyweight:
            return "Example: 50 push ups, 4 times per week"
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && !targetValue.isEmpty && !frequency.isEmpty &&
        Double(targetValue) != nil && Int(frequency) != nil
    }
    
    // MARK: - Actions
    
    private func addGoal() {
        guard let value = Double(targetValue),
              let freq = Int(frequency),
              freq > 0 else {
            errorMessage = "Please enter valid numbers"
            showingError = true
            return
        }
        
        let unit: String? = {
            switch selectedType {
            case .cardioDistance: return "km"
            case .cardioTime: return "min"
            default: return nil
            }
        }()
        
        let newGoal = WorkoutGoal(
            name: name,
            type: selectedType,
            targetValue: value,
            targetUnit: unit,
            frequency: freq
        )
        
        goals.append(newGoal)
        dismiss()
    }
}

// MARK: - Preview

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView(
            goals: .constant([
                WorkoutGoal(name: "pull ups", type: .strength, targetValue: 30, frequency: 3),
                WorkoutGoal(name: "run", type: .cardioDistance, targetValue: 5, targetUnit: "km", frequency: 2)
            ]),
            workoutDays: []
        )
    }
}
