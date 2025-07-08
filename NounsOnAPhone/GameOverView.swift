import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Horizontal layout
                HStack(spacing: 32) {
                    // Left side - Winner announcement
                    VStack(spacing: 24) {
                        // Header with improved styling
                        VStack(spacing: 16) {
                            Text("Fishbowl")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Final Results")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Winner or tie announcement with enhanced design
                        VStack(spacing: 24) {
                            if let winner = gameState.getWinner() {
                                WinnerOrTieView(isTie: false, winner: winner)
                            } else {
                                WinnerOrTieView(isTie: true, winner: nil)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                        )
                        
                        Spacer()
                        
                        // Play again button with enhanced design
                        GameButton.success(
                            title: "Play Again",
                            icon: "arrow.clockwise.circle.fill",
                            size: .large
                        ) {
                            withAnimation(.spring(response: 0.6)) {
                                gameState.resetGame()
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .frame(maxWidth: geometry.size.width * 0.5)
                    
                    // Right side - Final scores
                    VStack(spacing: 20) {
                        Text("Final Scores")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(.systemGray6))
                            )
                        
                        VStack(spacing: 16) {
                            FinalScoreCard(
                                teamNumber: 1,
                                score: gameState.team1Score,
                                isWinner: gameState.getWinner() == 1
                            )
                            
                            FinalScoreCard(
                                teamNumber: 2,
                                score: gameState.team2Score,
                                isWinner: gameState.getWinner() == 2
                            )
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: geometry.size.width * 0.5)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            } else {
                // Vertical layout with scrollable middle section
                VStack(spacing: 0) {
                    // Fixed header
                    VStack(spacing: 16) {
                        Text("Fishbowl")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    // Scrollable middle section
                    ScrollView {
                        VStack(spacing: 32) {
                            // Final Results title at top of scrollable section
                            Text("Final Results")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                            
                            // Winner or tie announcement with enhanced design
                            VStack(spacing: 24) {
                                if let winner = gameState.getWinner() {
                                    WinnerOrTieView(isTie: false, winner: winner)
                                } else {
                                    WinnerOrTieView(isTie: true, winner: nil)
                                }
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                            )
                            
                            // Final scores with improved design
                            VStack(spacing: 20) {
                                Text("Final Scores")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color(.systemGray6))
                                    )
                                
                                HStack(spacing: 16) {
                                    FinalScoreCard(
                                        teamNumber: 1,
                                        score: gameState.team1Score,
                                        isWinner: gameState.getWinner() == 1
                                    )
                                    
                                    FinalScoreCard(
                                        teamNumber: 2,
                                        score: gameState.team2Score,
                                        isWinner: gameState.getWinner() == 2
                                    )
                                }
                            }
                            
                            // Word statistics
                            WordStatisticsView(wordStats: gameState.getWordStatistics())
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                    
                    // Fixed footer
                    VStack(spacing: 16) {
                        // Play again button with enhanced design
                        GameButton.success(
                            title: "Play Again",
                            icon: "arrow.clockwise.circle.fill",
                            size: .large
                        ) {
                            withAnimation(.spring(response: 0.6)) {
                                gameState.resetGame()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct WinnerOrTieView: View {
    let isTie: Bool
    let winner: Int?
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(isTie ? Color.blue.opacity(0.1) : Color.yellow.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: isTie ? "equal.circle" : "trophy.fill")
                    .font(.system(size: 48))
                    .foregroundColor(isTie ? .blue : .yellow)
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isTie ? 0 : (winner ?? 0))
            VStack(spacing: 8) {
                if isTie {
                    Text("It's a Tie!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Both teams played equally well!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                } else {
                    Text("Team \(winner ?? 0) Wins!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Congratulations!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct FinalScoreCard: View {
    let teamNumber: Int
    let score: Int
    let isWinner: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Team header
            HStack(spacing: 8) {
                Text("Team \(teamNumber)")
                    .font(.headline)
                    .foregroundColor(isWinner ? .primary : .secondary)
                
                if isWinner {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)
                }
            }
            
            // Score display
            Text("\(score)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(isWinner ? .primary : .secondary)
            
            // Winner badge
            if isWinner {
                Text("Winner!")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.yellow)
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isWinner ? Color.yellow.opacity(0.1) : Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isWinner ? Color.yellow.opacity(0.3) : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isWinner ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isWinner)
    }
}

#Preview {
    GameOverView(gameState: GameState())
} 
