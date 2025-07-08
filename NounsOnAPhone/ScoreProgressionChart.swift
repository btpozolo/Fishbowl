import SwiftUI

struct ScoreProgressionChart: View {
    let scoreHistory: [(turn: Int, team1Score: Int, team2Score: Int)]
    
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
            
            if scoreHistory.isEmpty {
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
                // Chart
                ChartView(scoreHistory: scoreHistory)
                    .frame(height: 200)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ChartView: View {
    let scoreHistory: [(turn: Int, team1Score: Int, team2Score: Int)]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid lines
                GridLines(maxScore: maxScore, maxTurn: maxTurn, size: geometry.size)
                
                // Chart lines
                ChartLines(scoreHistory: scoreHistory, maxScore: maxScore, maxTurn: maxTurn, size: geometry.size)
                
                // Axis labels
                AxisLabels(maxScore: maxScore, maxTurn: maxTurn, size: geometry.size)
            }
        }
    }
    
    private var maxScore: Int {
        let maxTeam1 = scoreHistory.map { $0.team1Score }.max() ?? 0
        let maxTeam2 = scoreHistory.map { $0.team2Score }.max() ?? 0
        return max(maxTeam1, maxTeam2, 1) // Minimum of 1 to avoid division by zero
    }
    
    private var maxTurn: Int {
        return scoreHistory.map { $0.turn }.max() ?? 1
    }
}

struct GridLines: View {
    let maxScore: Int
    let maxTurn: Int
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Vertical grid lines (turns)
            ForEach(1...maxTurn, id: \.self) { turn in
                let x = (CGFloat(turn - 1) / CGFloat(maxTurn - 1)) * size.width
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 1)
                    .position(x: x, y: size.height / 2)
            }
            
            // Horizontal grid lines (scores)
            ForEach(0...maxScore, id: \.self) { score in
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
    let scoreHistory: [(turn: Int, team1Score: Int, team2Score: Int)]
    let maxScore: Int
    let maxTurn: Int
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Team 1 line (blue)
            Path { path in
                for (index, data) in scoreHistory.enumerated() {
                    let x = (CGFloat(data.turn - 1) / CGFloat(maxTurn - 1)) * size.width
                    let y = size.height - (CGFloat(data.team1Score) / CGFloat(maxScore)) * size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 3)
            
            // Team 2 line (red)
            Path { path in
                for (index, data) in scoreHistory.enumerated() {
                    let x = (CGFloat(data.turn - 1) / CGFloat(maxTurn - 1)) * size.width
                    let y = size.height - (CGFloat(data.team2Score) / CGFloat(maxScore)) * size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.red, lineWidth: 3)
            
            // Data points
            ForEach(scoreHistory.indices, id: \.self) { index in
                let data = scoreHistory[index]
                let x = (CGFloat(data.turn - 1) / CGFloat(maxTurn - 1)) * size.width
                
                // Team 1 point
                let y1 = size.height - (CGFloat(data.team1Score) / CGFloat(maxScore)) * size.height
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .position(x: x, y: y1)
                
                // Team 2 point
                let y2 = size.height - (CGFloat(data.team2Score) / CGFloat(maxScore)) * size.height
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .position(x: x, y: y2)
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
            // Y-axis labels (scores)
            ForEach(0...maxScore, id: \.self) { score in
                let y = size.height - (CGFloat(score) / CGFloat(maxScore)) * size.height
                Text("\(score)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .position(x: 15, y: y)
            }
            
            // X-axis labels (turns)
            ForEach(1...maxTurn, id: \.self) { turn in
                let x = (CGFloat(turn - 1) / CGFloat(maxTurn - 1)) * size.width
                Text("\(turn)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .position(x: x, y: size.height - 10)
            }
            
            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    Text("Team 1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("Team 2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .position(x: size.width - 60, y: 20)
        }
    }
}

#Preview {
    let sampleHistory = [
        (turn: 1, team1Score: 3, team2Score: 2),
        (turn: 2, team1Score: 5, team2Score: 4),
        (turn: 3, team1Score: 7, team2Score: 6),
        (turn: 4, team1Score: 8, team2Score: 6)
    ]
    
    return ScoreProgressionChart(scoreHistory: sampleHistory)
        .padding()
        .background(Color(.systemGroupedBackground))
} 