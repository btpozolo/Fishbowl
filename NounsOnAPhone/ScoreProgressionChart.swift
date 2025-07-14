import SwiftUI

struct ScoreProgressionChart: View {
    let team1TurnScores: [Int]
    let team2TurnScores: [Int]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Score Progression")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(.systemGray6))
                )
            if team1TurnScores.count <= 1 && team2TurnScores.count <= 1 {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("No score data available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
            } else {
                HStack(alignment: .center, spacing: 0) {
                    // Y-axis label - centered vertically
                    VStack {
                        Spacer()
                        Text("Scores")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(-90))
                            .frame(width: 60, height: 20)
                            .offset(x: -25) // Move further left for better spacing
                        Spacer()
                    }
                    .frame(width: 35)
                    // Chart
                    VStack(spacing: 0) {
                        ChartView(team1TurnScores: team1TurnScores, team2TurnScores: team2TurnScores)
                            .frame(height: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
                            )
                        // X-axis label
                        Text("Turn")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.top, 24) // Move further down
                    }
                }
                .padding(.horizontal, 8)
                // Legend below chart
                ModernLegend()
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ModernLegend: View {
    var body: some View {
        HStack(spacing: 20) {
            HStack(spacing: 6) {
                Capsule()
                    .fill(Color.blue)
                    .frame(width: 18, height: 8)
                Text("Team 1")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 6) {
                Capsule()
                    .fill(Color.red)
                    .frame(width: 18, height: 8)
                Text("Team 2")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ChartView: View {
    let team1TurnScores: [Int]
    let team2TurnScores: [Int]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid lines
                GridLines(maxScore: maxScore, maxTurn: maxTurn, size: geometry.size)
                // Chart lines
                ChartLines(team1TurnScores: team1TurnScores, team2TurnScores: team2TurnScores, maxScore: maxScore, maxTurn: maxTurn, size: geometry.size)
                // Axis labels
                AxisLabels(maxScore: maxScore, maxTurn: maxTurn, size: geometry.size)
            }
        }
    }
    
    private var maxScore: Int {
        let maxTeam1 = team1TurnScores.max() ?? 0
        let maxTeam2 = team2TurnScores.max() ?? 0
        return max(maxTeam1, maxTeam2, 1) // Minimum of 1 to avoid division by zero
    }
    private var maxTurn: Int {
        return max(team1TurnScores.count - 1, team2TurnScores.count - 1, 1)
    }
}

struct GridLines: View {
    let maxScore: Int
    let maxTurn: Int
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Y-axis (vertical line at x=0)
            Rectangle()
                .fill(Color(.systemGray3))
                .frame(width: 2)
                .position(x: 0, y: size.height / 2)
            // Vertical grid lines (turns)
            ForEach(0...maxTurn, id: \.self) { turn in
                let x = (CGFloat(turn) / CGFloat(maxTurn)) * size.width
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 1)
                    .position(x: x, y: size.height / 2)
            }
            // Horizontal grid lines (scores) - every 5 points
            ForEach(Array(stride(from: 0, through: maxScore, by: 5)), id: \.self) { score in
                let y = size.height - (CGFloat(score) / CGFloat(maxScore)) * size.height
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 1)
                    .position(x: size.width / 2, y: y)
            }
        }
    }
}

struct ChartLines: View {
    let team1TurnScores: [Int]
    let team2TurnScores: [Int]
    let maxScore: Int
    let maxTurn: Int
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Team 1 line (blue)
            Path { path in
                for i in 0..<team1TurnScores.count {
                    let x = (CGFloat(i) / CGFloat(maxTurn)) * size.width
                    let y = size.height - (CGFloat(team1TurnScores[i]) / CGFloat(maxScore)) * size.height
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            // Team 2 line (red)
            Path { path in
                for i in 0..<team2TurnScores.count {
                    let x = (CGFloat(i) / CGFloat(maxTurn)) * size.width
                    let y = size.height - (CGFloat(team2TurnScores[i]) / CGFloat(maxScore)) * size.height
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.red, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            // Data points
            ForEach(team1TurnScores.indices, id: \.self) { i in
                let x = (CGFloat(i) / CGFloat(maxTurn)) * size.width
                let y = size.height - (CGFloat(team1TurnScores[i]) / CGFloat(maxScore)) * size.height
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .shadow(color: Color.blue.opacity(0.18), radius: 4, x: 0, y: 2)
                    .position(x: x, y: y)
            }
            ForEach(team2TurnScores.indices, id: \.self) { i in
                let x = (CGFloat(i) / CGFloat(maxTurn)) * size.width
                let y = size.height - (CGFloat(team2TurnScores[i]) / CGFloat(maxScore)) * size.height
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .shadow(color: Color.red.opacity(0.18), radius: 4, x: 0, y: 2)
                    .position(x: x, y: y)
            }
        }
    }
}

struct AxisLabels: View {
    let maxScore: Int
    let maxTurn: Int
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Y-axis labels (scores) - every 5 points
            ForEach(Array(stride(from: 0, through: maxScore, by: 5)), id: \.self) { score in
                let y = size.height - (CGFloat(score) / CGFloat(maxScore)) * size.height
                Text("\(score)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .trailing)
                    .position(x: -35, y: y) // moved further left for better spacing
            }
            // X-axis labels (turns)
            ForEach(0...maxTurn, id: \.self) { turn in
                let x = (CGFloat(turn) / CGFloat(maxTurn)) * size.width
                Text("\(turn)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .position(x: x, y: size.height + 10)
            }
        }
    }
}

struct ScoreProgressionChart_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            ScoreProgressionChart(
                team1TurnScores: [0, 2, 4, 7, 10],
                team2TurnScores: [0, 1, 2, 3, 5]
            )
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(20)
            .shadow(radius: 4)
        }
        .padding()
        .background(Color(.systemGray6))
    }
} 
