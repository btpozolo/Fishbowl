import SwiftUI

struct WordsPerMinuteTable: View {
    let wpmData: [GameState.WordsPerMinuteData]
    let overallWPM: (team1WPM: Double?, team2WPM: Double?)
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Words Per Minute")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(.systemGray6))
                )
            
            // Table
            VStack(spacing: 0) {
                // Table header
                HStack(spacing: 12) {
                    Text("Round")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Team 1")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(width: 80, alignment: .center)
                    
                    Text("Team 2")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(width: 80, alignment: .center)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // Table rows
                VStack(spacing: 8) {
                    // Overall row
                    WPMTableRow(
                        roundName: "Overall",
                        team1WPM: overallWPM.team1WPM,
                        team2WPM: overallWPM.team2WPM,
                        isOverall: true
                    )
                    
                    // Round rows
                    ForEach(wpmData, id: \.round) { data in
                        WPMTableRow(
                            roundName: data.round.shortDescription,
                            team1WPM: data.team1WPM,
                            team2WPM: data.team2WPM,
                            isOverall: false
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct WPMTableRow: View {
    let roundName: String
    let team1WPM: Double?
    let team2WPM: Double?
    let isOverall: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Round name
            Text(roundName)
                .font(.subheadline)
                .fontWeight(isOverall ? .bold : .medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Team 1 WPM
            WPMValue(value: team1WPM)
                .frame(width: 80, alignment: .center)
            
            // Team 2 WPM
            WPMValue(value: team2WPM)
                .frame(width: 80, alignment: .center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct WPMValue: View {
    let value: Double?
    
    var body: some View {
        if let wpm = value {
            Text(String(format: "%.2f", wpm))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(wpmColor(wpm))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(wpmColor(wpm).opacity(0.1))
                )
        } else {
            Text("--")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                )
        }
    }
    
    private func wpmColor(_ wpm: Double) -> Color {
        if wpm > 8.0 {
            return .green
        } else {
            return .red
        }
    }
}

#Preview {
    let sampleWPMData = [
        GameState.WordsPerMinuteData(round: .describe, team1WPM: 12.5, team2WPM: nil),
        GameState.WordsPerMinuteData(round: .actOut, team1WPM: 6.7, team2WPM: 9.1),
        GameState.WordsPerMinuteData(round: .oneWord, team1WPM: 4.2, team2WPM: 7.8)
    ]
    
    let overallWPM = (team1WPM: 7.8, team2WPM: 8.4)
    
    return WordsPerMinuteTable(wpmData: sampleWPMData, overallWPM: overallWPM)
        .padding()
        .background(Color(.systemGroupedBackground))
} 