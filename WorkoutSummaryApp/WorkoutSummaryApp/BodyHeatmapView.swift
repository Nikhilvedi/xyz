//
//  BodyHeatmapView.swift
//  WorkoutSummaryApp
//
//  Visual representation of muscle groups with heatmap
//

import SwiftUI

struct BodyHeatmapView: View {
    let muscleIntensity: [MuscleGroup: Double]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Muscle Groups Targeted")
                .font(.title2)
                .fontWeight(.bold)
            
            // Body visualization
            ZStack {
                // Simple body outline
                bodyOutline
                
                // Muscle group overlays
                muscleOverlays
            }
            .frame(height: 400)
            .padding()
            
            // Legend
            legend
            
            // Detailed breakdown
            muscleBreakdown
        }
    }
    
    // MARK: - Body Outline
    
    private var bodyOutline: some View {
        VStack(spacing: 0) {
            // Head
            Circle()
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: 60, height: 60)
            
            // Torso
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: 120, height: 180)
            
            // Legs
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 50, height: 120)
                
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 50, height: 120)
            }
        }
    }
    
    // MARK: - Muscle Overlays
    
    private var muscleOverlays: some View {
        VStack(spacing: 0) {
            // Head spacer
            Spacer()
                .frame(height: 60)
            
            // Upper body
            VStack(spacing: 5) {
                // Shoulders
                HStack(spacing: 20) {
                    muscleIndicator(for: .shoulders, label: "Shoulders")
                        .frame(width: 40, height: 30)
                    
                    Spacer()
                        .frame(width: 40)
                    
                    muscleIndicator(for: .shoulders, label: "")
                        .frame(width: 40, height: 30)
                }
                
                // Chest
                muscleIndicator(for: .chest, label: "Chest")
                    .frame(width: 100, height: 40)
                
                // Arms row
                HStack(spacing: 10) {
                    VStack(spacing: 5) {
                        muscleIndicator(for: .biceps, label: "Biceps")
                            .frame(width: 35, height: 35)
                        muscleIndicator(for: .triceps, label: "Triceps")
                            .frame(width: 35, height: 35)
                    }
                    
                    VStack(spacing: 5) {
                        muscleIndicator(for: .upperBack, label: "Back")
                            .frame(width: 80, height: 40)
                        muscleIndicator(for: .abs, label: "Abs")
                            .frame(width: 80, height: 40)
                    }
                    
                    VStack(spacing: 5) {
                        muscleIndicator(for: .biceps, label: "")
                            .frame(width: 35, height: 35)
                        muscleIndicator(for: .triceps, label: "")
                            .frame(width: 35, height: 35)
                    }
                }
            }
            .frame(height: 180)
            
            // Lower body
            HStack(spacing: 10) {
                VStack(spacing: 5) {
                    muscleIndicator(for: .quads, label: "Quads")
                        .frame(width: 50, height: 50)
                    muscleIndicator(for: .hamstrings, label: "Hams")
                        .frame(width: 50, height: 40)
                    muscleIndicator(for: .calves, label: "Calves")
                        .frame(width: 50, height: 30)
                }
                
                VStack(spacing: 5) {
                    muscleIndicator(for: .quads, label: "")
                        .frame(width: 50, height: 50)
                    muscleIndicator(for: .hamstrings, label: "")
                        .frame(width: 50, height: 40)
                    muscleIndicator(for: .calves, label: "")
                        .frame(width: 50, height: 30)
                }
            }
        }
    }
    
    // MARK: - Muscle Indicator
    
    private func muscleIndicator(for muscle: MuscleGroup, label: String) -> some View {
        let intensity = muscleIntensity[muscle] ?? 0
        let color = MuscleMapper.getColor(for: intensity)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            
            if !label.isEmpty && intensity > 0 {
                Text(label)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            }
        }
    }
    
    // MARK: - Legend
    
    private var legend: some View {
        HStack(spacing: 20) {
            legendItem(color: Color.gray.opacity(0.2), label: "Not Targeted")
            legendItem(color: Color.yellow.opacity(0.4), label: "Light")
            legendItem(color: Color.orange.opacity(0.6), label: "Moderate")
            legendItem(color: Color.red.opacity(0.8), label: "Heavy")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 20, height: 20)
            
            Text(label)
                .font(.caption)
        }
    }
    
    // MARK: - Muscle Breakdown
    
    private var muscleBreakdown: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Detailed Breakdown")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(MuscleGroup.allCases.filter { $0 != .cardio }, id: \.self) { muscle in
                    muscleBreakdownItem(for: muscle)
                }
            }
            
            // Cardio separately if present
            if let cardioIntensity = muscleIntensity[.cardio], cardioIntensity > 0 {
                Divider()
                muscleBreakdownItem(for: .cardio)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func muscleBreakdownItem(for muscle: MuscleGroup) -> some View {
        let intensity = muscleIntensity[muscle] ?? 0
        let color = MuscleMapper.getColor(for: intensity)
        let description = MuscleMapper.getIntensityDescription(for: intensity)
        
        return HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(muscle.displayName)
                .font(.subheadline)
            
            Spacer()
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct BodyHeatmapView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleIntensity: [MuscleGroup: Double] = [
            .chest: 0.8,
            .triceps: 0.6,
            .shoulders: 0.5,
            .lats: 0.4,
            .quads: 0.7,
            .hamstrings: 0.3
        ]
        
        ScrollView {
            BodyHeatmapView(muscleIntensity: sampleIntensity)
                .padding()
        }
    }
}
