import SwiftUI

struct WordStatisticsView: View {
    let wordStats: [GameState.WordStat]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Word Statistics")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(.systemGray6))
                )
            
            // Table header
            HStack(spacing: 12) {
                Text("Word")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Skips")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .center)
                    .padding(.horizontal, 8)
                
                Text("Avg Time")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .center)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            // Word rows
            LazyVStack(spacing: 8) {
                ForEach(wordStats, id: \.word.id) { stat in
                    WordStatRow(stat: stat)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct WordStatRow: View {
    let stat: GameState.WordStat
    
    var body: some View {
        HStack(spacing: 12) {
            // Word text
            Text(stat.word.text)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
            
            // Skips count
            Text("\(stat.skips)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(stat.skips > 0 ? .orange : .secondary)
                .frame(width: 60, alignment: .center)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(stat.skips > 0 ? Color.orange.opacity(0.1) : Color(.systemGray6))
                )
            
            // Average time
            Text(formatTime(stat.averageTime))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(timeColor(stat.averageTime))
                .frame(width: 80, alignment: .center)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(timeColor(stat.averageTime).opacity(0.1))
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func formatTime(_ seconds: Double) -> String {
        if seconds < 60 {
            return String(format: "%.2fs", seconds)
        } else {
            let minutes = Int(seconds) / 60
            let remainingSeconds = Int(seconds) % 60
            return String(format: "%dm%ds", minutes, remainingSeconds)
        }
    }
    
    private func timeColor(_ seconds: Double) -> Color {
        if seconds >= 30 {
            return .red
        } else if seconds >= 15 {
            return .orange
        } else if seconds >= 5 {
            return .yellow
        } else {
            return .green
        }
    }
}

#Preview {
    let sampleStats = [
        GameState.WordStat(
            word: Word(text: "Elephant"),
            skips: 2,
            averageTime: 45.5,
            totalTime: 136
        ),
        GameState.WordStat(
            word: Word(text: "Pizza"),
            skips: 0,
            averageTime: 12.3,
            totalTime: 37
        ),
        GameState.WordStat(
            word: Word(text: "Basketball"),
            skips: 1,
            averageTime: 28.7,
            totalTime: 86
        )
    ]
    
    return WordStatisticsView(wordStats: sampleStats)
        .padding()
        .background(Color(.systemGroupedBackground))
} 