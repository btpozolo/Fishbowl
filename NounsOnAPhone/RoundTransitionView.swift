import SwiftUI

struct RoundTransitionView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject private var soundManager = SoundManager.shared
    @State private var showingSoundSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Horizontal layout
                VStack(spacing: 8) {
                    // Top: Centered title with round number
                    VStack(spacing: 8) {
                        Text(transitionTitle)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 40)
                    }
                    // Center the team info/time block vertically
                    Spacer()
                    VStack(spacing: 8) {
                        // Team info
                        VStack(spacing: 8) {
                            Text(nextTeamTitle)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray6))
                                )
                            Text("Team \(nextTeamNumber)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.accentColor)
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: nextTeamNumber)
                        }
                        // Time remaining (if applicable)
                        if gameState.lastTransitionReason == .wordsExhausted && gameState.timeRemaining > 0 {
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                Text("Time remaining: \(formatTime(gameState.timeRemaining))")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.orange.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    Spacer()
                    // Sound Settings Button
                    Button(action: {
                        showingSoundSettings = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "speaker.wave.2")
                                .font(.caption)
                            Text("Sound Settings")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .padding(.bottom, 8)
                    
                    // Bottom: Continue button
                    GameButton.primary(
                        title: continueButtonText,
                        icon: "arrow.right.circle.fill",
                        size: .large
                    ) {
                        withAnimation(.spring(response: 0.6)) {
                            gameState.advanceTeamOrRound()
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 8)
            } else {
                // Vertical layout (original)
                VStack(spacing: 40) {
                    // Header with improved styling
                    VStack(spacing: 20) {
                        // Status icon with animation
                        ZStack {
                            Circle()
                                .fill(statusColor.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: statusIcon)
                                .font(.system(size: 36))
                                .foregroundColor(statusColor)
                        }
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: gameState.timeRemaining)
                        
                        VStack(spacing: 12) {
                            Text(transitionTitle)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text(transitionMessage)
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Next team info with enhanced design
                    VStack(spacing: 24) {
                        Text(nextTeamTitle)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(.systemGray6))
                            )
                        
                        // Team number without circle
                        Text("Team \(nextTeamNumber)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.accentColor)
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: nextTeamNumber)
                        
                        // Time remaining info (if applicable)
                        if gameState.lastTransitionReason == .wordsExhausted && gameState.timeRemaining > 0 {
                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                
                                Text("Time remaining: \(formatTime(gameState.timeRemaining))")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        
                        Text(nextTeamMessage)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Sound Settings Button
                    Button(action: {
                        showingSoundSettings = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "speaker.wave.2")
                                .font(.caption)
                            Text("Sound Settings")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .padding(.bottom, 12)
                    
                    // Continue button with enhanced design
                    GameButton.primary(
                        title: continueButtonText,
                        icon: "arrow.right.circle.fill",
                        size: .large
                    ) {
                        withAnimation(.spring(response: 0.6)) {
                            gameState.advanceTeamOrRound()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingSoundSettings) {
            SoundSettingsView()
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    private var transitionTitle: String {
        if gameState.lastTransitionReason == .timerExpired {
            return "Time's Up!"
        } else {
            return "Round \(gameState.currentRound.rawValue) Complete!"
        }
    }
    
    private var transitionMessage: String {
        if gameState.lastTransitionReason == .timerExpired {
            return "Team \(gameState.currentTeam == 1 ? 2 : 1) ran out of time"
        } else {
            return "Team \(gameState.currentTeam) completed all words with \(formatTime(gameState.timeRemaining)) remaining!"
        }
    }
    
    private var nextTeamTitle: String {
        if gameState.lastTransitionReason == .timerExpired {
            return "Next Up:"
        } else {
            return "Same Team Continues:"
        }
    }
    
    private var nextTeamNumber: Int {
        if gameState.lastTransitionReason == .timerExpired {
            return gameState.currentTeam
        } else {
            return gameState.currentTeam
        }
    }
    
    private var nextTeamMessage: String {
        if gameState.lastTransitionReason == .timerExpired {
            return "Get ready to play!"
        } else {
            return "Continue with remaining time!"
        }
    }
    
    private var continueButtonText: String {
        if gameState.lastTransitionReason == .timerExpired {
            return "Pass Phone to Next Team"
        } else {
            return "Continue to Next Round"
        }
    }
    
    private var statusIcon: String {
        if gameState.lastTransitionReason == .timerExpired {
            return "clock.badge.exclamationmark"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        if gameState.lastTransitionReason == .timerExpired {
            return .red
        } else {
            return .green
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    RoundTransitionView(gameState: GameState())
} 

#Preview("Landscape", traits: .landscapeLeft) {
    RoundTransitionView(gameState: GameState())
}

#Preview("Team 1 Ran Out of Time - Switch to Team 2, Round 1") {
    let sampleGameState = GameState()
    sampleGameState.addSampleWords()
    sampleGameState.currentPhase = .roundTransition
    sampleGameState.currentRound = .describe
    sampleGameState.currentTeam = 2 // Team 2's turn next
    sampleGameState.lastTransitionReason = .timerExpired
    sampleGameState.timeRemaining = 60 // Full timer for new team
    return RoundTransitionView(gameState: sampleGameState)
}


