import SwiftUI

struct GamePlayView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Horizontal layout: Left (round/timer), Center (word/button), Right (scores)
                HStack(spacing: 24) {
                    // Left: Round info and timer
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Team \(gameState.currentTeam)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text(gameState.currentRound.title)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        // Timer
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "timer")
                                    .font(.title3)
                                    .foregroundColor(timerColor)
                                Text(timeString)
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundColor(timerColor)
                                    .monospacedDigit()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(timerBackgroundColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(timerColor.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            ProgressView(value: Double(gameState.timeRemaining), total: Double(gameState.timerDuration))
                                .progressViewStyle(LinearProgressViewStyle(tint: timerColor))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: geometry.size.width * 0.22, alignment: .top)
                    
                    // Center: Word and button
                    VStack(spacing: 40) {
                        if let currentWord = gameState.currentWord {
                            Text(currentWord.text)
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 40)
                                .frame(maxWidth: .infinity)
                                .lineLimit(currentWord.text.contains(" ") ? nil : 1)
                                .truncationMode(.tail)
                                .minimumScaleFactor(0.3)
                                .background(
                                    RoundedRectangle(cornerRadius: 32)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 32)
                                                .stroke(Color.accentColor.opacity(0.2), lineWidth: 2)
                                        )
                                )
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentWord.text)
                        }
                        Button(action: {
                            withAnimation(.spring(response: 0.4)) {
                                gameState.wordGuessed()
                            }
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 36))
                                Text("Correct!")
                                    .font(.system(size: 36, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(24)
                            .shadow(color: .green.opacity(0.3), radius: 12, x: 0, y: 4)
                        }
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.3), value: gameState.team1Score + gameState.team2Score)
                    }
                    .frame(maxWidth: geometry.size.width * 0.45)
                    
                    // Right: Scores
                    VStack(spacing: 32) {
                        ScoreDisplay(teamNumber: 1, score: gameState.team1Score, isCurrentTeam: gameState.currentTeam == 1)
                        ScoreDisplay(teamNumber: 2, score: gameState.team2Score, isCurrentTeam: gameState.currentTeam == 2)
                        Spacer()
                    }
                    .frame(maxWidth: geometry.size.width * 0.22, alignment: .top)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            } else {
                // Vertical layout (original)
                VStack(spacing: 0) {
                    // Header with improved styling
                    VStack(spacing: 20) {
                        // Team and round info
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Team \(gameState.currentTeam)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text(gameState.currentRound.title)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            // Timer with enhanced design
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "timer")
                                        .font(.title3)
                                        .foregroundColor(timerColor)
                                    Text(timeString)
                                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                                        .foregroundColor(timerColor)
                                        .monospacedDigit()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(timerBackgroundColor)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(timerColor.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                ProgressView(value: Double(gameState.timeRemaining), total: Double(gameState.timerDuration))
                                    .progressViewStyle(LinearProgressViewStyle(tint: timerColor))
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    Spacer()
                    // Current word display with enhanced design
                    if let currentWord = gameState.currentWord {
                        VStack(spacing: 24) {
                            Text("Current Word")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray6))
                                )
                            Text(currentWord.text)
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 40)
                                .frame(maxWidth: .infinity)
                                .lineLimit(currentWord.text.contains(" ") ? nil : 1)
                                .truncationMode(.tail)
                                .minimumScaleFactor(0.3)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.accentColor.opacity(0.2), lineWidth: 2)
                                        )
                                )
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentWord.text)
                        }
                        .padding(.horizontal, 20)
                    }
                    Spacer()
                    // Correct button with enhanced design
                    Button(action: {
                        withAnimation(.spring(response: 0.4)) {
                            gameState.wordGuessed()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                            Text("Correct!")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.3), value: gameState.team1Score + gameState.team2Score)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    // Scores with improved design
                    HStack(spacing: 20) {
                        ScoreDisplay(teamNumber: 1, score: gameState.team1Score, isCurrentTeam: gameState.currentTeam == 1)
                        ScoreDisplay(teamNumber: 2, score: gameState.team2Score, isCurrentTeam: gameState.currentTeam == 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var timeString: String {
        let minutes = gameState.timeRemaining / 60
        let seconds = gameState.timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var timerColor: Color {
        let totalTime = gameState.timerDuration
        let remainingTime = gameState.timeRemaining
        let percentage = Double(remainingTime) / Double(totalTime)
        
        if percentage <= 0.17 { // Last 17% of time
            return .red
        } else if percentage <= 0.5 { // Last 50% of time
            return .orange
        } else {
            return .accentColor
        }
    }
    
    private var timerBackgroundColor: Color {
        let totalTime = gameState.timerDuration
        let remainingTime = gameState.timeRemaining
        let percentage = Double(remainingTime) / Double(totalTime)
        
        if percentage <= 0.17 {
            return .red.opacity(0.1)
        } else if percentage <= 0.5 {
            return .orange.opacity(0.1)
        } else {
            return .accentColor.opacity(0.1)
        }
    }
}

struct ScoreDisplay: View {
    let teamNumber: Int
    let score: Int
    let isCurrentTeam: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Text("Team \(teamNumber)")
                    .font(.headline)
                    .foregroundColor(isCurrentTeam ? .accentColor : .secondary)
                
                if isCurrentTeam {
                    Image(systemName: "circle.fill")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            
            Text("\(score)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(isCurrentTeam ? .accentColor : .primary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isCurrentTeam ? Color.accentColor.opacity(0.1) : Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isCurrentTeam ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isCurrentTeam ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isCurrentTeam)
    }
}

#Preview {
    GamePlayView(gameState: GameState())
} 