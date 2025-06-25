import SwiftUI

struct GameOverviewView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Horizontal layout
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
                    
                    // Round descriptions in horizontal layout
                    HStack(spacing: 16) {
                        ForEach(RoundType.allCases, id: \.rawValue) { round in
                            RoundDescriptionCard(round: round)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    Spacer()
                    
                    // Ready to begin button with enhanced design
                    Button(action: {
                        withAnimation(.spring(response: 0.6)) {
                            gameState.beginRound()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("Ready to Begin!")
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
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            } else {
                // Vertical layout (original)
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
                            RoundDescriptionCard(round: round)
                        }
                    }
                    
                    Spacer()
                    
                    // Ready to begin button with enhanced design
                    Button(action: {
                        withAnimation(.spring(response: 0.6)) {
                            gameState.beginRound()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("Ready to Begin!")
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
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct RoundDescriptionCard: View {
    let round: RoundType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                // Round number with enhanced design
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
                    
                    Text(round.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            // Round-specific icon
            HStack {
                Image(systemName: roundIcon)
                    .font(.title3)
                    .foregroundColor(roundColor)
                
                Text(roundTip)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
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