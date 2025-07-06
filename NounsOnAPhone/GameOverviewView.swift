import SwiftUI

struct GameOverviewView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Horizontal layout - REFACTORED
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        // Header row: Title left, Timer right
                        HStack(alignment: .top) {
                            Text("Fishbowl")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Image(systemName: "timer")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                Text("\(gameState.timerDuration) seconds per team")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.accentColor.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 8)

                        // Round descriptions in horizontal layout, more space, no text cut off
                        HStack(spacing: 16) {
                            ForEach(RoundType.allCases, id: \.rawValue) { round in
                                HorizontalRoundDescriptionCard(round: round)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 210) // Fixed height for all cards
                            }
                        }
                        
                        // Button pinned above safe area
                        GameButton.success(
                            title: "Ready to Begin!",
                            icon: "play.circle.fill",
                            size: .large
                        ) {
                            withAnimation(.spring(response: 0.6)) {
                                gameState.beginRound()
                            }
                        }
                        
                    }
                    .padding(.horizontal, 12)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                    .frame(maxHeight: .infinity, alignment: .top)


                }
                .ignoresSafeArea(.keyboard)
            } else {
                // Vertical layout (original)
                ZStack(alignment: .bottom) {
                    VStack(spacing: 24) {
                        // Header with improved styling
                        VStack(spacing: 12) {
                            Text("Fishbowl")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("\(gameState.words.count) words ready to play!")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            // Timer duration info with enhanced design
                            HStack(spacing: 12) {
                                Image(systemName: "timer")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                
                                Text("\(gameState.timerDuration) seconds per team")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.accentColor.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.top, 20)
                        
                        // Round descriptions with improved card design
                        VStack(spacing: 16) {
                            ForEach(RoundType.allCases, id: \.rawValue) { round in
                                VerticalRoundDescriptionCard(round: round)
                            }
                        }
                        
                        Spacer()
                        
                        // Button pinned above safe area
                        GameButton.success(
                            title: "Ready to Begin!",
                            icon: "play.circle.fill",
                            size: .large
                        ) {
                            withAnimation(.spring(response: 0.6)) {
                                gameState.beginRound()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxHeight: .infinity, alignment: .top)
                
                }
                .ignoresSafeArea(.keyboard)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Horizontal Card
struct HorizontalRoundDescriptionCard: View {
    let round: RoundType
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(roundColor)
                        .frame(width: 40, height: 40)
                    Text("\(round.rawValue)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(round.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(round.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            if round == .oneWord {
                Spacer() // Push content to top only for one word round
            }
            HStack {
                Image(systemName: roundIcon)
                    .font(.title3)
                    .foregroundColor(roundColor)
                Text(roundTip)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(roundColor.opacity(0.1))
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    private var roundColor: Color {
        switch round {
        case .describe:
            return .blue
        case .actOut:
            return .orange
        case .oneWord:
            return .purple
        }
    }
    private var roundIcon: String {
        switch round {
        case .describe:
            return "text.bubble"
        case .actOut:
            return "person.fill"
        case .oneWord:
            return "1.circle"
        }
    }
    private var roundTip: String {
        switch round {
        case .describe:
            return "Use descriptions, synonyms, or related words"
        case .actOut:
            return "Use gestures, facial expressions, and body language"
        case .oneWord:
            return "Only one word allowed - choose carefully!"
        }
    }
}
// MARK: - Vertical Card
struct VerticalRoundDescriptionCard: View {
    let round: RoundType
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(roundColor)
                        .frame(width: 40, height: 40)
                    Text("\(round.rawValue)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(round.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(round.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Image(systemName: roundIcon)
                    .font(.title3)
                    .foregroundColor(roundColor)
                Text(roundTip)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(roundColor.opacity(0.1))
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    private var roundColor: Color {
        switch round {
        case .describe:
            return .blue
        case .actOut:
            return .orange
        case .oneWord:
            return .purple
        }
    }
    private var roundIcon: String {
        switch round {
        case .describe:
            return "text.bubble"
        case .actOut:
            return "person.fill"
        case .oneWord:
            return "1.circle"
        }
    }
    private var roundTip: String {
        switch round {
        case .describe:
            return "Use descriptions, synonyms, or related words"
        case .actOut:
            return "Use gestures, facial expressions, and body language"
        case .oneWord:
            return "Only one word allowed - choose carefully!"
        }
    }
}

#Preview {
    GameOverviewView(gameState: GameState())
}

#Preview("Landscape", traits: .landscapeLeft) {
    GameOverviewView(gameState: GameState())
}
