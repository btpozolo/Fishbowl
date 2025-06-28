import SwiftUI

struct RoundTransitionView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Horizontal layout
                VStack(spacing: 24) {
                    // Top: Centered title with round number
                    VStack(spacing: 12) {
                        Text(transitionTitleWithRound)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Middle: Team info and time remaining in vertical stack
                    VStack(spacing: 20) {
                        // Team info
                        VStack(spacing: 16) {
                            Text(nextTeamTitle)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray6))
                                )
                            
                            // Team number
                            Text("Team \(nextTeamNumber)")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.accentColor)
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: nextTeamNumber)
                        }
                        
                        // Time remaining (if applicable)
                        if gameState.timeRemaining > 0 {
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
                    }
                    
                    Spacer()
                    
                    // Bottom: Continue button
                    Button(action: {
                        withAnimation(.spring(response: 0.6)) {
                            gameState.nextTeam()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                            Text(continueButtonText)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.accentColor, .accentColor.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
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
                        if gameState.timeRemaining > 0 {
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
                    
                    // Continue button with enhanced design
                    Button(action: {
                        withAnimation(.spring(response: 0.6)) {
                            gameState.nextTeam()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                            Text(continueButtonText)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.accentColor, .accentColor.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var transitionTitle: String {
        if gameState.timeRemaining == 0 {
            return "Time's Up!"
        } else {
            return "Round Complete!"
        }
    }
    
    private var transitionMessage: String {
        if gameState.timeRemaining == 0 {
            return "Team \(gameState.currentTeam) ran out of time"
        } else {
            return "Team \(gameState.currentTeam) completed all words with \(formatTime(gameState.timeRemaining)) remaining!"
        }
    }
    
    private var nextTeamTitle: String {
        if gameState.timeRemaining == 0 {
            return "Next Up:"
        } else {
            return "Same Team Continues:"
        }
    }
    
    private var nextTeamNumber: Int {
        if gameState.timeRemaining == 0 {
            return gameState.currentTeam == 1 ? 2 : 1
        } else {
            return gameState.currentTeam
        }
    }
    
    private var nextTeamMessage: String {
        if gameState.timeRemaining == 0 {
            return "Get ready to play!"
        } else {
            return "Continue with remaining time!"
        }
    }
    
    private var continueButtonText: String {
        if gameState.timeRemaining == 0 {
            return "Continue to Next Team"
        } else {
            return "Continue to Next Round"
        }
    }
    
    private var statusIcon: String {
        if gameState.timeRemaining == 0 {
            return "clock.badge.exclamationmark"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        if gameState.timeRemaining == 0 {
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
    
    private var transitionTitleWithRound: String {
        if gameState.timeRemaining == 0 {
            return "Round \(gameState.currentRound) Complete!"
        } else {
            return "Round \(gameState.currentRound) Complete!"
        }
    }
}

#Preview {
    RoundTransitionView(gameState: GameState())
} 

#Preview("Landscape", traits: .landscapeLeft) {
    RoundTransitionView(gameState: GameState())
}

